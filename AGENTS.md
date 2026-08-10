# AGENTS.md — LibxcNative.jl

Project-specific guidance for coding agents working on `LibxcNative.jl`.

## Project goal

Mimic the SymPy → C code-generation pipeline used by the upstream
[libxc](https://libxc.gitlab.io/) library, but generate **native Julia**
instead. The generated implementations must be pure Julia and have no runtime
dependency on the original libxc binding.

## API contract

The package must act as a drop-in replacement for
[`JuliaMolSim/Libxc.jl`](https://github.com/JuliaMolSim/Libxc.jl).
Keep the public API in sync: `Functional(...)` constructors, `evaluate`
signatures, and result named-tuples (e.g. `zk`, `vrho`, `vsigma`, `vtau`).

## GPU portability

Generated code must run on both `CUDA.jl` and `AMDGPU.jl` backends, written in a
backend-agnostic way:

- Target `AbstractArray` rather than concrete array types.
- Use `map` / `map!` as the primitive for pointwise evaluation loops.
- Pass only `isbits` data into kernels/closures.
- Avoid scalar indexing, runtime dispatch, and heap allocations inside GPU
  kernels.

## Code generation pipeline

- Generation scripts live in `gen/` and consume the upstream libxc source that
  is tracked in this repo as a git dependency at `deps/libxc`.
- `gen/generate_all.py` regenerates the functional implementations in
  `src/generated/functionals/`.
- `gen/generate_references.py` extracts absolute reference data from upstream
  libxc regression tests and writes them to `test/references/`.
- These scripts must remain rerunnable when `deps/libxc` is updated or bumped.
- The usage of these scripts must be documented in `README.md`.

## Initial functional scope

Start with these eight functionals:

- LDA: `lda_x`, `lda_c_pw`, `lda_c_vwn`, `lda_xc_teter93`
- GGA: `gga_x_pbe`, `gga_c_pbe`
- meta-GGA: `mgga_x_scan`, `mgga_c_scan`

## License note

Hand-written Julia wrapper code is MIT licensed. Files under
`src/generated/functionals/` are derived from upstream `libxc` and are licensed
under the Mozilla Public License 2.0; see `LICENSES/MPL-2.0.txt`.
