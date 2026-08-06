function evaluate(func::Functional;
                  derivatives::AbstractArray = 0:1,
                  rho::AbstractArray,
                  sigma::Union{AbstractArray,Nothing} = nothing,
                  lapl::Union{AbstractArray,Nothing} = nothing,
                  tau::Union{AbstractArray,Nothing} = nothing,
                  zk = nothing,
                  vrho = nothing,
                  vsigma = nothing,
                  vlapl = nothing,
                  vtau = nothing,
                  kwargs...)
    output_names = _requested_outputs(func, derivatives)
    shape = _grid_shape(func, rho)

    outputs = _collect_outputs(output_names, zk, vrho, vsigma, vlapl, vtau,
                               func.spin_dimensions, shape, rho)

    evaluate!(func; rho=rho, sigma=sigma, lapl=lapl, tau=tau,
              derivatives=derivatives, outputs...)

    return _build_output(output_names, outputs.zk, outputs.vrho, outputs.vsigma,
                         outputs.vlapl, outputs.vtau)
end

function evaluate!(func::Functional;
                   rho::AbstractArray,
                   sigma::Union{AbstractArray,Nothing} = nothing,
                   lapl::Union{AbstractArray,Nothing} = nothing,
                   tau::Union{AbstractArray,Nothing} = nothing,
                   derivatives::AbstractArray = 0:1,
                   zk = nothing,
                   vrho = nothing,
                   vsigma = nothing,
                   vlapl = nothing,
                   vtau = nothing,
                   kwargs...)
    mod = FUNCTIONAL_MODULES[func.identifier]
    family = func.family

    _validate_inputs(family, sigma, lapl, tau)

    output_names = _requested_outputs(func, derivatives)
    shape = _grid_shape(func, rho)

    outputs = _collect_outputs(output_names, zk, vrho, vsigma, vlapl, vtau,
                               func.spin_dimensions, shape, rho)

    rho2   = _normalize_rho(rho, func.n_spin)
    sigma2 = sigma !== nothing ? _normalize_sigma(sigma, func.n_spin) : nothing
    lapl2  = lapl  !== nothing ? _normalize_lapl(lapl, func.n_spin)    : nothing
    tau2   = tau   !== nothing ? _normalize_tau(tau, func.n_spin)      : nothing

    if family == :lda
        evaluate_lda!(mod, func.params, func.n_spin, rho2, outputs.zk, outputs.vrho)
    elseif family == :gga
        evaluate_gga!(mod, func.params, func.n_spin, rho2, sigma2,
                      outputs.zk, outputs.vrho, outputs.vsigma)
    elseif family == :mgga
        evaluate_mgga!(mod, func.params, func.n_spin, rho2, sigma2, lapl2, tau2,
                       outputs.zk, outputs.vrho, outputs.vsigma,
                       outputs.vlapl, outputs.vtau)
    else
        throw(ArgumentError("family $family not implemented"))
    end

    return nothing
end

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

function _grid_shape(func::Functional, rho::AbstractArray)
    if func.n_spin == 1
        if ndims(rho) == 1
            return (length(rho),)
        else
            return size(rho)[2:end]
        end
    else
        if ndims(rho) == 1
            return (length(rho) ÷ 2,)
        else
            return size(rho)[2:end]
        end
    end
end

function _output_size(name::Symbol, dims::SpinDimensions, shape::Tuple)
    d = _dim_for_field(name, dims)
    if d == 0 || d == 1
        return shape
    else
        return (d, shape...)
    end
end

function _collect_outputs(output_names, zk, vrho, vsigma, vlapl, vtau,
                          dims::SpinDimensions, shape::Tuple, prototype::AbstractArray)
    return (
        zk   = :zk   in output_names ? _prepare_output(zk,   :zk,   dims, shape, prototype) : nothing,
        vrho = :vrho in output_names ? _prepare_output(vrho, :vrho, dims, shape, prototype) : nothing,
        vsigma = :vsigma in output_names ? _prepare_output(vsigma, :vsigma, dims, shape, prototype) : nothing,
        vlapl  = :vlapl  in output_names ? _prepare_output(vlapl,  :vlapl,  dims, shape, prototype) : nothing,
        vtau   = :vtau   in output_names ? _prepare_output(vtau,   :vtau,   dims, shape, prototype) : nothing,
    )
