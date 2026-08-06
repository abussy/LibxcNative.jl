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
            return "ifelse(" + self.stringify([cond, a, b], ", ") + ")"
        if name == "my_piecewise5":
            c1, a, c2, b, c = expr.args
            return "ifelse(" + self.stringify(
                [c1, a, self._make_piecewise5(c2, b, c)], ", "
            ) + ")"
        return super()._print_Function(expr)

    def _make_piecewise5(self, c2: sp.Expr, b: sp.Expr, c: sp.Expr) -> str:
        return "ifelse(" + self.stringify([c2, b, c], ", ") + ")"


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

    # zk function: energy per particle.
    lines.append(
        f"function zk(params, {', '.join(args)})\n    "
        + to_julia(zk_raw).replace("\n", "\n    ")
        + "\nend\n"
    )

    # First derivative functions (potentials) are derivatives of epsilon.
    for out_name, var in derivs:
        deriv = sp.diff(epsilon, var)
        lines.append(
            f"function {out_name}(params, {', '.join(args)})\n    "
            + to_julia(deriv).replace("\n", "\n    ")
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
