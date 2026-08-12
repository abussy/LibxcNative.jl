mutable struct Functional{ID, P<:NamedTuple}
    identifier::Symbol
    n_spin::Int
    name::String
    kind::Symbol
    family::Symbol
    flags::Vector{Symbol}
    derivatives::Vector{Int}
    references::Vector{@NamedTuple{reference::String, doi::String, bibtex::String, key::String}}
    spin_dimensions::SpinDimensions
    params::P

    function Functional(identifier::Symbol; n_spin::Integer=1)
        n_spin = Int(n_spin)
        n_spin in (1, 2) || throw(ArgumentError("n_spin must be 1 or 2"))
        spec = get(FUNCTIONAL_SPECS, identifier) do
            throw(ArgumentError("functional :$identifier is not implemented"))
        end
        mod = FUNCTIONAL_MODULES[identifier]
        dims = spin_dimensions(spec.family, n_spin)
        params = mod.DEFAULT_PARAMS
        derivatives = _derivatives_from_flags(spec.flags)
        new{identifier, typeof(params)}(
            identifier,
            n_spin,
            String(identifier),
            spec.kind,
            spec.family,
            spec.flags,
            derivatives,
            spec.references,
            dims,
            params,
        )
    end
end

available_functionals() = collect(keys(FUNCTIONAL_SPECS))

function _derivatives_from_flags(flags::Vector{Symbol})
    derivs = Int[]
    :exc in flags && push!(derivs, 0)
    :vxc in flags && push!(derivs, 1)
    return derivs
end

supported_derivatives(f::Functional{ID,P}) where {ID,P} = f.derivatives

is_lda(f::Functional{ID,P})    where {ID,P} = f.family in (:lda, :hyb_lda)
is_gga(f::Functional{ID,P})    where {ID,P} = f.family in (:gga, :hyb_gga)
is_mgga(f::Functional{ID,P})   where {ID,P} = f.family in (:mgga, :hyb_mgga)
is_hybrid(f::Functional{ID,P}) where {ID,P} = f.family in (:hyb_gga, :hyb_lda, :hyb_mgga)
is_vv10(f::Functional{ID,P})   where {ID,P} = :vv10 in f.flags
is_range_separated(f::Functional{ID,P}) where {ID,P} = any(s -> s in f.flags, (:hym_cam, :cam_omega, :cam_alpha, :cam_beta))
is_global_hybrid(f::Functional{ID,P})   where {ID,P} = :exx_coefficient in f.flags
needs_laplacian(f::Functional{ID,P})    where {ID,P} = :needs_laplacian in f.flags
needs_tau(f::Functional{ID,P})          where {ID,P} = :needs_tau in f.flags

function Base.getproperty(f::Functional{ID,P}, name::Symbol) where {ID,P}
    if name == :density_threshold
        return getfield(f, :params).dens_threshold
    elseif name == :zeta_threshold
        return getfield(f, :params).zeta_threshold
    elseif name == :sigma_threshold
        return 1e-10  # API stub: not forwarded to generated kernels
    elseif name == :tau_threshold
        return 1e-10  # API stub: not forwarded to generated kernels
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

function Base.setproperty!(f::Functional{ID,P}, name::Symbol, value) where {ID,P}
    if name == :density_threshold
        f.params = merge(f.params, (dens_threshold=Float64(value),))
    elseif name == :zeta_threshold
        f.params = merge(f.params, (zeta_threshold=Float64(value),))
    elseif name in (:sigma_threshold, :tau_threshold)
        # API stub: silently ignored; generated kernels do not use these thresholds
    else
        setfield!(f, name, value)
    end
end

# ---------------------------------------------------------------------------
# Typed kernel getters.  These turn the functional identifier (known at
# compile time for a concrete Functional{ID,P}) into a direct reference to the
# generated scalar kernel, avoiding dynamic dispatch inside the per-point loops.
#
# When a kernel is not implemented (e.g. vlapl for a functional that does not
# need the laplacian), get_kernel returns a MissingKernel singleton instead of
# throwing.  This is isbits, so it is safe to capture in GPU kernels; the
# MissingKernel is never actually called because the corresponding output is
# nothing and the if-guard around the map! is skipped.
# ---------------------------------------------------------------------------

struct MissingKernel end
(::MissingKernel)(args...) = error("kernel not implemented for this functional")

@generated function get_kernel(::Functional{ID,P}, ::Val{out}) where {ID, P, out}
    mod = FUNCTIONAL_MODULES[ID]
    try
        f = getfield(mod, out)
        return :($f)
    catch
        return :(MissingKernel())
    end
end
