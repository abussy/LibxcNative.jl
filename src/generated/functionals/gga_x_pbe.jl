# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# ---------------------------------------------------------------------------
# GENERATED FILE - do not edit manually.
# Generated from upstream libxc SymPy sources (deps/libxc) by
#   python gen/generate_functional.py gga_x_pbe
# ---------------------------------------------------------------------------

module gga_x_pbe

const FAMILY = :gga

const DEFAULT_PARAMS = (; dens_threshold=1e-15, zeta_threshold=1e-15)

function zk(params, rho_up, rho_down, sigma_aa, sigma_ab, sigma_bb)
    if rho_up + rho_down <= params.dens_threshold
        return zero(rho_up)
    end
    x0 = rho_down + rho_up
    x1 = (-rho_down + rho_up) / x0
    x2 = x1 + 1
    x3 = x0 / 2
    x4 = (cbrt(6) ^ 1) / (cbrt(pi) ^ 4)
    x5 = 0.009146457198521546 * x4
    x6 = sigma_aa / (cbrt(rho_up) ^ 8)
    x7 = 0.007353751587611323 * x4
    x8 = x2 <= params.zeta_threshold
    x9 = params.zeta_threshold - 1
    x10 = 1 - x1
    x11 = x10 <= params.zeta_threshold
    x12 = -x9
    x13 = (x8 ? x9 : (x11 ? x12 : x1)) + 1
    x14 = (cbrt(params.zeta_threshold) ^ 4)
    x15 = 0.369279383191011 * (cbrt(x0) ^ 1)
    x16 = sigma_bb / (cbrt(rho_down) ^ 8)
    x17 = (x11 ? x9 : (x8 ? x12 : -x1)) + 1
    (x10 * x3 <= params.dens_threshold ? 0.0 : -x15 * (x16 * x7 / (x16 * x5 + 0.804) + 1) * (x17 <= params.zeta_threshold ? x14 : (cbrt(x17) ^ 4))) + (x2 * x3 <= params.dens_threshold ? 0.0 : -x15 * (x6 * x7 / (x5 * x6 + 0.804) + 1) * (x13 <= params.zeta_threshold ? x14 : (cbrt(x13) ^ 4)))
end

