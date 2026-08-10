#!/usr/bin/env python3
"""Generate a native Julia module for one libxc functional."""

from __future__ import annotations

import argparse
import os
import re
import sys
from pathlib import Path
from typing import Any

import sympy as sp
from sympy.printing.julia import JuliaCodePrinter

# Make the local libxc_source importable.
sys.path.insert(0, str(Path(__file__).resolve().parent))
from libxc_source import (  # noqa: E402
    FAMILY_BY_TYPE,
    get_energy_expression,
    load_math_module,
    parse_c_wrapper,
    raw_substitution,
    substitute_param_defaults,
)

REPO_ROOT = Path(__file__).resolve().parent.parent
OUT_DIR = REPO_ROOT / "src" / "generated" / "functionals"

MPL_HEADER = """# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# ---------------------------------------------------------------------------
# GENERATED FILE - do not edit manually.
# Generated from upstream libxc SymPy sources (deps/libxc) by
#   python gen/generate_functional.py {name}
# ---------------------------------------------------------------------------
"""


class LibxcNativeJuliaPrinter(JuliaCodePrinter):
    """Julia printer that understands the libxc-specific helper heads."""

    def _print_branch(self, expr: sp.Expr) -> str:
        """Print a piecewise branch; promote integer 0 to 0.0 for type stability."""
        if expr.is_zero:
            return "0.0"
        return self._print(expr)

    def _print_Function(self, expr: sp.Function) -> str:
        name = expr.func.__name__
        if name == "xc_log1p":
            return "log1p(" + self.stringify(expr.args, ", ") + ")"
        if name == "xc_expm1":
            return "expm1(" + self.stringify(expr.args, ", ") + ")"
        if name == "xc_asinh":
            return "asinh(" + self.stringify(expr.args, ", ") + ")"
        if name == "xc_atanh":
            return "atanh(" + self.stringify(expr.args, ", ") + ")"
        if name == "my_piecewise3":
            cond, a, b = expr.args
            return (
                "(" + self._print(cond) + " ? "
                + self._print_branch(a) + " : " + self._print_branch(b) + ")"
            )
        if name == "my_piecewise5":
            c1, a, c2, b, c = expr.args
            return (
                "(" + self._print(c1) + " ? " + self._print_branch(a) + " : "
                + self._make_piecewise5(c2, b, c) + ")"
            )

        return super()._print_Function(expr)

    def _make_piecewise5(self, c2: sp.Expr, b: sp.Expr, c: sp.Expr) -> str:
        return (
            "(" + self._print(c2) + " ? " + self._print_branch(b) + " : "
            + self._print_branch(c) + ")"
        )

    def _print_Pow(self, expr):
        base, exp = expr.args
        if exp.is_Rational:
            p, q = exp.p, exp.q
            b = self._print(base)
            if q == 2:
                return f"(sqrt({b}) ^ {p})"
            if q == 3:
                return f"(cbrt({b}) ^ {p})"
            if q == 4:
                return f"(sqrt(sqrt({b})) ^ {p})"
        return super()._print_Pow(expr)


def to_julia(expr: sp.Expr) -> str:
    """Convert a SymPy expression to scalar Julia code."""
    text = LibxcNativeJuliaPrinter().doprint(expr)
    # The inherited printer uses broadcasted operators; force scalar code.
    text = re.sub(r"\s*\.\*\s*", " * ", text)
    text = re.sub(r"\s*\.\/\s*", " / ", text)
    text = re.sub(r"\s*\.\^\s*", "^", text)
    # Threshold parameters live in the params NamedTuple.
    text = text.replace("dens_threshold", "params.dens_threshold")
    text = text.replace("zeta_threshold", "params.zeta_threshold")
    return text


def _raw_symbols() -> dict[str, sp.Symbol]:
    return {
        "rho_up": sp.Symbol("rho_up", positive=True),
        "rho_down": sp.Symbol("rho_down", positive=True),
        "sigma_aa": sp.Symbol("sigma_aa", positive=True),
        "sigma_ab": sp.Symbol("sigma_ab", real=True),
        "sigma_bb": sp.Symbol("sigma_bb", positive=True),
        "lapl_up": sp.Symbol("lapl_up", real=True),
        "lapl_down": sp.Symbol("lapl_down", real=True),
        "tau_up": sp.Symbol("tau_up", positive=True),
        "tau_down": sp.Symbol("tau_down", positive=True),
    }


