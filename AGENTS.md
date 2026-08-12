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

### Julia boxing and GPU kernel compatibility

Julia boxes variables that are **conditionally assigned** within a scope (e.g.
inside `if`/`else` branches). `Core.Box` is not isbits, so GPU compilation
fails with "passing non-bitstype argument" if any boxed variable is captured by
a `map!` closure.

This is a **scope-level** analysis, not branch-level: if *any* variable in a
function is conditionally assigned, *all* captured variables in that scope get
boxed — even ones assigned unconditionally.

Rules that follow from this:

1. **Never assign kernel functions conditionally.** Either call `get_kernel`
   unconditionally at the top of the scope, or split the function so each
   branch lives in its own scope.

2. **Split family wrappers by `n_spin`.** Each `evaluate_<family>!` dispatches
   to a dedicated `_<family>_unp!` (n_spin == 1) or `_<family>_pol!`
   (n_spin == 2) function. This isolates the different kernel sets and
   variable names in separate scopes.

3. **`get_kernel` returns `MissingKernel()` (isbits) for unimplemented kernels**
   instead of throwing. This lets all kernel lookups be unconditional —
   `vlapl`/`vtau` kernels that don't exist for a given functional simply
   return a singleton that is never called (the corresponding `if out_*`
   guard is false).

4. **Do not capture `Type` objects.** A variable like `T = eltype(rho)` is a
   `Type{Float64}`, which is not isbits. Use `zero(rui)` directly instead of
   `zero(T)` — the element type is already available from the data.

### Testing on GPU

- Run with `Pkg.test("LibxcNative"; test_args=["amdgpu"])` or
  `test_args=["cuda"]`.
- `test/compare_references.jl` defines `to_device`/`to_host` (CPU fallbacks)
  and `parse_input` (JSON → CPU `Array{Float64}`).
- GPU extensions (`ext/LibxcNative*Ext.jl`) add specialized `to_device`/
  `to_host` methods on `LibxcNative.to_device` / `LibxcNative.to_host`.
- The test label reflects the active backend (e.g. `amdgpu vs libxc
  references`).

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
