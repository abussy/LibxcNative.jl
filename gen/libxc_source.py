#!/usr/bin/env python3
"""Utilities for reading the upstream libxc source and extracting symbolic
functional definitions."""

from __future__ import annotations

import importlib.util
import os
import re
from pathlib import Path
from typing import Any

import sympy as sp

# Absolute path to the repository root (parent of gen/)
REPO_ROOT = Path(__file__).resolve().parent.parent
LIBXC_DIR = REPO_ROOT / "deps" / "libxc"
PYTHON_DIR = LIBXC_DIR / "python"
SRC_DIR = LIBXC_DIR / "src"


def _setup_python_path() -> None:
    """Make the upstream python/ tree importable, including family subdirs."""
    if str(PYTHON_DIR) not in sys.path:
        sys.path.insert(0, str(PYTHON_DIR))
    for entry in sorted(os.listdir(PYTHON_DIR)):
        sub = PYTHON_DIR / entry
        if sub.is_dir() and str(sub) not in sys.path:
            sys.path.insert(0, str(sub))


# Insert immediately so that the import below works.
import sys  # noqa: E402

_setup_python_path()

import libxc_codegen  # noqa: E402


FAMILY_BY_TYPE = {
    "lda_exc": "lda",
    "gga_exc": "gga",
    "mgga_exc": "mgga",
}

# Numeric values for constants that survive deep inlining.
_CONSTANT_SUBS = {
    sp.Symbol("M_CBRT3", positive=True): sp.N(3 ** (sp.Rational(1, 3))),
    sp.Symbol("M_CBRTPI", positive=True): sp.N(sp.pi ** (sp.Rational(1, 3))),
    sp.Symbol("M_CBRT2", positive=True): sp.N(2 ** (sp.Rational(1, 3))),
    sp.Symbol("M_PI", positive=True): sp.pi,
    sp.Symbol("XC_EPSILON", positive=True): sp.N(2.220446049250313e-16),
    sp.Symbol("XC_MIN", positive=True): sp.N(2.2250738585072014e-308),
}


def find_math_file(name: str) -> tuple[str, Path]:
    """Return (family, path) for python/<family>/<name>.py."""
    for family in sorted(os.listdir(PYTHON_DIR)):
        candidate = PYTHON_DIR / family / f"{name}.py"
        if candidate.is_file():
            return family, candidate
    raise FileNotFoundError(f"no python/<family>/{name}.py found")


def load_math_module(name: str) -> Any:
    """Load the upstream SymPy math module for ``name``.

    The module's ``PARAMS_STRUCT`` macro is activated so that parameter
    defaults baked in the .py file are used when available.  Helpers are
    left unresolved; call ``resolve_helpers`` afterwards if you need the
    fully inlined energy expression.
    """
    _setup_python_path()
    family, src = find_math_file(name)
    spec = importlib.util.spec_from_file_location(name, src)
    mod = importlib.util.module_from_spec(spec)

    # Activate the functional's parameter-default block.  The parameter struct
    # name is not yet known (it is defined inside the module), so we use the
    # conventional name derived from the functional name.  Special cases such
    # as included parameter blocks are handled explicitly.
    setattr(mod, f"_macro_{name}_params", True)
    if name == "gga_c_pbe":
        setattr(mod, "_macro_lda_c_pw_params", True)
        setattr(mod, "_macro_lda_c_pw_modified_params", True)

    spec.loader.exec_module(mod)  # type: ignore[union-attr]
    return mod


def resolve_helpers(mod: Any) -> None:
    """Resolve every @helper proxy in ``mod`` so expressions can be inlined.

    We leave spin-density screening in reconstruction mode (no marker) so that
    the resulting expressions are written purely in terms of the spin densities
    and can be differentiated symbolically.
    """
    for obj in list(vars(mod).values()):
        if getattr(obj, "_is_helper_proxy", False):
            obj._resolve()


def reduced_variables(mod: Any) -> list[sp.Symbol]:
    """Return the reduced-variable symbols expected by ``mod.f``."""
    sig = mod.f.__code__.co_varnames[: mod.f.__code__.co_argcount]
    return [sp.Symbol(v, real=True) for v in sig]


