#!/usr/bin/env python3
"""Regenerate the native Julia modules for all supported functionals."""

from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generate_functional import generate  # noqa: E402

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

OUT_DIR = Path(__file__).resolve().parent.parent / "src" / "generated" / "functionals"


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    for name in FUNCTIONALS:
        text = generate(name)
        (OUT_DIR / f"{name}.jl").write_text(text)
        print(f"Wrote {OUT_DIR / name}.jl")


if __name__ == "__main__":
    main()
