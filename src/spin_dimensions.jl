# Spin dimensions for the implemented families.
# Values mirror the upstream xc_dimensions struct for collinear spins.

struct SpinDimensions
    rho::Int
    sigma::Int
    lapl::Int
    tau::Int
    zk::Int
    vrho::Int
    vsigma::Int
    vlapl::Int
    vtau::Int
end

function spin_dimensions(family::Symbol, n_spin::Int)
    n_spin in (1, 2) || throw(ArgumentError("n_spin must be 1 or 2"))
    if family == :lda
        return SpinDimensions(
            n_spin, 0, 0, 0,
            1, n_spin, 0, 0, 0,
        )
    elseif family == :gga
        n_sigma = n_spin == 1 ? 1 : 3
        return SpinDimensions(
            n_spin, n_sigma, 0, 0,
            1, n_spin, n_sigma, 0, 0,
        )
    elseif family == :mgga
        n_sigma = n_spin == 1 ? 1 : 3
        return SpinDimensions(
            n_spin, n_sigma, n_spin, n_spin,
            1, n_spin, n_sigma, n_spin, n_spin,
        )
    else
        throw(ArgumentError("unknown family: $family"))
    end
end
