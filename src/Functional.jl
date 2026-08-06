mutable struct Functional
    identifier::Symbol
    n_spin::Int
    name::String
    kind::Symbol
    family::Symbol
    flags::Vector{Symbol}
    derivatives::Vector{Int}
    references::Vector{@NamedTuple{reference::String, doi::String, bibtex::String, key::String}}
    spin_dimensions::SpinDimensions
    params::NamedTuple

    function Functional(identifier::Symbol; n_spin::Integer=1)
        n_spin = Int(n_spin)
        n_spin in (1, 2) || throw(ArgumentError("n_spin must be 1 or 2"))
        spec = get(FUNCTIONAL_SPECS, identifier) do
            throw(ArgumentError("functional :$identifier is not implemented"))
        end
        mod = FUNCTIONAL_MODULES[identifier]
        dims = spin_dimensions(spec.family, n_spin)
        params = mod.DEFAULT_PARAMS
        new(
            identifier,
            n_spin,
            String(identifier),
            spec.kind,
            spec.family,
            spec.flags,
            [0, 1],
            spec.references,
            dims,
            params,
        )
    end
end

available_functionals() = collect(keys(FUNCTIONAL_SPECS))

supported_derivatives(f::Functional) = f.derivatives

is_lda(f::Functional)    = f.family in (:lda, :hyb_lda)
is_gga(f::Functional)    = f.family in (:gga, :hyb_gga)
is_mgga(f::Functional)   = f.family in (:mgga, :hyb_mgga)
is_hybrid(f::Functional) = f.family in (:hyb_gga, :hyb_lda, :hyb_mgga)
is_vv10(f::Functional)   = :vv10 in f.flags
is_range_separated(f::Functional) = any(s -> s in f.flags, (:hym_cam, :cam_omega, :cam_alpha, :cam_beta))
is_global_hybrid(f::Functional)   = :exx_coefficient in f.flags
needs_laplacian(f::Functional)    = :needs_laplacian in f.flags
needs_tau(f::Functional)          = :needs_tau in f.flags

function Base.getproperty(f::Functional, name::Symbol)
    if name == :density_threshold
        return getfield(f, :params).dens_threshold
    elseif name == :zeta_threshold
        return getfield(f, :params).zeta_threshold
    elseif name == :sigma_threshold
        return 1e-10  # placeholder matching upstream behavior
    elseif name == :tau_threshold
        return 1e-10
    elseif name == :exx_coefficient
        return nothing
    elseif name == :cam_omega
        return nothing
    elseif name == :cam_alpha
        return nothing
    elseif name == :cam_beta
        return nothing
    elseif name == :nlc_b
        return nothing
    elseif name == :nlc_C
        return nothing
    else
        return getfield(f, name)
    end
end

function Base.setproperty!(f::Functional, name::Symbol, value)
    if name == :density_threshold
        f.params = merge(f.params, (dens_threshold=Float64(value),))
    elseif name == :zeta_threshold
        f.params = merge(f.params, (zeta_threshold=Float64(value),))
    elseif name in (:sigma_threshold, :tau_threshold)
        # stored only for API compatibility; not forwarded to generated kernels
    else
        setfield!(f, name, value)
    end
end
