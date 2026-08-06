#!/usr/bin/env python3
"""Generate reference test data from the upstream libxc regression tests.

The regression tests under deps/libxc/testsuite/regression/ contain the
expected output arrays inline.  This script extracts them, together with the
input density grids from pylibxc/example_densities.py, and writes JSON files
that the Julia test suite can load.
"""

from __future__ import annotations

import ast
import json
import os
import re
import sys
from pathlib import Path
from typing import Any

REPO_ROOT = Path(__file__).resolve().parent.parent
LIBXC_DIR = REPO_ROOT / "deps" / "libxc"
EXAMPLE_DENSITIES = LIBXC_DIR / "pylibxc" / "example_densities.py"
REGRESSION_DIR = LIBXC_DIR / "testsuite" / "regression"
OUT_DIR = REPO_ROOT / "test" / "references"

FUNCTIONALS = [
    "lda_x",
    "lda_c_pw",
    "lda_c_vwn",
    "lda_xc_teter93",
    "gga_x_pbe",
    "gga_c_pbe",
    "mgga_x_scan",
    "mgga_c_scan",
]


def _parse_example_densities() -> dict[str, dict[str, Any]]:
    """Parse pylibxc/example_densities.py manually (it does not need libxc)."""
    text = EXAMPLE_DENSITIES.read_text()
    tree = ast.parse(text)
    arrays: dict[str, list[float]] = {}
    for node in ast.walk(tree):
        if isinstance(node, ast.Assign):
            for target in node.targets:
                if isinstance(target, ast.Name) and target.id.endswith("_data"):
                    # asarray([...]).reshape(...) -> evaluate the list argument
                    value = node.value
                    # Unwrap a trailing method call (.reshape, .transpose, etc.)
                    if isinstance(value, ast.Call) and isinstance(value.func, ast.Attribute):
                        value = value.func.value
                    if isinstance(value, ast.Call) and value.args:
                        try:
                            arrays[target.id] = ast.literal_eval(value.args[0])
                        except (ValueError, SyntaxError):
                            pass

    def make_input(data: list[float], nspin: int) -> dict[str, Any]:
        # data flattened in C (row-major) order with columns:
        # rhoa, rhob, sigmaaa, sigmaab, sigmabb, lapla, laplb, taua, taub
        n = len(data) // 9
        cols = [data[i::9] for i in range(9)]
        rhoa, rhob, sigmaaa, sigmaab, sigmabb, lapla, laplb, taua, taub = cols
        if nspin == 1:
            return {
                "rho": [a + b for a, b in zip(rhoa, rhob)],
                "sigma": [aa + bb + 2 * ab for aa, ab, bb in zip(sigmaaa, sigmaab, sigmabb)],
                "lapl": [a + b for a, b in zip(lapla, laplb)],
                "tau": [a + b for a, b in zip(taua, taub)],
            }
        else:
            return {
                "rho": [list(pair) for pair in zip(rhoa, rhob)],
                "sigma": [list(trip) for trip in zip(sigmaaa, sigmaab, sigmabb)],
                "lapl": [list(pair) for pair in zip(lapla, laplb)],
                "tau": [list(pair) for pair in zip(taua, taub)],
            }

    inputs = {
        "N": make_input(arrays["N_data"], 2),
        "N_restr": make_input(arrays["N_data"], 1),
    }
    return inputs


def _field_from_function(tree: ast.AST) -> str | None:
    """Return the output field name used in a regression test function."""
    for node in ast.walk(tree):
        if isinstance(node, ast.Subscript):
            if isinstance(node.value, ast.Name) and node.value.id == "out":
                if isinstance(node.slice, ast.Constant) and isinstance(node.slice.value, str):
                    return node.slice.value
    return None


def _extract_array_literal(function_node: ast.FunctionDef) -> list[float] | None:
    """Find ``ref_tgt = ns.full_like(tgt, ns.asarray([...]))`` and return the list."""
    for node in ast.walk(function_node):
        if isinstance(node, ast.Assign):
            for target in node.targets:
                if isinstance(target, ast.Name) and target.id.startswith("ref_tgt"):
                    value = node.value
                    # ref_tgt = ns.full_like(tgt, ns.asarray([...]))
                    if (isinstance(value, ast.Call)
                            and len(value.args) >= 2
                            and isinstance(value.args[1], ast.Call)
                            and value.args[1].args):
                        inner = value.args[1].args[0]
                        try:
                            return ast.literal_eval(inner)
                        except (ValueError, SyntaxError):
                            pass
    return None


def _parse_regression_test(path: Path) -> dict[str, list[float]]:
    """Parse a single regression test file into {field: flattened_array}."""
    text = path.read_text()
    tree = ast.parse(text)
    refs: dict[str, list[float]] = {}
    for node in tree.body:
        if isinstance(node, ast.FunctionDef) and node.name.startswith("test_"):
            field = _field_from_function(node)
            arr = _extract_array_literal(node)
            if field and arr:
                refs[field] = arr
    return refs


def _family_dir(name: str) -> str:
    """Find the existing regression directory for the functional."""
    for subdir in REGRESSION_DIR.iterdir():
        if subdir.is_dir() and any(subdir.glob(f"test_{name}_*.py")):
            return subdir.name
    raise FileNotFoundError(f"no regression directory for {name}")


def _reshape(field: str, values: list[float], n_points: int, nspin: int) -> list[Any]:
    if field == "zk":
        return values
    if field in ("vrho", "vlapl", "vtau"):
        dim = 2 if nspin == 2 else 1
        if dim == 1:
            return values
        return [values[i * dim : (i + 1) * dim] for i in range(n_points)]
    if field == "vsigma":
        dim = 3 if nspin == 2 else 1
        if dim == 1:
            return values
        return [values[i * dim : (i + 1) * dim] for i in range(n_points)]
    # Unknown field: keep flat
    return values


def generate_for_functional(name: str, inputs: dict[str, dict[str, Any]]) -> None:
    print(f"Generating references for {name} ...")
    family_dir = _family_dir(name)
    for suffix, nspin, key in (("N", 2, "N"), ("N_restr", 1, "N_restr")):
        test_path = REGRESSION_DIR / family_dir / f"test_{name}_{suffix}.py"
        if not test_path.is_file():
            print(f"  warning: {test_path} not found, skipping")
            continue
        refs = _parse_regression_test(test_path)
        if not refs:
            print(f"  warning: no references found in {test_path}")
            continue
        inp = inputs[key]
        n_points = len(inp["rho"])
        reshaped = {field: _reshape(field, arr, n_points, nspin)
                    for field, arr in refs.items()}
        data = {
            "functional": name,
            "n_spin": nspin,
            "inputs": inp,
            "expected": reshaped,
        }
        out_path = OUT_DIR / f"{name}_{suffix}.json"
        out_path.write_text(json.dumps(data, indent=2))
        print(f"  wrote {out_path}")


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    inputs = _parse_example_densities()
    for name in FUNCTIONALS:
        generate_for_functional(name, inputs)


if __name__ == "__main__":
    main()