def get_energy_expression(mod: Any) -> sp.Expr:
    """Return the energy-per-particle expression in reduced variables."""
    resolve_helpers(mod)
    vars_ = reduced_variables(mod)
    expr = mod.f(*vars_)
    expr = libxc_codegen._deep_inline(expr)
    # Replace surviving placeholders with numeric constants.
    expr = expr.subs(_CONSTANT_SUBS)
    return expr


def family_from_module(mod: Any) -> str:
    return FAMILY_BY_TYPE[mod.TYPE]


# ---------------------------------------------------------------------------
# Conversion from reduced variables to raw spin-resolved quantities
# ---------------------------------------------------------------------------

_X2S = sp.Rational(1, 2) * (6 * sp.pi ** 2) ** (-sp.Rational(1, 3))
_XT2S = sp.Rational(1, 2) * (3 * sp.pi ** 2) ** (-sp.Rational(1, 3))


def _make_raw_symbols() -> dict[str, sp.Symbol]:
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


def raw_substitution(mod: Any) -> dict[sp.Symbol, sp.Expr]:
    """Map the reduced variables used by ``mod.f`` to raw spin-resolved forms."""
    r = _make_raw_symbols()
    rho_up, rho_down = r["rho_up"], r["rho_down"]
    sigma_aa, sigma_ab, sigma_bb = r["sigma_aa"], r["sigma_ab"], r["sigma_bb"]
    lapl_up, lapl_down = r["lapl_up"], r["lapl_down"]
    tau_up, tau_down = r["tau_up"], r["tau_down"]

    rho_total = rho_up + rho_down
    zeta = (rho_up - rho_down) / rho_total
    rs = ((sp.Rational(3, 4) / sp.pi) / rho_total) ** (sp.Rational(1, 3))

    sigma_total = sigma_aa + 2 * sigma_ab + sigma_bb

    # Per-spin reduced gradients (the arguments of gga_s / gga_s_total are
    # already the physical reduced gradients s = |grad n| / n^(4/3)).
    xs0 = sp.sqrt(sigma_aa) / rho_up ** (sp.Rational(4, 3))
    xs1 = sp.sqrt(sigma_bb) / rho_down ** (sp.Rational(4, 3))
    xt = sp.sqrt(sigma_total) / rho_total ** (sp.Rational(4, 3))

    # Reduced laplacian and kinetic energy density.
    u0 = lapl_up / rho_up ** (sp.Rational(5, 3))
    u1 = lapl_down / rho_down ** (sp.Rational(5, 3))
    t0 = tau_up / rho_up ** (sp.Rational(5, 3))
    t1 = tau_down / rho_down ** (sp.Rational(5, 3))

    vars_ = reduced_variables(mod)
    sig = mod.f.__code__.co_varnames[: mod.f.__code__.co_argcount]
    mapping = {
        "rs": rs,
        "z": zeta,
        "zeta": zeta,
        "xt": xt,
        "xs0": xs0,
        "xs1": xs1,
        "u0": u0,
        "u1": u1,
        "us0": u0,
        "us1": u1,
        "t0": t0,
        "t1": t1,
        "ts0": t0,
        "ts1": t1,
    }
    return {v: mapping[s] for v, s in zip(vars_, sig)}


# ---------------------------------------------------------------------------
# C-wrapper parsing
# ---------------------------------------------------------------------------


def _c_wrapper_path(name: str) -> Path:
    return SRC_DIR / f"{name}.c"


def _eval_c_expression(expr: str) -> float:
    """Safely evaluate a small C arithmetic expression to float."""
    import math

    expr = expr.strip()
    if not expr:
        raise ValueError("empty C expression")

    constants = {
        "M_PI": math.pi,
        "M_CBRT2": math.pow(2.0, 1.0 / 3.0),
        "M_CBRT3": math.pow(3.0, 1.0 / 3.0),
        "M_CBRTPI": math.pow(math.pi, 1.0 / 3.0),
        "MU_PBE": 0.06672455060314922 * math.pi * math.pi / 3.0,
        "MU_GE": 10.0 / 81.0,
    }
    env = {"__builtins__": {}}
    env.update(math.__dict__)
    env.update(constants)
    return float(eval(expr, env))  # noqa: S307


