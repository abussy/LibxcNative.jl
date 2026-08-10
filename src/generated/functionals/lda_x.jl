# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# ---------------------------------------------------------------------------
# GENERATED FILE - do not edit manually.
# Generated from upstream libxc SymPy sources (deps/libxc) by
#   python gen/generate_functional.py lda_x
# ---------------------------------------------------------------------------

module lda_x

using Base: ifelse

const FAMILY = :lda

const DEFAULT_PARAMS = (; dens_threshold=1e-15, zeta_threshold=1e-15)

function zk(params, rho_up, rho_down)
    if rho_up + rho_down <= params.dens_threshold
        return zero(rho_up)
    end
    x0 = rho_down + rho_up
    x1 = (-rho_down + rho_up) / x0
    x2 = x1 + 1
    x3 = x0 / 2
    x4 = (cbrt(params.zeta_threshold) ^ 4)
    x5 = 0.369279383191011 * (cbrt(x0) ^ 1)
    x6 = 1 - x1
    (x2 * x3 <= params.dens_threshold ? 0.0 : -x5 * (x2 <= params.zeta_threshold ? x4 : (cbrt(x2) ^ 4))) + (x3 * x6 <= params.dens_threshold ? 0.0 : -x5 * (x6 <= params.zeta_threshold ? x4 : (cbrt(x6) ^ 4)))
end

function vrho_up(params, rho_up, rho_down)
    if rho_up + rho_down <= params.dens_threshold
        return zero(rho_up)
    end
    x0 = -rho_down + rho_up
    x1 = rho_down + rho_up
    x2 = 1 / x1
    x3 = x0 * x2
    x4 = x3 + 1
    x5 = x1 / 2
    x6 = x4 * x5 <= params.dens_threshold
    x7 = x4 <= params.zeta_threshold
    x8 = (cbrt(params.zeta_threshold) ^ 4)
    x9 = (x7 ? x8 : (cbrt(x4) ^ 4))
    x10 = 0.369279383191011 * (cbrt(x1) ^ 1)
    x11 = 1 - x3
    x12 = x11 * x5 <= params.dens_threshold
    x13 = x11 <= params.zeta_threshold
    x14 = (x13 ? x8 : (cbrt(x11) ^ 4))
    x15 = 0.123093127730337 / (cbrt(x1) ^ 2)
    x16 = (4 // 3) * x0 / x1^2 - 4 // 3 * x2
    x1 * ((x12 ? 0.0 : -x10 * (x13 ? 0.0 : (cbrt(x11) ^ 1) * x16) - x14 * x15) + (x6 ? 0.0 : -x10 * (x7 ? 0.0 : -x16 * (cbrt(x4) ^ 1)) - x15 * x9)) + (x12 ? 0.0 : -x10 * x14) + (x6 ? 0.0 : -x10 * x9)
end

function vrho_down(params, rho_up, rho_down)
    if rho_up + rho_down <= params.dens_threshold
        return zero(rho_up)
    end
    x0 = -rho_down + rho_up
    x1 = rho_down + rho_up
    x2 = 1 / x1
    x3 = x0 * x2
    x4 = x3 + 1
    x5 = x1 / 2
    x6 = x4 * x5 <= params.dens_threshold
    x7 = x4 <= params.zeta_threshold
    x8 = (cbrt(params.zeta_threshold) ^ 4)
    x9 = (x7 ? x8 : (cbrt(x4) ^ 4))
    x10 = 0.369279383191011 * (cbrt(x1) ^ 1)
    x11 = 1 - x3
    x12 = x11 * x5 <= params.dens_threshold
    x13 = x11 <= params.zeta_threshold
    x14 = (x13 ? x8 : (cbrt(x11) ^ 4))
    x15 = 0.123093127730337 / (cbrt(x1) ^ 2)
    x16 = (4 // 3) * x0 / x1^2 + (4 // 3) * x2
    x1 * ((x12 ? 0.0 : -x10 * (x13 ? 0.0 : (cbrt(x11) ^ 1) * x16) - x14 * x15) + (x6 ? 0.0 : -x10 * (x7 ? 0.0 : -x16 * (cbrt(x4) ^ 1)) - x15 * x9)) + (x12 ? 0.0 : -x10 * x14) + (x6 ? 0.0 : -x10 * x9)
end

function zk_unp(params, rho)
    if rho <= params.dens_threshold
        return zero(rho)
    end
    2 * (rho / 2 <= params.dens_threshold ? 0.0 : -0.369279383191011 * (cbrt(rho) ^ 1) * (1 <= params.zeta_threshold ? (cbrt(params.zeta_threshold) ^ 4) : 1))
end

function vrho_unp(params, rho)
    if rho <= params.dens_threshold
        return zero(rho)
    end
    x0 = rho / 2 <= params.dens_threshold
    x1 = (1 <= params.zeta_threshold ? (cbrt(params.zeta_threshold) ^ 4) : 1)
    2 * rho * (x0 ? 0.0 : -0.123093127730337 * x1 / (cbrt(rho) ^ 2)) + 2 * (x0 ? 0.0 : -0.369279383191011 * (cbrt(rho) ^ 1) * x1)
end


end # module