function vrho_up(params, rho_up, rho_down, sigma_aa, sigma_ab, sigma_bb)
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
    x7 = (cbrt(6) ^ 1) / (cbrt(pi) ^ 4)
    x8 = 0.009146457198521546 * x7
    x9 = sigma_aa / (cbrt(rho_up) ^ 8)
    x10 = 1 / (x8 * x9 + 0.804)
    x11 = x7 * x9
    x12 = 0.007353751587611323 * x10 * x11 + 1
    x13 = x4 <= params.zeta_threshold
    x14 = params.zeta_threshold - 1
    x15 = 1 - x3
    x16 = x15 <= params.zeta_threshold
    x17 = -x14
    x18 = (x13 ? x14 : (x16 ? x17 : x3)) + 1
    x19 = x18 <= params.zeta_threshold
    x20 = (cbrt(params.zeta_threshold) ^ 4)
    x21 = (x19 ? x20 : (cbrt(x18) ^ 4))
    x22 = x12 * x21
    x23 = 0.369279383191011 * (cbrt(x1) ^ 1)
    x24 = x15 * x5 <= params.dens_threshold
    x25 = sigma_bb / (cbrt(rho_down) ^ 8)
    x26 = 0.007353751587611323 * x25 * x7 / (x25 * x8 + 0.804) + 1
    x27 = (x16 ? x14 : (x13 ? x17 : -x3)) + 1
    x28 = x27 <= params.zeta_threshold
    x29 = x26 * (x28 ? x20 : (cbrt(x27) ^ 4))
    x30 = 0.123093127730337 / (cbrt(x1) ^ 2)
    x31 = x0 / x1^2 - x2
    x1 * ((x24 ? 0.0 : -x23 * x26 * (x28 ? 0.0 : (4 // 3) * (cbrt(x27) ^ 1) * (x16 ? 0.0 : (x13 ? 0.0 : x31))) - x29 * x30) + (x6 ? 0.0 : -x12 * x23 * (x19 ? 0.0 : (4 // 3) * (cbrt(x18) ^ 1) * (x13 ? 0.0 : (x16 ? 0.0 : -x31))) - x21 * x23 * (-0.0196100042336302 * sigma_aa * x10 * x7 / (cbrt(rho_up) ^ 11) + 0.0002774715730825426 * (cbrt(6) ^ 2) * sigma_aa^2 / ((cbrt(pi) ^ 8) * (cbrt(rho_up) ^ 19) * (0.01137619054542481 * x11 + 1)^2)) - x22 * x30)) + (x24 ? 0.0 : -x23 * x29) + (x6 ? 0.0 : -x22 * x23)
end

function vrho_down(params, rho_up, rho_down, sigma_aa, sigma_ab, sigma_bb)
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
    x7 = (cbrt(6) ^ 1) / (cbrt(pi) ^ 4)
    x8 = 0.009146457198521546 * x7
    x9 = sigma_aa / (cbrt(rho_up) ^ 8)
    x10 = 0.007353751587611323 * x7 * x9 / (x8 * x9 + 0.804) + 1
    x11 = x4 <= params.zeta_threshold
    x12 = params.zeta_threshold - 1
    x13 = 1 - x3
    x14 = x13 <= params.zeta_threshold
    x15 = -x12
    x16 = (x11 ? x12 : (x14 ? x15 : x3)) + 1
    x17 = x16 <= params.zeta_threshold
    x18 = (cbrt(params.zeta_threshold) ^ 4)
    x19 = x10 * (x17 ? x18 : (cbrt(x16) ^ 4))
    x20 = 0.369279383191011 * (cbrt(x1) ^ 1)
    x21 = x13 * x5 <= params.dens_threshold
    x22 = sigma_bb / (cbrt(rho_down) ^ 8)
    x23 = 1 / (x22 * x8 + 0.804)
    x24 = x22 * x7
    x25 = 0.007353751587611323 * x23 * x24 + 1
    x26 = (x14 ? x12 : (x11 ? x15 : -x3)) + 1
    x27 = x26 <= params.zeta_threshold
    x28 = (x27 ? x18 : (cbrt(x26) ^ 4))
    x29 = x25 * x28
    x30 = 0.123093127730337 / (cbrt(x1) ^ 2)
    x31 = x0 / x1^2 + x2
    x1 * ((x21 ? 0.0 : -x20 * x25 * (x27 ? 0.0 : (4 // 3) * (cbrt(x26) ^ 1) * (x14 ? 0.0 : (x11 ? 0.0 : x31))) - x20 * x28 * (-0.0196100042336302 * sigma_bb * x23 * x7 / (cbrt(rho_down) ^ 11) + 0.0002774715730825426 * (cbrt(6) ^ 2) * sigma_bb^2 / ((cbrt(pi) ^ 8) * (cbrt(rho_down) ^ 19) * (0.01137619054542481 * x24 + 1)^2)) - x29 * x30) + (x6 ? 0.0 : -x10 * x20 * (x17 ? 0.0 : (4 // 3) * (cbrt(x16) ^ 1) * (x11 ? 0.0 : (x14 ? 0.0 : -x31))) - x19 * x30)) + (x21 ? 0.0 : -x20 * x29) + (x6 ? 0.0 : -x19 * x20)
end

function vsigma_aa(params, rho_up, rho_down, sigma_aa, sigma_ab, sigma_bb)
    if rho_up + rho_down <= params.dens_threshold
        return zero(rho_up)
    end
    x0 = rho_down + rho_up
    x1 = (-rho_down + rho_up) / x0
    x2 = x1 + 1
    x3 = (cbrt(6) ^ 1) / ((cbrt(pi) ^ 4) * (cbrt(rho_up) ^ 8))
    x4 = sigma_aa * x3
    x5 = params.zeta_threshold - 1
    x6 = (x2 <= params.zeta_threshold ? x5 : (1 - x1 <= params.zeta_threshold ? -x5 : x1)) + 1
    x0 * (x0 * x2 / 2 <= params.dens_threshold ? 0.0 : -0.369279383191011 * (cbrt(x0) ^ 1) * (0.007353751587611323 * x3 / (0.009146457198521546 * x4 + 0.804) - 0.0001040518399059535 * (cbrt(6) ^ 2) * sigma_aa / ((cbrt(pi) ^ 8) * (cbrt(rho_up) ^ 16) * (0.01137619054542481 * x4 + 1)^2)) * (x6 <= params.zeta_threshold ? (cbrt(params.zeta_threshold) ^ 4) : (cbrt(x6) ^ 4)))
end

function vsigma_ab(params, rho_up, rho_down, sigma_aa, sigma_ab, sigma_bb)
    if rho_up + rho_down <= params.dens_threshold
        return zero(rho_up)
    end
    zero(rho_up)
end

function vsigma_bb(params, rho_up, rho_down, sigma_aa, sigma_ab, sigma_bb)
    if rho_up + rho_down <= params.dens_threshold
        return zero(rho_up)
    end
    x0 = rho_down + rho_up
    x1 = (-rho_down + rho_up) / x0
    x2 = 1 - x1
    x3 = (cbrt(6) ^ 1) / ((cbrt(pi) ^ 4) * (cbrt(rho_down) ^ 8))
    x4 = sigma_bb * x3
    x5 = params.zeta_threshold - 1
    x6 = (x2 <= params.zeta_threshold ? x5 : (x1 + 1 <= params.zeta_threshold ? -x5 : -x1)) + 1
    x0 * (x0 * x2 / 2 <= params.dens_threshold ? 0.0 : -0.369279383191011 * (cbrt(x0) ^ 1) * (0.007353751587611323 * x3 / (0.009146457198521546 * x4 + 0.804) - 0.0001040518399059535 * (cbrt(6) ^ 2) * sigma_bb / ((cbrt(pi) ^ 8) * (cbrt(rho_down) ^ 16) * (0.01137619054542481 * x4 + 1)^2)) * (x6 <= params.zeta_threshold ? (cbrt(params.zeta_threshold) ^ 4) : (cbrt(x6) ^ 4)))
end

function zk_unp(params, rho, sigma)
    if rho <= params.dens_threshold
        return zero(rho)
    end
    x0 = (cbrt(3) ^ 1) * sigma / ((cbrt(pi) ^ 4) * (cbrt(rho) ^ 8))
    x1 = 1 <= params.zeta_threshold
    x2 = params.zeta_threshold - 1
    x3 = (x1 ? x2 : (x1 ? -x2 : 0.0)) + 1
    2 * (rho / 2 <= params.dens_threshold ? 0.0 : -0.369279383191011 * (cbrt(rho) ^ 1) * (0.01470750317522265 * x0 / (0.01829291439704309 * x0 + 0.804) + 1) * (x3 <= params.zeta_threshold ? (cbrt(params.zeta_threshold) ^ 4) : (cbrt(x3) ^ 4)))
end

function vrho_unp(params, rho, sigma)
    if rho <= params.dens_threshold
        return zero(rho)
    end
    x0 = rho / 2 <= params.dens_threshold
    x1 = (cbrt(3) ^ 1) * sigma / (cbrt(pi) ^ 4)
    x2 = x1 / (cbrt(rho) ^ 8)
    x3 = 1 / (0.01829291439704309 * x2 + 0.804)
    x4 = 1 <= params.zeta_threshold
    x5 = params.zeta_threshold - 1
    x6 = (x4 ? x5 : (x4 ? -x5 : 0.0)) + 1
    x7 = (x6 <= params.zeta_threshold ? (cbrt(params.zeta_threshold) ^ 4) : (cbrt(x6) ^ 4))
    x8 = x7 * (0.01470750317522265 * x2 * x3 + 1)
    x9 = 0.369279383191011 * (cbrt(rho) ^ 1)
    2 * rho * (x0 ? 0.0 : -x7 * x9 * (-0.03922000846726039 * x1 * x3 / (cbrt(rho) ^ 11) + 0.00110988629233017 * (cbrt(3) ^ 2) * sigma^2 / ((cbrt(pi) ^ 8) * (cbrt(rho) ^ 19) * (0.02275238109084962 * x2 + 1)^2)) - 0.123093127730337 * x8 / (cbrt(rho) ^ 2)) + 2 * (x0 ? 0.0 : -x8 * x9)
end

function vsigma_unp(params, rho, sigma)
    if rho <= params.dens_threshold
        return zero(rho)
    end
    x0 = 1 <= params.zeta_threshold
    x1 = params.zeta_threshold - 1
    x2 = (x0 ? x1 : (x0 ? -x1 : 0.0)) + 1
    x3 = (cbrt(3) ^ 1) / ((cbrt(pi) ^ 4) * (cbrt(rho) ^ 8))
    x4 = sigma * x3
    2 * rho * (rho / 2 <= params.dens_threshold ? 0.0 : -0.369279383191011 * (cbrt(rho) ^ 1) * (0.01470750317522265 * x3 / (0.01829291439704309 * x4 + 0.804) - 0.0004162073596238139 * (cbrt(3) ^ 2) * sigma / ((cbrt(pi) ^ 8) * (cbrt(rho) ^ 16) * (0.02275238109084962 * x4 + 1)^2)) * (x2 <= params.zeta_threshold ? (cbrt(params.zeta_threshold) ^ 4) : (cbrt(x2) ^ 4)))
end


end # module