def _unpolarized_symbols() -> dict[str, sp.Symbol]:
    return {
        "rho": sp.Symbol("rho", positive=True),
        "sigma": sp.Symbol("sigma", positive=True),
        "lapl": sp.Symbol("lapl", real=True),
        "tau": sp.Symbol("tau", positive=True),
    }


def _unpolarized_substitution(raw: dict[str, sp.Symbol], unp: dict[str, sp.Symbol]) -> dict[sp.Expr, sp.Expr]:
    """Map spin-resolved variables to unpolarized ones (rho_up = rho_down = rho/2, etc.)."""
    return {
        raw["rho_up"]: unp["rho"] / 2,
        raw["rho_down"]: unp["rho"] / 2,
        raw["sigma_aa"]: unp["sigma"] / 4,
        raw["sigma_ab"]: unp["sigma"] / 4,
        raw["sigma_bb"]: unp["sigma"] / 4,
        raw["lapl_up"]: unp["lapl"] / 2,
        raw["lapl_down"]: unp["lapl"] / 2,
        raw["tau_up"]: unp["tau"] / 2,
        raw["tau_down"]: unp["tau"] / 2,
    }


def derivative_variables(
    family: str, needs_lapl: bool, needs_tau: bool
) -> list[tuple[str, sp.Symbol]]:
    """Return (output_name, raw_variable) pairs for first derivatives."""
    r = _raw_symbols()
    out = [("vrho_up", r["rho_up"]), ("vrho_down", r["rho_down"])]
    if family in ("gga", "mgga"):
        out.extend(
            [
                ("vsigma_aa", r["sigma_aa"]),
                ("vsigma_ab", r["sigma_ab"]),
                ("vsigma_bb", r["sigma_bb"]),
            ]
        )
    if family == "mgga":
        if needs_lapl:
            out.extend(
                [("vlapl_up", r["lapl_up"]), ("vlapl_down", r["lapl_down"])]
            )
        if needs_tau:
            out.extend([("vtau_up", r["tau_up"]), ("vtau_down", r["tau_down"])])
    return out


def function_signature(family: str, needs_lapl: bool, needs_tau: bool) -> list[str]:
    """Argument list used by every generated scalar function for this family."""
    base = ["rho_up", "rho_down"]
    if family in ("gga", "mgga"):
        base += ["sigma_aa", "sigma_ab", "sigma_bb"]
    if family == "mgga":
        if needs_lapl:
            base += ["lapl_up", "lapl_down"]
        if needs_tau:
            base += ["tau_up", "tau_down"]
    return base


def unpolarized_signature(family: str, needs_lapl: bool, needs_tau: bool) -> list[str]:
    """Argument list for the unpolarized (n_spin == 1) scalar kernels."""
    base = ["rho"]
    if family in ("gga", "mgga"):
        base += ["sigma"]
    if family == "mgga":
        if needs_lapl:
            base += ["lapl"]
        if needs_tau:
            base += ["tau"]
    return base


def unpolarized_derivatives(
    family: str, needs_lapl: bool, needs_tau: bool, unp: dict[str, sp.Symbol]
) -> list[tuple[str, sp.Symbol]]:
    """Derivative variable names for unpolarized kernels."""
    out = [("vrho", unp["rho"])]
    if family in ("gga", "mgga"):
        out.append(("vsigma", unp["sigma"]))
    if family == "mgga":
        if needs_lapl:
            out.append(("vlapl", unp["lapl"]))
        if needs_tau:
            out.append(("vtau", unp["tau"]))
    return out