def parse_c_wrapper(name: str) -> dict[str, Any]:
    """Parse ``src/<name>.c`` for functional metadata and parameter defaults."""
    text = _c_wrapper_path(name).read_text()

    # Find the first xc_func_info_TYPE definition.
    m = re.search(
        r"const\s+xc_func_info_type\s+xc_func_info_" + re.escape(name)
        + r"\s*=\s*\{(.*?)\};",
        text,
        re.DOTALL,
    )
    if not m:
        raise RuntimeError(f"could not find xc_func_info_{name} in src/{name}.c")

    body = m.group(1)
    # Split top-level fields, ignoring commas inside strings or nested braces.
    fields = []
    depth = 0
    in_string = False
    current = []
    for ch in body:
        if ch == '"':
            in_string = not in_string
            current.append(ch)
        elif in_string:
            current.append(ch)
        elif ch == "{":
            depth += 1
            current.append(ch)
        elif ch == "}":
            depth -= 1
            current.append(ch)
        elif ch == "," and depth == 0:
            fields.append("".join(current).strip())
            current = []
        else:
            current.append(ch)
    if current:
        fields.append("".join(current).strip())
    if len(fields) < 8:
        raise RuntimeError(f"xc_func_info_{name} has fewer than 8 fields")

    family_token = fields[3]
    kind_token = fields[1]
    name_str = fields[2].strip('"')
    flags_str = fields[5]
    dens_threshold_str = fields[6]
    ext_params = fields[7]

    family = family_token.replace("XC_FAMILY_", "").lower()
    kind_map = {
        "XC_EXCHANGE": "exchange",
        "XC_CORRELATION": "correlation",
        "XC_EXCHANGE_CORRELATION": "exchange_correlation",
        "XC_KINETIC": "kinetic",
    }
    kind = kind_map.get(kind_token, "unknown")

    flags = []
    if "XC_FLAGS_HAVE_EXC" in flags_str:
        flags.append("exc")
    if "XC_FLAGS_HAVE_VXC" in flags_str:
        flags.append("vxc")
    if "XC_FLAGS_HAVE_FXC" in flags_str:
        flags.append("fxc")
    if "XC_FLAGS_HAVE_KXC" in flags_str:
        flags.append("kxc")
    if "XC_FLAGS_HAVE_LXC" in flags_str:
        flags.append("lxc")
    if "XC_FLAGS_NEEDS_LAPLACIAN" in flags_str:
        flags.append("needs_laplacian")
    if "XC_FLAGS_NEEDS_TAU" in flags_str:
        flags.append("needs_tau")

    dens_threshold = float(dens_threshold_str)

    # Parse external parameters: {n, names, desc, values_array, setter}
    params: dict[str, float] = {}
    mp = re.match(r"\s*\{\s*(\w+)\s*,\s*(\w+)\s*,\s*(\w+)\s*,\s*(\w+)\s*,", ext_params)
    if mp:
        n_par_var, names_var, desc_var, values_var = mp.groups()
        # Locate the values array definition.
        val_re = re.search(
            r"static\s+const\s+double\s+"
            + re.escape(values_var)
            + r"\s*\[.*?\]\s*=\s*\{([^}]*)\}",
            text,
        )
        names_re = re.search(
            r"static\s+const\s+char\s*\*\s*"
            + re.escape(names_var)
            + r"\s*\[.*?\]\s*=\s*\{([^}]*)\}",
            text,
        )
        if val_re:
            values = [
                _eval_c_expression(v)
                for v in val_re.group(1).split(",")
                if v.strip()
            ]
            names: list[str] = []
            if names_re:
                names = [
                    n.strip().strip('"').lstrip("_")
                    for n in names_re.group(1).split(",")
                    if n.strip()
                ]
            for i, val in enumerate(values):
                key = names[i] if i < len(names) else f"param{i}"
                params[key] = val

    return {
        "name": name_str,
        "family": family,
        "kind": kind,
        "flags": flags,
        "dens_threshold": dens_threshold,
        "params": params,
    }


def substitute_param_defaults(expr: sp.Expr, defaults: dict[str, float]) -> sp.Expr:
    """Substitute ``params_a_<name>`` symbols with their default values."""
    subs = {}
    for sym in expr.free_symbols:
        sname = str(sym)
        if sname.startswith("params_a_"):
            key = sname[len("params_a_"):]
            if key in defaults:
                subs[sym] = sp.N(defaults[key])
    if subs:
        expr = expr.subs(subs)
    return expr
