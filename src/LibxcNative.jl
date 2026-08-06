module LibxcNative

# Native-Julia reimplementation of a subset of libxc functionals.
# The public API mirrors JuliaMolSim/Libxc.jl.

const libxc_version = v"7.0.0"
const libxc_doi     = "10.1063/1.1940598"

export
    available_functionals,
    Functional,
    evaluate, evaluate!,
    supported_derivatives,
    is_lda, is_gga, is_mgga, is_hybrid,
    is_vv10, is_range_separated, is_global_hybrid,
    needs_laplacian, needs_tau

include("spin_dimensions.jl")
include("generated/registry.jl")
include("Functional.jl")
include("families/lda.jl")
include("families/gga.jl")
include("families/mgga.jl")
include("evaluate.jl")

end # module