def generate(name: str) -> str:
    print(f"Generating {name} ...")
    mod = load_math_module(name)
    family = FAMILY_BY_TYPE[mod.TYPE]
    meta = parse_c_wrapper(name)

    # Energy-per-particle in reduced variables.
    energy_reduced = get_energy_expression(mod)

    # Substitute defaults from the C wrapper for any remaining params_a_* symbols.
    energy_reduced = substitute_param_defaults(energy_reduced, meta["params"])

    # Convert to raw spin-resolved variables.
    sub = raw_substitution(mod)
    zk_raw = energy_reduced.xreplace(sub)

    # Energy density epsilon = rho_total * zk.
    r = _raw_symbols()
    rho_total = r["rho_up"] + r["rho_down"]
    epsilon = rho_total * zk_raw

    needs_lapl = "needs_laplacian" in meta["flags"]
    needs_tau = "needs_tau" in meta["flags"]

    args = function_signature(family, needs_lapl, needs_tau)
    derivs = derivative_variables(family, needs_lapl, needs_tau)

    # Default parameters carried by the Functional object.
    default_params = {"dens_threshold": meta["dens_threshold"], "zeta_threshold": 1e-15}
    params_tuple = ", ".join(f"{k}={v}" for k, v in default_params.items())

    lines: list[str] = []
    lines.append(MPL_HEADER.format(name=name))
    lines.append(f"module {name}\n")
    lines.append("using Base: ifelse\n")
    lines.append(f"const FAMILY = :{family}\n")
    lines.append(f"const DEFAULT_PARAMS = (; {params_tuple})\n")

    def body_with_guard(expr: sp.Expr, total_density: str = "rho_up + rho_down") -> str:
        """Return the indented function body with a density-threshold guard."""
        if expr.is_zero:
            body = f"zero({total_density.split()[0]})"
        else:
            replacements, reduced = sp.cse(expr)
            lines = []
            for sym, val in replacements:
                lines.append(f"{sym} = {to_julia(val)}")
            lines.append(to_julia(reduced[0]))
            body = "\n    ".join(lines)
        return (
            f"    if {total_density} <= params.dens_threshold\n"
            f"        return zero({total_density.split()[0]})\n"
            "    end\n"
            "    " + body
        )

    # zk function: energy per particle.
    lines.append(
        f"function zk(params, {', '.join(args)})\n"
        + body_with_guard(zk_raw)
        + "\nend\n"
    )

    # First derivative functions (potentials) are derivatives of epsilon.
    for out_name, var in derivs:
        deriv = sp.diff(epsilon, var)
        lines.append(
            f"function {out_name}(params, {', '.join(args)})\n"
            + body_with_guard(deriv)
            + "\nend\n"
        )

    # -----------------------------------------------------------------------
    # Unpolarized (n_spin == 1) kernels: substitute zeta = 0 before printing.
    # These are much cheaper because all spin-interpolation piecewise disappears.
    # -----------------------------------------------------------------------
    unp = _unpolarized_symbols()
    unp_sub = _unpolarized_substitution(r, unp)
    epsilon_unp = epsilon.xreplace(unp_sub)
    # Energy per particle for the unpolarized case.
    zk_unp = epsilon_unp / unp["rho"]

    unp_args = unpolarized_signature(family, needs_lapl, needs_tau)
    unp_derivs = unpolarized_derivatives(family, needs_lapl, needs_tau, unp)

    lines.append(
        f"function zk_unp(params, {', '.join(unp_args)})\n"
        + body_with_guard(zk_unp, "rho")
        + "\nend\n"
    )
    for out_name, var in unp_derivs:
        deriv = sp.diff(epsilon_unp, var)
        lines.append(
            f"function {out_name}_unp(params, {', '.join(unp_args)})\n"
            + body_with_guard(deriv, "rho")
            + "\nend\n"
        )

    lines.append("\nend # module")
    return "\n".join(lines)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Generate a native Julia functional module from libxc sources."
    )
    parser.add_argument("name", help="functional name, e.g. lda_x")
    parser.add_argument(
        "-o",
        "--output",
        type=Path,
        help="output file (default: src/generated/functionals/<name>.jl)",
    )
    args = parser.parse_args()

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    output = args.output or OUT_DIR / f"{args.name}.jl"
    text = generate(args.name)
    output.write_text(text)
    print(f"Wrote {output}")


if __name__ == "__main__":
    main()
