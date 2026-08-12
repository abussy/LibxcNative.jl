# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# ---------------------------------------------------------------------------
# GENERATED FILE - do not edit manually.
# Generated from upstream libxc SymPy sources (deps/libxc) by
#   python gen/generate_functional.py lda_xc_teter93
# ---------------------------------------------------------------------------

module lda_xc_teter93

const FAMILY = :lda

const DEFAULT_PARAMS = (; dens_threshold=1e-15, zeta_threshold=1e-15)

function zk(params, rho_up, rho_down)
    if rho_up + rho_down <= params.dens_threshold
        return zero(rho_up)
    end
    x0 = (cbrt(6) ^ 1)
    x1 = rho_down + rho_up
    x2 = x0 / ((cbrt(pi) ^ 1) * (cbrt(x1) ^ 1))
    x3 = 1 / x1
    x4 = x3 * (-rho_down + rho_up)
    x5 = (cbrt(params.zeta_threshold) ^ 4) - 1
    x6 = params.zeta_threshold - 1
    x7 = -x4
    x8 = ((1 - x4 <= params.zeta_threshold ? x5 : expm1((4 // 3) * log1p((x7 > x6 ? x7 : x6)))) + (x4 + 1 <= params.zeta_threshold ? x5 : expm1((4 // 3) * log1p((x4 > x6 ? x4 : x6))))) / (-2 + 2 * (cbrt(2) ^ 1))
    x9 = (3 // 4) * x3 / pi
    x10 = (cbrt(6) ^ 2) / (4 * (cbrt(pi) ^ 2) * (cbrt(x1) ^ 2))
    (-x10 * (0.1574201515892867 * x8 + 0.7405551735357053) - x2 * (0.6157402568883345 * x8 + 2.217058676663745) / 2 - 0.119086804055547 * x8 - x9 * (0.003532336663397157 * x8 + 0.01968227878617998) - 0.4581652932831429) / ((3 // 8) * x0 * (0.004200005045691381 * x8 + 0.02359291751427506) / ((cbrt(pi) ^ 4) * (cbrt(x1) ^ 4)) + x10 * (0.2673612973836267 * x8 + 4.504130959426697) + 0.5 * x2 + x9 * (0.2052004607777787 * x8 + 1.110667363742916))
end

function vrho_up(params, rho_up, rho_down)
    if rho_up + rho_down <= params.dens_threshold
        return zero(rho_up)
    end
    x0 = rho_down + rho_up
    x1 = (cbrt(6) ^ 1)
    x2 = (cbrt(pi) ^ -1)
    x3 = x1 * x2
    x4 = x3 / (cbrt(x0) ^ 1)
    x5 = 1 / (-2 + 2 * (cbrt(2) ^ 1))
    x6 = -rho_down + rho_up
    x7 = 1 / x0
    x8 = x6 * x7
    x9 = x8 + 1 <= params.zeta_threshold
    x10 = (cbrt(params.zeta_threshold) ^ 4) - 1
    x11 = params.zeta_threshold - 1
    x12 = x8 > x11
    x13 = (x12 ? x8 : x11)
    x14 = expm1((4 // 3) * log1p(x13))
    x15 = 1 - x8 <= params.zeta_threshold
    x16 = -x8
    x17 = x16 > x11
    x18 = (x17 ? x16 : x11)
    x19 = expm1((4 // 3) * log1p(x18))
    x20 = x5 * ((x15 ? x10 : x19) + (x9 ? x10 : x14))
    x21 = 0.2052004607777787 * x20 + 1.110667363742916
    x22 = 1 / pi
    x23 = x22 * x7
    x24 = x21 * x23
    x25 = (cbrt(x0) ^ -4)
    x26 = (cbrt(pi) ^ -4)
    x27 = x1 * x26 * (0.004200005045691381 * x20 + 0.02359291751427506)
    x28 = x25 * x27
    x29 = (cbrt(6) ^ 2)
    x30 = (cbrt(pi) ^ -2)
    x31 = x29 * x30
    x32 = x31 * (0.2673612973836267 * x20 + 4.504130959426697)
    x33 = (cbrt(x0) ^ -2)
    x34 = x33 / 4
    x35 = 1 / ((3 // 4) * x24 + (3 // 8) * x28 + x32 * x34 + 0.5 * x4)
    x36 = 0.003532336663397157 * x20 + 0.01968227878617998
    x37 = 0.6157402568883345 * x20 + 2.217058676663745
    x38 = 0.1574201515892867 * x20 + 0.7405551735357053
    x39 = -0.119086804055547 * x20 - 3 // 4 * x23 * x36 - x31 * x34 * x38 - x37 * x4 / 2 - 0.4581652932831429
    x40 = x0^(-2)
    x41 = (cbrt(x0) ^ -5)
    x42 = x40 * x6 - x7
    x43 = x5 * ((x15 ? 0.0 : (4 // 3) * (x19 + 1) * (x17 ? x42 : 0.0) / (x18 + 1)) + (x9 ? 0.0 : (4 // 3) * (x14 + 1) * (x12 ? -x42 : 0.0) / (x13 + 1)))
    x44 = x23 * x43
    x45 = x31 * x33 * x43
    x0 * x35 * (x1 * x2 * x25 * x37 / 6 + (3 // 4) * x22 * x36 * x40 + x29 * x30 * x38 * x41 / 6 - 0.3078701284441673 * x4 * x43 - 0.119086804055547 * x43 - 0.002649252497547868 * x44 - 0.03935503789732168 * x45) + (16 // 9) * x0 * x39 * (-0.001575001892134268 * x1 * x25 * x26 * x43 + (3 // 4) * x21 * x22 * x40 + 0.16666666666666667 * x25 * x3 + x32 * x41 / 6 - 0.153900345583334 * x44 - 0.06684032434590667 * x45 + x27 / (2 * (cbrt(x0) ^ 7))) / (x24 + x28 / 2 + x32 * x33 / 3 + 0.66666666666666667 * x4)^2 + x35 * x39
end

function vrho_down(params, rho_up, rho_down)
    if rho_up + rho_down <= params.dens_threshold
        return zero(rho_up)
    end
    x0 = rho_down + rho_up
    x1 = (cbrt(6) ^ 1)
    x2 = (cbrt(pi) ^ -1)
    x3 = x1 * x2
    x4 = x3 / (cbrt(x0) ^ 1)
    x5 = 1 / (-2 + 2 * (cbrt(2) ^ 1))
    x6 = -rho_down + rho_up
    x7 = 1 / x0
    x8 = x6 * x7
    x9 = x8 + 1 <= params.zeta_threshold
    x10 = (cbrt(params.zeta_threshold) ^ 4) - 1
    x11 = params.zeta_threshold - 1
    x12 = x8 > x11
    x13 = (x12 ? x8 : x11)
    x14 = expm1((4 // 3) * log1p(x13))
    x15 = 1 - x8 <= params.zeta_threshold
    x16 = -x8
    x17 = x16 > x11
    x18 = (x17 ? x16 : x11)
    x19 = expm1((4 // 3) * log1p(x18))
    x20 = x5 * ((x15 ? x10 : x19) + (x9 ? x10 : x14))
    x21 = 0.2052004607777787 * x20 + 1.110667363742916
    x22 = 1 / pi
    x23 = x22 * x7
    x24 = x21 * x23
    x25 = (cbrt(x0) ^ -4)
    x26 = (cbrt(pi) ^ -4)
    x27 = x1 * x26 * (0.004200005045691381 * x20 + 0.02359291751427506)
    x28 = x25 * x27
    x29 = (cbrt(6) ^ 2)
    x30 = (cbrt(pi) ^ -2)
    x31 = x29 * x30
    x32 = x31 * (0.2673612973836267 * x20 + 4.504130959426697)
    x33 = (cbrt(x0) ^ -2)
    x34 = x33 / 4
    x35 = 1 / ((3 // 4) * x24 + (3 // 8) * x28 + x32 * x34 + 0.5 * x4)
    x36 = 0.003532336663397157 * x20 + 0.01968227878617998
    x37 = 0.6157402568883345 * x20 + 2.217058676663745
    x38 = 0.1574201515892867 * x20 + 0.7405551735357053
    x39 = -0.119086804055547 * x20 - 3 // 4 * x23 * x36 - x31 * x34 * x38 - x37 * x4 / 2 - 0.4581652932831429
    x40 = x0^(-2)
    x41 = (cbrt(x0) ^ -5)
    x42 = x40 * x6 + x7
    x43 = x5 * ((x15 ? 0.0 : (4 // 3) * (x19 + 1) * (x17 ? x42 : 0.0) / (x18 + 1)) + (x9 ? 0.0 : (4 // 3) * (x14 + 1) * (x12 ? -x42 : 0.0) / (x13 + 1)))
    x44 = x23 * x43
    x45 = x31 * x33 * x43
    x0 * x35 * (x1 * x2 * x25 * x37 / 6 + (3 // 4) * x22 * x36 * x40 + x29 * x30 * x38 * x41 / 6 - 0.3078701284441673 * x4 * x43 - 0.119086804055547 * x43 - 0.002649252497547868 * x44 - 0.03935503789732168 * x45) + (16 // 9) * x0 * x39 * (-0.001575001892134268 * x1 * x25 * x26 * x43 + (3 // 4) * x21 * x22 * x40 + 0.16666666666666667 * x25 * x3 + x32 * x41 / 6 - 0.153900345583334 * x44 - 0.06684032434590667 * x45 + x27 / (2 * (cbrt(x0) ^ 7))) / (x24 + x28 / 2 + x32 * x33 / 3 + 0.66666666666666667 * x4)^2 + x35 * x39
end

function zk_unp(params, rho)
    if rho <= params.dens_threshold
        return zero(rho)
    end
    x0 = (cbrt(6) ^ 1)
    x1 = x0 / ((cbrt(pi) ^ 1) * (cbrt(rho) ^ 1))
    x2 = params.zeta_threshold - 1
    x3 = (1 <= params.zeta_threshold ? (cbrt(params.zeta_threshold) ^ 4) - 1 : expm1((4 // 3) * log1p((0 > x2 ? 0.0 : x2)))) / (-2 + 2 * (cbrt(2) ^ 1))
    x4 = (3 // 4) / (pi * rho)
    x5 = (cbrt(6) ^ 2) / (4 * (cbrt(pi) ^ 2) * (cbrt(rho) ^ 2))
    (-x1 * (1.231480513776669 * x3 + 2.217058676663745) / 2 - 0.238173608111094 * x3 - x4 * (0.007064673326794314 * x3 + 0.01968227878617998) - x5 * (0.3148403031785734 * x3 + 0.7405551735357053) - 0.4581652932831429) / (0.5 * x1 + x4 * (0.4104009215555574 * x3 + 1.110667363742916) + x5 * (0.5347225947672534 * x3 + 4.504130959426697) + (3 // 8) * x0 * (0.008400010091382762 * x3 + 0.02359291751427506) / ((cbrt(pi) ^ 4) * (cbrt(rho) ^ 4)))
end

function vrho_unp(params, rho)
    if rho <= params.dens_threshold
        return zero(rho)
    end
    x0 = params.zeta_threshold - 1
    x1 = (1 <= params.zeta_threshold ? (cbrt(params.zeta_threshold) ^ 4) - 1 : expm1((4 // 3) * log1p((0 > x0 ? 0.0 : x0)))) / (-2 + 2 * (cbrt(2) ^ 1))
    x2 = 0.005298504995095736 * x1 + 0.01476170908963499
    x3 = 1 / pi
    x4 = x3 / rho^2
    x5 = 1.231480513776669 * x1 + 2.217058676663745
    x6 = (cbrt(rho) ^ -4)
    x7 = (cbrt(6) ^ 1)
    x8 = x7 / (cbrt(pi) ^ 1)
    x9 = x6 * x8
    x10 = (cbrt(6) ^ 2) / (cbrt(pi) ^ 2)
    x11 = x10 * (0.3148403031785734 * x1 + 0.7405551735357053)
    x12 = 1 / (6 * (cbrt(rho) ^ 5))
    x13 = x8 / (cbrt(rho) ^ 1)
    x14 = 0.4104009215555574 * x1 + 1.110667363742916
    x15 = x3 / rho
    x16 = x14 * x15
    x17 = x7 * (0.008400010091382762 * x1 + 0.02359291751427506) / (cbrt(pi) ^ 4)
    x18 = x17 * x6
    x19 = x10 * (0.5347225947672534 * x1 + 4.504130959426697)
    x20 = (cbrt(rho) ^ -2)
    x21 = x20 / 4
    x22 = 1 / (0.5 * x13 + (3 // 4) * x16 + (3 // 8) * x18 + x19 * x21)
    x23 = -0.238173608111094 * x1 - x11 * x21 - x13 * x5 / 2 - x15 * x2 - 0.4581652932831429
    rho * x22 * (x11 * x12 + x2 * x4 + x5 * x9 / 6) + (16 // 9) * rho * x23 * (x12 * x19 + (3 // 4) * x14 * x4 + 0.16666666666666667 * x9 + x17 / (2 * (cbrt(rho) ^ 7))) / (0.66666666666666667 * x13 + x16 + x18 / 2 + x19 * x20 / 3)^2 + x22 * x23
end


end # module