end

function _prepare_output(arr, name::Symbol, dims::SpinDimensions, shape::Tuple, prototype::AbstractArray)
    if arr === nothing
        return similar(prototype, Float64, _output_size(name, dims, shape))
    end
    return arr
end

function _dim_for_field(name::Symbol, dims::SpinDimensions)
    name == :zk && return dims.zk
    name == :vrho && return dims.vrho
    name == :vsigma && return dims.vsigma
    name == :vlapl && return dims.vlapl
    name == :vtau && return dims.vtau
    return 0
end

function _requested_outputs(func::Functional, derivatives::AbstractArray)
    derivs = sort!(collect(derivatives))
    names = Symbol[]
    for d in derivs
        if d == 0
            push!(names, :zk)
        elseif d == 1
            push!(names, :vrho)
            if is_gga(func) || is_mgga(func)
                push!(names, :vsigma)
            end
            if is_mgga(func) && needs_laplacian(func)
                push!(names, :vlapl)
            end
            if is_mgga(func) && needs_tau(func)
                push!(names, :vtau)
            end
        else
            throw(ArgumentError("derivative order $d not supported"))
        end
    end
    return names
end

function _build_output(names, zk, vrho, vsigma, vlapl, vtau)
    pairs = Pair{Symbol, Any}[]
    for n in names
        if n == :zk
            push!(pairs, :zk => zk)
        elseif n == :vrho
            push!(pairs, :vrho => vrho)
        elseif n == :vsigma
            push!(pairs, :vsigma => vsigma)
        elseif n == :vlapl
            push!(pairs, :vlapl => vlapl)
        elseif n == :vtau
            push!(pairs, :vtau => vtau)
        end
    end
    return NamedTuple(pairs)
end

function _validate_inputs(family, sigma, lapl, tau)
    if family in (:gga, :mgga) && sigma === nothing
        throw(ArgumentError("sigma is required for GGA and meta-GGA functionals"))
    end
    if family == :mgga && tau === nothing
        # Some mGGAs need lapl instead; our current set needs tau.
        throw(ArgumentError("tau is required for meta-GGA functionals"))
    end
end

function _normalize_rho(rho::AbstractArray, n_spin::Int)
    if ndims(rho) == 1
        n = length(rho)
        if n_spin == 1
            return reshape(rho, 1, n)
        else
            iseven(n) || throw(ArgumentError("rho length must be even for n_spin=2"))
            return reshape(rho, 2, n ÷ 2)
        end
    end
    d = size(rho, 1)
    d == n_spin || throw(ArgumentError("first dimension of rho must be $n_spin"))
    return reshape(rho, d, :)
end

function _normalize_sigma(sigma::AbstractArray, n_spin::Int)
    if ndims(sigma) == 1
        n = length(sigma)
        if n_spin == 1
            return reshape(sigma, 1, n)
        else
            mod(n, 3) == 0 || throw(ArgumentError("sigma length must be a multiple of 3 for n_spin=2"))
            return reshape(sigma, 3, n ÷ 3)
        end
    end
    d = size(sigma, 1)
    expected = n_spin == 1 ? 1 : 3
    d == expected || throw(ArgumentError("first dimension of sigma must be $expected"))
    return reshape(sigma, d, :)
end

function _normalize_lapl(lapl::AbstractArray, n_spin::Int)
    if ndims(lapl) == 1
        n = length(lapl)
        if n_spin == 1
            return reshape(lapl, 1, n)
        else
            iseven(n) || throw(ArgumentError("lapl length must be even for n_spin=2"))
            return reshape(lapl, 2, n ÷ 2)
        end
    end
    d = size(lapl, 1)
    d == n_spin || throw(ArgumentError("first dimension of lapl must be $n_spin"))
    return reshape(lapl, d, :)
end

function _normalize_tau(tau::AbstractArray, n_spin::Int)
    if ndims(tau) == 1
        n = length(tau)
        if n_spin == 1
            return reshape(tau, 1, n)
        else
            iseven(n) || throw(ArgumentError("tau length must be even for n_spin=2"))
            return reshape(tau, 2, n ÷ 2)
        end
    end
    d = size(tau, 1)
    d == n_spin || throw(ArgumentError("first dimension of tau must be $n_spin"))
    return reshape(tau, d, :)
end
