# LibxcNative.jl

Native-Julia reimplementation of a subset of exchange-correlation
functionals from the [libxc](https://libxc.gitlab.io/) library.

The public API mirrors [`JuliaMolSim/Libxc.jl`](https://github.com/JuliaMolSim/Libxc.jl)
for an easy migration path, but the package has no runtime dependency on the
original binding.

> **Status:** early development. Only a small set of functionals is
> implemented; see below.

## Supported functionals

| Family | Functionals |
|--------|-------------|
| LDA    | `lda_x`, `lda_c_pw`, `lda_c_vwn`, `lda_xc_teter93` |
| GGA    | `gga_x_pbe`, `gga_c_pbe` |
| meta-GGA | `mgga_x_scan`, `mgga_c_scan` |

Only energy (`zk`) and first-order potential (`vrho`, `vsigma`, `vtau`)
evaluations are generated at the moment.

## Usage

```julia
using LibxcNative

rho = [0.1, 0.2, 0.3, 0.4, 0.5]
fun = Functional(:lda_x)
result = evaluate(fun; rho=rho)
@show result.zk
@show result.vrho
```

The same API works on `CuArray`s and `ROCArray`s because the generated
kernels are written against `AbstractArray` and use only `isbits`
closures with `map!`/`map`.

## Regenerating code and tests

The functional implementations are generated from the SymPy sources in
the upstream `libxc` repository (pinned as a submodule under
`deps/libxc`):

```bash
python gen/generate_all.py
```

Reference test data is extracted from the upstream `libxc` regression
tests and written to `test/references/`:

```bash
python gen/generate_references.py
```

Run the test suite with:

```julia
using Pkg; Pkg.test("LibxcNative")
```

## License

The hand-written Julia wrapper code is released under the MIT license.
Files under `src/generated/functionals/` are derived from upstream
`libxc` and are licensed under the Mozilla Public License 2.0; see
`LICENSES/MPL-2.0.txt`.
