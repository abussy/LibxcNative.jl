# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# ---------------------------------------------------------------------------
# GENERATED FILE - do not edit manually.
# Generated from upstream libxc SymPy sources (deps/libxc) by
#   python gen/generate_functional.py mgga_x_scan
# ---------------------------------------------------------------------------

module mgga_x_scan

const FAMILY = :mgga

const DEFAULT_PARAMS = (; dens_threshold=1e-15, zeta_threshold=1e-15)

function zk(params, rho_up, rho_down, sigma_aa, sigma_ab, sigma_bb, tau_up, tau_down)
    if rho_up + rho_down <= params.dens_threshold
        return zero(rho_up)
    end
    x0 = rho_down + rho_up
    x1 = (-rho_down + rho_up) / x0
    x2 = x1 + 1
    x3 = x0 / 2
    x4 = sigma_aa / (cbrt(rho_up) ^ 8)
    x5 = (cbrt(pi) ^ -4)
    x6 = (cbrt(6) ^ 1) * x5
    x7 = (5 // 9) * x6
    x8 = x7 * (-x4 / 8 + tau_up / (cbrt(rho_up) ^ 5))
    x9 = (0.981830887265065 > x8 ? x8 : 0.981830887265065)
    x10 = (x8 <= 1 ? (x8 > 0.981830887265065 ? 0.0 : exp(-0.667 * x9 / (1 - x9))) : (x8 < 1.02206363082423 ? 0.0 : -1.24 * exp(0.8 / (1 - (1.02206363082423 > x8 ? 1.02206363082423 : x8)))))
    x11 = x4 * x6
    x12 = 0.000211513038552076 * (cbrt(6) ^ 2) / (cbrt(pi) ^ 8)
    x13 = (7 // 12960) * 2 ^ (5 // 6) * (cbrt(3) ^ 1) * (sqrt(73) ^ 1) * x5
    x14 = 1 - x8
    x15 = (sqrt(146) ^ 1) / 100
    x16 = (5 // 972) * x11 + (x13 * x4 + x14 * x15 * exp(-x14^2 / 2))^2 + sigma_aa^2 * x12 * exp(-0.0411181346945236 * x11) / (cbrt(rho_up) ^ 16)
    x17 = x2 <= params.zeta_threshold
    x18 = params.zeta_threshold - 1
    x19 = 1 - x1
    x20 = x19 <= params.zeta_threshold
    x21 = -x18
    x22 = (x17 ? x18 : (x20 ? x21 : x1)) + 1
    x23 = (cbrt(params.zeta_threshold) ^ 4)
    x24 = 4.9479 * (cbrt(2) ^ 2) * 3 ^ (1 // 6) * (cbrt(pi) ^ 1)
    x25 = 0.369279383191011 * (cbrt(x0) ^ 1)
    x26 = sigma_bb / (cbrt(rho_down) ^ 8)
    x27 = x7 * (-x26 / 8 + tau_down / (cbrt(rho_down) ^ 5))
    x28 = (0.981830887265065 > x27 ? x27 : 0.981830887265065)
    x29 = (x27 <= 1 ? (x27 > 0.981830887265065 ? 0.0 : exp(-0.667 * x28 / (1 - x28))) : (x27 < 1.02206363082423 ? 0.0 : -1.24 * exp(0.8 / (1 - (1.02206363082423 > x27 ? 1.02206363082423 : x27)))))
    x30 = x26 * x6
    x31 = 1 - x27
    x32 = (5 // 972) * x30 + (x13 * x26 + x15 * x31 * exp(-x31^2 / 2))^2 + sigma_bb^2 * x12 * exp(-0.0411181346945236 * x30) / (cbrt(rho_down) ^ 16)
    x33 = (x20 ? x18 : (x17 ? x21 : -x1)) + 1
    (x19 * x3 <= params.dens_threshold ? 0.0 : x25 * (1.174 * x29 + (1 - x29) * (0.065 * x32 / (x32 + 0.065) + 1)) * (x33 <= params.zeta_threshold ? x23 : (cbrt(x33) ^ 4)) * expm1(-(cbrt(rho_down) ^ 2) * x24 / (sqrt(sqrt(sigma_bb)) ^ 1))) + (x2 * x3 <= params.dens_threshold ? 0.0 : x25 * (1.174 * x10 + (1 - x10) * (0.065 * x16 / (x16 + 0.065) + 1)) * (x22 <= params.zeta_threshold ? x23 : (cbrt(x22) ^ 4)) * expm1(-(cbrt(rho_up) ^ 2) * x24 / (sqrt(sqrt(sigma_aa)) ^ 1)))
end

function vrho_up(params, rho_up, rho_down, sigma_aa, sigma_ab, sigma_bb, tau_up, tau_down)
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
    x8 = params.zeta_threshold - 1
    x9 = 1 - x3
    x10 = x9 <= params.zeta_threshold
    x11 = -x8
    x12 = (x7 ? x8 : (x10 ? x11 : x3)) + 1
    x13 = x12 <= params.zeta_threshold
    x14 = (cbrt(params.zeta_threshold) ^ 4)
    x15 = (x13 ? x14 : (cbrt(x12) ^ 4))
    x16 = (cbrt(rho_up) ^ -8)
    x17 = sigma_aa * x16
    x18 = (cbrt(pi) ^ -4)
    x19 = (cbrt(6) ^ 1) * x18
    x20 = (5 // 9) * x19
    x21 = x20 * (-x17 / 8 + tau_up / (cbrt(rho_up) ^ 5))
    x22 = x21 <= 1
    x23 = x21 > 0.981830887265065
    x24 = 0.981830887265065 > x21
    x25 = (x24 ? x21 : 0.981830887265065)
    x26 = 1 - x25
    x27 = 0.667 / x26
    x28 = exp(-x25 * x27)
    x29 = x21 < 1.02206363082423
    x30 = 1.02206363082423 > x21
    x31 = 1 - (x30 ? 1.02206363082423 : x21)
    x32 = exp(0.8 / x31)
    x33 = (x22 ? (x23 ? 0.0 : x28) : (x29 ? 0.0 : -1.24 * x32))
    x34 = 1 - x33
    x35 = x17 * x19
    x36 = (cbrt(6) ^ 2)
    x37 = (cbrt(pi) ^ -8)
    x38 = 0.000211513038552076 * x36 * x37
    x39 = exp(-0.0411181346945236 * x35)
    x40 = sigma_aa^2 * x39
    x41 = 2 ^ (5 // 6)
    x42 = (cbrt(3) ^ 1)
    x43 = (sqrt(73) ^ 1)
    x44 = x18 * x41 * x42 * x43
    x45 = (7 // 12960) * x44
    x46 = 1 - x21
    x47 = x46^2
    x48 = exp(-x47 / 2)
    x49 = (sqrt(146) ^ 1) / 100
    x50 = x17 * x45 + x46 * x48 * x49
    x51 = (5 // 972) * x35 + x50^2 + x38 * x40 / (cbrt(rho_up) ^ 16)
    x52 = x51 + 0.065
    x53 = 0.065 / x52
    x54 = x51 * x53 + 1
    x55 = 1.174 * x33 + x34 * x54
    x56 = (sqrt(sqrt(sigma_aa)) ^ -1)
    x57 = (cbrt(2) ^ 2)
    x58 = 3 ^ (1 // 6)
    x59 = (cbrt(pi) ^ 1)
    x60 = 4.9479 * x57 * x58 * x59
    x61 = expm1(-(cbrt(rho_up) ^ 2) * x56 * x60)
    x62 = x55 * x61
    x63 = x15 * x62
    x64 = (cbrt(x1) ^ 1)
    x65 = 0.369279383191011 * x64
    x66 = x5 * x9 <= params.dens_threshold
    x67 = (x10 ? x8 : (x7 ? x11 : -x3)) + 1
    x68 = x67 <= params.zeta_threshold
    x69 = sigma_bb / (cbrt(rho_down) ^ 8)
    x70 = x20 * (-x69 / 8 + tau_down / (cbrt(rho_down) ^ 5))
    x71 = (0.981830887265065 > x70 ? x70 : 0.981830887265065)
    x72 = (x70 <= 1 ? (x70 > 0.981830887265065 ? 0.0 : exp(-0.667 * x71 / (1 - x71))) : (x70 < 1.02206363082423 ? 0.0 : -1.24 * exp(0.8 / (1 - (1.02206363082423 > x70 ? 1.02206363082423 : x70)))))
    x73 = x19 * x69
    x74 = 1 - x70
    x75 = (5 // 972) * x73 + (x45 * x69 + x49 * x74 * exp(-x74^2 / 2))^2 + sigma_bb^2 * x38 * exp(-0.0411181346945236 * x73) / (cbrt(rho_down) ^ 16)
    x76 = (1.174 * x72 + (1 - x72) * (0.065 * x75 / (x75 + 0.065) + 1)) * expm1(-(cbrt(rho_down) ^ 2) * x60 / (sqrt(sqrt(sigma_bb)) ^ 1))
    x77 = x76 * (x68 ? x14 : (cbrt(x67) ^ 4))
    x78 = 0.123093127730337 / (cbrt(x1) ^ 2)
    x79 = x0 / x1^2 - x2
    x80 = (cbrt(rho_up) ^ -11)
    x81 = sigma_aa * x80 / 3 - 5 // 3 * tau_up * x16
    x82 = x20 * x81
    x83 = (x24 ? x82 : 0.0)
    x84 = (x22 ? (x23 ? 0.0 : x28 * (-0.667 * x25 * x83 / x26^2 - x27 * x83)) : (x29 ? 0.0 : -0.992 * x32 * (x30 ? 0.0 : x82) / x31^2))
    x85 = sigma_aa * x80
    x86 = -10 // 729 * x19 * x85 + x50 * (x18 * x41 * x42 * x43 * x47 * x48 * x81 / 90 - x44 * x48 * x81 / 90 - 7 // 2430 * x44 * x85) + 0.000139152345741316 * sigma_aa^3 * x39 / (pi ^ 4 * rho_up^9) - 0.00112806953894441 * x36 * x37 * x40 / (cbrt(rho_up) ^ 19)
    x1 * ((x6 ? 0.0 : x15 * x61 * x65 * (x34 * (-0.065 * x51 * x86 / x52^2 + x53 * x86) - x54 * x84 + 1.174 * x84) + x62 * x65 * (x13 ? 0.0 : (4 // 3) * (cbrt(x12) ^ 1) * (x7 ? 0.0 : (x10 ? 0.0 : -x79))) + x63 * x78 - 1.21810497339387 * x15 * x55 * x56 * x57 * x58 * x59 * x64 * (x61 + 1) / (cbrt(rho_up) ^ 1)) + (x66 ? 0.0 : x65 * x76 * (x68 ? 0.0 : (4 // 3) * (cbrt(x67) ^ 1) * (x10 ? 0.0 : (x7 ? 0.0 : x79))) + x77 * x78)) + (x6 ? 0.0 : x63 * x65) + (x66 ? 0.0 : x65 * x77)
end

function vrho_down(params, rho_up, rho_down, sigma_aa, sigma_ab, sigma_bb, tau_up, tau_down)
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
    x8 = params.zeta_threshold - 1
    x9 = 1 - x3
    x10 = x9 <= params.zeta_threshold
    x11 = -x8
    x12 = (x7 ? x8 : (x10 ? x11 : x3)) + 1
    x13 = x12 <= params.zeta_threshold
    x14 = (cbrt(params.zeta_threshold) ^ 4)
    x15 = sigma_aa / (cbrt(rho_up) ^ 8)
    x16 = (cbrt(pi) ^ -4)
    x17 = (cbrt(6) ^ 1) * x16
    x18 = (5 // 9) * x17
    x19 = x18 * (-x15 / 8 + tau_up / (cbrt(rho_up) ^ 5))
    x20 = (0.981830887265065 > x19 ? x19 : 0.981830887265065)
    x21 = (x19 <= 1 ? (x19 > 0.981830887265065 ? 0.0 : exp(-0.667 * x20 / (1 - x20))) : (x19 < 1.02206363082423 ? 0.0 : -1.24 * exp(0.8 / (1 - (1.02206363082423 > x19 ? 1.02206363082423 : x19)))))
    x22 = x15 * x17
    x23 = (cbrt(6) ^ 2) / (cbrt(pi) ^ 8)
    x24 = 0.000211513038552076 * x23
    x25 = 2 ^ (5 // 6)
    x26 = (cbrt(3) ^ 1)
    x27 = (sqrt(73) ^ 1)
    x28 = x16 * x25 * x26 * x27
    x29 = (7 // 12960) * x28
    x30 = 1 - x19
    x31 = (sqrt(146) ^ 1) / 100
    x32 = (5 // 972) * x22 + (x15 * x29 + x30 * x31 * exp(-x30^2 / 2))^2 + sigma_aa^2 * x24 * exp(-0.0411181346945236 * x22) / (cbrt(rho_up) ^ 16)
    x33 = (cbrt(2) ^ 2) * 3 ^ (1 // 6) * (cbrt(pi) ^ 1)
    x34 = 4.9479 * x33
    x35 = (1.174 * x21 + (1 - x21) * (0.065 * x32 / (x32 + 0.065) + 1)) * expm1(-(cbrt(rho_up) ^ 2) * x34 / (sqrt(sqrt(sigma_aa)) ^ 1))
    x36 = x35 * (x13 ? x14 : (cbrt(x12) ^ 4))
    x37 = (cbrt(x1) ^ 1)
    x38 = 0.369279383191011 * x37
    x39 = x5 * x9 <= params.dens_threshold
    x40 = (x10 ? x8 : (x7 ? x11 : -x3)) + 1
    x41 = x40 <= params.zeta_threshold
    x42 = (x41 ? x14 : (cbrt(x40) ^ 4))
    x43 = (cbrt(rho_down) ^ -8)
    x44 = sigma_bb * x43
    x45 = x18 * (-x44 / 8 + tau_down / (cbrt(rho_down) ^ 5))
    x46 = x45 <= 1
    x47 = x45 > 0.981830887265065
    x48 = 0.981830887265065 > x45
    x49 = (x48 ? x45 : 0.981830887265065)
    x50 = 1 - x49
    x51 = 0.667 / x50
    x52 = exp(-x49 * x51)
    x53 = x45 < 1.02206363082423
    x54 = 1.02206363082423 > x45
    x55 = 1 - (x54 ? 1.02206363082423 : x45)
    x56 = exp(0.8 / x55)
    x57 = (x46 ? (x47 ? 0.0 : x52) : (x53 ? 0.0 : -1.24 * x56))
    x58 = 1 - x57
    x59 = x17 * x44
    x60 = exp(-0.0411181346945236 * x59)
    x61 = sigma_bb^2 * x60
    x62 = 1 - x45
    x63 = x62^2
    x64 = exp(-x63 / 2)
    x65 = x29 * x44 + x31 * x62 * x64
    x66 = (5 // 972) * x59 + x65^2 + x24 * x61 / (cbrt(rho_down) ^ 16)
    x67 = x66 + 0.065
    x68 = 0.065 / x67
    x69 = x66 * x68 + 1
    x70 = 1.174 * x57 + x58 * x69
    x71 = (sqrt(sqrt(sigma_bb)) ^ -1)
    x72 = expm1(-(cbrt(rho_down) ^ 2) * x34 * x71)
    x73 = x70 * x72
    x74 = x42 * x73
    x75 = 0.123093127730337 / (cbrt(x1) ^ 2)
    x76 = x0 / x1^2 + x2
    x77 = (cbrt(rho_down) ^ -11)
    x78 = sigma_bb * x77 / 3 - 5 // 3 * tau_down * x43
    x79 = x18 * x78
    x80 = (x48 ? x79 : 0.0)
    x81 = (x46 ? (x47 ? 0.0 : x52 * (-0.667 * x49 * x80 / x50^2 - x51 * x80)) : (x53 ? 0.0 : -0.992 * x56 * (x54 ? 0.0 : x79) / x55^2))
    x82 = sigma_bb * x77
    x83 = -10 // 729 * x17 * x82 + x65 * (x16 * x25 * x26 * x27 * x63 * x64 * x78 / 90 - x28 * x64 * x78 / 90 - 7 // 2430 * x28 * x82) + 0.000139152345741316 * sigma_bb^3 * x60 / (pi ^ 4 * rho_down^9) - 0.00112806953894441 * x23 * x61 / (cbrt(rho_down) ^ 19)
    x1 * ((x39 ? 0.0 : x38 * x42 * x72 * (x58 * (-0.065 * x66 * x83 / x67^2 + x68 * x83) - x69 * x81 + 1.174 * x81) + x38 * x73 * (x41 ? 0.0 : (4 // 3) * (cbrt(x40) ^ 1) * (x10 ? 0.0 : (x7 ? 0.0 : x76))) + x74 * x75 - 1.21810497339387 * x33 * x37 * x42 * x70 * x71 * (x72 + 1) / (cbrt(rho_down) ^ 1)) + (x6 ? 0.0 : x35 * x38 * (x13 ? 0.0 : (4 // 3) * (cbrt(x12) ^ 1) * (x7 ? 0.0 : (x10 ? 0.0 : -x76))) + x36 * x75)) + (x39 ? 0.0 : x38 * x74) + (x6 ? 0.0 : x36 * x38)
end

function vsigma_aa(params, rho_up, rho_down, sigma_aa, sigma_ab, sigma_bb, tau_up, tau_down)
    if rho_up + rho_down <= params.dens_threshold
        return zero(rho_up)
    end
    x0 = rho_down + rho_up
    x1 = (-rho_down + rho_up) / x0
    x2 = x1 + 1
    x3 = (cbrt(2) ^ 2) * 3 ^ (1 // 6) * (cbrt(pi) ^ 1) * (cbrt(rho_up) ^ 2)
    x4 = expm1(-4.9479 * x3 / (sqrt(sqrt(sigma_aa)) ^ 1))
    x5 = (cbrt(rho_up) ^ -8)
    x6 = sigma_aa * x5
    x7 = (cbrt(pi) ^ -4)
    x8 = (cbrt(6) ^ 1) * x7
    x9 = (5 // 9) * x8 * (-x6 / 8 + tau_up / (cbrt(rho_up) ^ 5))
    x10 = x9 <= 1
    x11 = x9 > 0.981830887265065
    x12 = 0.981830887265065 > x9
    x13 = (x12 ? x9 : 0.981830887265065)
    x14 = 1 - x13
    x15 = 0.667 / x14
    x16 = exp(-x13 * x15)
    x17 = x9 < 1.02206363082423
    x18 = 1.02206363082423 > x9
    x19 = 1 - (x18 ? 1.02206363082423 : x9)
    x20 = exp(0.8 / x19)
    x21 = (x10 ? (x11 ? 0.0 : x16) : (x17 ? 0.0 : -1.24 * x20))
    x22 = 1 - x21
    x23 = x6 * x8
    x24 = exp(-0.0411181346945236 * x23)
    x25 = sigma_aa^2 * x24
    x26 = (cbrt(6) ^ 2) / ((cbrt(pi) ^ 8) * (cbrt(rho_up) ^ 16))
    x27 = 2 ^ (5 // 6) * (cbrt(3) ^ 1) * (sqrt(73) ^ 1) * x7
    x28 = 1 - x9
    x29 = x28^2
    x30 = exp(-x29 / 2)
    x31 = (7 // 12960) * x27 * x6 + (sqrt(146) ^ 1) * x28 * x30 / 100
    x32 = (5 // 972) * x23 + 0.000211513038552076 * x25 * x26 + x31^2
    x33 = x32 + 0.065
    x34 = 0.065 / x33
    x35 = x32 * x34 + 1
    x36 = params.zeta_threshold - 1
    x37 = (x2 <= params.zeta_threshold ? x36 : (1 - x1 <= params.zeta_threshold ? -x36 : x1)) + 1
    x38 = (cbrt(x0) ^ 1) * (x37 <= params.zeta_threshold ? (cbrt(params.zeta_threshold) ^ 4) : (cbrt(x37) ^ 4))
    x39 = x5 * x8
    x40 = -5 // 72 * x39
    x41 = (x12 ? x40 : 0.0)
    x42 = (x10 ? (x11 ? 0.0 : x16 * (-0.667 * x13 * x41 / x14^2 - x15 * x41)) : (x17 ? 0.0 : -0.992 * x20 * (x18 ? 0.0 : x40) / x19^2))
    x43 = x27 * x5
    x44 = x30 * x43 / 720
    x45 = 0.000423026077104152 * sigma_aa * x24 * x26 + x31 * (-x29 * x44 + (7 // 6480) * x43 + x44) + (5 // 972) * x39 - 5.21821296529933e-5 * x25 / (pi ^ 4 * rho_up^8)
    x0 * (x0 * x2 / 2 <= params.dens_threshold ? 0.0 : 0.369279383191011 * x38 * x4 * (x22 * (-0.065 * x32 * x45 / x33^2 + x34 * x45) - x35 * x42 + 1.174 * x42) + 0.456789365022701 * x3 * x38 * (1.174 * x21 + x22 * x35) * (x4 + 1) / (sqrt(sqrt(sigma_aa)) ^ 5))
end

function vsigma_ab(params, rho_up, rho_down, sigma_aa, sigma_ab, sigma_bb, tau_up, tau_down)
    if rho_up + rho_down <= params.dens_threshold
        return zero(rho_up)
    end
    zero(rho_up)
end

function vsigma_bb(params, rho_up, rho_down, sigma_aa, sigma_ab, sigma_bb, tau_up, tau_down)
    if rho_up + rho_down <= params.dens_threshold
        return zero(rho_up)
    end
    x0 = rho_down + rho_up
    x1 = (-rho_down + rho_up) / x0
    x2 = 1 - x1
    x3 = (cbrt(2) ^ 2) * 3 ^ (1 // 6) * (cbrt(pi) ^ 1) * (cbrt(rho_down) ^ 2)
    x4 = expm1(-4.9479 * x3 / (sqrt(sqrt(sigma_bb)) ^ 1))
    x5 = (cbrt(rho_down) ^ -8)
    x6 = sigma_bb * x5
    x7 = (cbrt(pi) ^ -4)
    x8 = (cbrt(6) ^ 1) * x7
    x9 = (5 // 9) * x8 * (-x6 / 8 + tau_down / (cbrt(rho_down) ^ 5))
    x10 = x9 <= 1
    x11 = x9 > 0.981830887265065
    x12 = 0.981830887265065 > x9
    x13 = (x12 ? x9 : 0.981830887265065)
    x14 = 1 - x13
    x15 = 0.667 / x14
    x16 = exp(-x13 * x15)
    x17 = x9 < 1.02206363082423
    x18 = 1.02206363082423 > x9
    x19 = 1 - (x18 ? 1.02206363082423 : x9)
    x20 = exp(0.8 / x19)
    x21 = (x10 ? (x11 ? 0.0 : x16) : (x17 ? 0.0 : -1.24 * x20))
    x22 = 1 - x21
    x23 = x6 * x8
    x24 = exp(-0.0411181346945236 * x23)
    x25 = sigma_bb^2 * x24
    x26 = (cbrt(6) ^ 2) / ((cbrt(pi) ^ 8) * (cbrt(rho_down) ^ 16))
    x27 = 2 ^ (5 // 6) * (cbrt(3) ^ 1) * (sqrt(73) ^ 1) * x7
    x28 = 1 - x9
    x29 = x28^2
    x30 = exp(-x29 / 2)
    x31 = (7 // 12960) * x27 * x6 + (sqrt(146) ^ 1) * x28 * x30 / 100
    x32 = (5 // 972) * x23 + 0.000211513038552076 * x25 * x26 + x31^2
    x33 = x32 + 0.065
    x34 = 0.065 / x33
    x35 = x32 * x34 + 1
    x36 = params.zeta_threshold - 1
    x37 = (x2 <= params.zeta_threshold ? x36 : (x1 + 1 <= params.zeta_threshold ? -x36 : -x1)) + 1
    x38 = (cbrt(x0) ^ 1) * (x37 <= params.zeta_threshold ? (cbrt(params.zeta_threshold) ^ 4) : (cbrt(x37) ^ 4))
    x39 = x5 * x8
    x40 = -5 // 72 * x39
    x41 = (x12 ? x40 : 0.0)
    x42 = (x10 ? (x11 ? 0.0 : x16 * (-0.667 * x13 * x41 / x14^2 - x15 * x41)) : (x17 ? 0.0 : -0.992 * x20 * (x18 ? 0.0 : x40) / x19^2))
    x43 = x27 * x5
    x44 = x30 * x43 / 720
    x45 = 0.000423026077104152 * sigma_bb * x24 * x26 + x31 * (-x29 * x44 + (7 // 6480) * x43 + x44) + (5 // 972) * x39 - 5.21821296529933e-5 * x25 / (pi ^ 4 * rho_down^8)
    x0 * (x0 * x2 / 2 <= params.dens_threshold ? 0.0 : 0.369279383191011 * x38 * x4 * (x22 * (-0.065 * x32 * x45 / x33^2 + x34 * x45) - x35 * x42 + 1.174 * x42) + 0.456789365022701 * x3 * x38 * (1.174 * x21 + x22 * x35) * (x4 + 1) / (sqrt(sqrt(sigma_bb)) ^ 5))
end

function vtau_up(params, rho_up, rho_down, sigma_aa, sigma_ab, sigma_bb, tau_up, tau_down)
    if rho_up + rho_down <= params.dens_threshold
        return zero(rho_up)
    end
    x0 = rho_down + rho_up
    x1 = (-rho_down + rho_up) / x0
    x2 = x1 + 1
    x3 = params.zeta_threshold - 1
    x4 = (x2 <= params.zeta_threshold ? x3 : (1 - x1 <= params.zeta_threshold ? -x3 : x1)) + 1
    x5 = (cbrt(rho_up) ^ -5)
    x6 = sigma_aa / (cbrt(rho_up) ^ 8)
    x7 = (cbrt(pi) ^ -4)
    x8 = (cbrt(6) ^ 1) * x7
    x9 = (5 // 9) * x8
    x10 = x9 * (tau_up * x5 - x6 / 8)
    x11 = x10 <= 1
    x12 = x10 > 0.981830887265065
    x13 = 0.981830887265065 > x10
    x14 = (x13 ? x10 : 0.981830887265065)
    x15 = 1 - x14
    x16 = 0.667 / x15
    x17 = exp(-x14 * x16)
    x18 = x5 * x9
    x19 = (x13 ? x18 : 0.0)
    x20 = x10 < 1.02206363082423
    x21 = 1.02206363082423 > x10
    x22 = 1 - (x21 ? 1.02206363082423 : x10)
    x23 = exp(0.8 / x22)
    x24 = (x11 ? (x12 ? 0.0 : x17 * (-0.667 * x14 * x19 / x15^2 - x16 * x19)) : (x20 ? 0.0 : -0.992 * x23 * (x21 ? 0.0 : x18) / x22^2))
    x25 = x6 * x8
    x26 = 2 ^ (5 // 6) * (cbrt(3) ^ 1) * (sqrt(73) ^ 1) * x7
    x27 = 1 - x10
    x28 = x27^2
    x29 = exp(-x28 / 2)
    x30 = (7 // 12960) * x26 * x6 + (sqrt(146) ^ 1) * x27 * x29 / 100
    x31 = (5 // 972) * x25 + x30^2 + 0.000211513038552076 * (cbrt(6) ^ 2) * sigma_aa^2 * exp(-0.0411181346945236 * x25) / ((cbrt(pi) ^ 8) * (cbrt(rho_up) ^ 16))
    x32 = x31 + 0.065
    x33 = 1 / x32
    x34 = x26 * x29 * x5 / 90
    x35 = x28 * x34 - x34
    x0 * (x0 * x2 / 2 <= params.dens_threshold ? 0.0 : 0.369279383191011 * (cbrt(x0) ^ 1) * (-x24 * (0.065 * x31 * x33 + 1) + 1.174 * x24 + (1 - (x11 ? (x12 ? 0.0 : x17) : (x20 ? 0.0 : -1.24 * x23))) * (-0.065 * x30 * x31 * x35 / x32^2 + 0.065 * x30 * x33 * x35)) * (x4 <= params.zeta_threshold ? (cbrt(params.zeta_threshold) ^ 4) : (cbrt(x4) ^ 4)) * expm1(-4.9479 * (cbrt(2) ^ 2) * 3 ^ (1 // 6) * (cbrt(pi) ^ 1) * (cbrt(rho_up) ^ 2) / (sqrt(sqrt(sigma_aa)) ^ 1)))
end

function vtau_down(params, rho_up, rho_down, sigma_aa, sigma_ab, sigma_bb, tau_up, tau_down)
    if rho_up + rho_down <= params.dens_threshold
        return zero(rho_up)
    end
    x0 = rho_down + rho_up
    x1 = (-rho_down + rho_up) / x0
    x2 = 1 - x1
    x3 = params.zeta_threshold - 1
    x4 = (x2 <= params.zeta_threshold ? x3 : (x1 + 1 <= params.zeta_threshold ? -x3 : -x1)) + 1
    x5 = (cbrt(rho_down) ^ -5)
    x6 = sigma_bb / (cbrt(rho_down) ^ 8)
    x7 = (cbrt(pi) ^ -4)
    x8 = (cbrt(6) ^ 1) * x7
    x9 = (5 // 9) * x8
    x10 = x9 * (tau_down * x5 - x6 / 8)
    x11 = x10 <= 1
    x12 = x10 > 0.981830887265065
    x13 = 0.981830887265065 > x10
    x14 = (x13 ? x10 : 0.981830887265065)
    x15 = 1 - x14
    x16 = 0.667 / x15
    x17 = exp(-x14 * x16)
    x18 = x5 * x9
    x19 = (x13 ? x18 : 0.0)
    x20 = x10 < 1.02206363082423
    x21 = 1.02206363082423 > x10
    x22 = 1 - (x21 ? 1.02206363082423 : x10)
    x23 = exp(0.8 / x22)
    x24 = (x11 ? (x12 ? 0.0 : x17 * (-0.667 * x14 * x19 / x15^2 - x16 * x19)) : (x20 ? 0.0 : -0.992 * x23 * (x21 ? 0.0 : x18) / x22^2))
    x25 = x6 * x8
    x26 = 2 ^ (5 // 6) * (cbrt(3) ^ 1) * (sqrt(73) ^ 1) * x7
    x27 = 1 - x10
    x28 = x27^2
    x29 = exp(-x28 / 2)
    x30 = (7 // 12960) * x26 * x6 + (sqrt(146) ^ 1) * x27 * x29 / 100
    x31 = (5 // 972) * x25 + x30^2 + 0.000211513038552076 * (cbrt(6) ^ 2) * sigma_bb^2 * exp(-0.0411181346945236 * x25) / ((cbrt(pi) ^ 8) * (cbrt(rho_down) ^ 16))
    x32 = x31 + 0.065
    x33 = 1 / x32
    x34 = x26 * x29 * x5 / 90
    x35 = x28 * x34 - x34
    x0 * (x0 * x2 / 2 <= params.dens_threshold ? 0.0 : 0.369279383191011 * (cbrt(x0) ^ 1) * (-x24 * (0.065 * x31 * x33 + 1) + 1.174 * x24 + (1 - (x11 ? (x12 ? 0.0 : x17) : (x20 ? 0.0 : -1.24 * x23))) * (-0.065 * x30 * x31 * x35 / x32^2 + 0.065 * x30 * x33 * x35)) * (x4 <= params.zeta_threshold ? (cbrt(params.zeta_threshold) ^ 4) : (cbrt(x4) ^ 4)) * expm1(-4.9479 * (cbrt(2) ^ 2) * 3 ^ (1 // 6) * (cbrt(pi) ^ 1) * (cbrt(rho_down) ^ 2) / (sqrt(sqrt(sigma_bb)) ^ 1)))
end

function zk_unp(params, rho, sigma, tau)
    if rho <= params.dens_threshold
        return zero(rho)
    end
    x0 = 1 <= params.zeta_threshold
    x1 = params.zeta_threshold - 1
    x2 = (x0 ? x1 : (x0 ? -x1 : 0.0)) + 1
    x3 = (cbrt(pi) ^ -4)
    x4 = (cbrt(2) ^ 2)
    x5 = sigma / (cbrt(rho) ^ 8)
    x6 = (5 // 9) * (cbrt(6) ^ 1) * x3 * (-x4 * x5 / 8 + tau * x4 / (cbrt(rho) ^ 5))
    x7 = (0.981830887265065 > x6 ? x6 : 0.981830887265065)
    x8 = (x6 <= 1 ? (x6 > 0.981830887265065 ? 0.0 : exp(-0.667 * x7 / (1 - x7))) : (x6 < 1.02206363082423 ? 0.0 : -1.24 * exp(0.8 / (1 - (1.02206363082423 > x6 ? 1.02206363082423 : x6)))))
    x9 = (cbrt(3) ^ 1) * x3 * x5
    x10 = (sqrt(146) ^ 1)
    x11 = 1 - x6
    x12 = (5 // 486) * x9 + (x10 * x11 * exp(-x11^2 / 2) / 100 + (7 // 6480) * x10 * x9)^2 + 0.000846052154208304 * (cbrt(3) ^ 2) * sigma^2 * exp(-0.0822362693890472 * x9) / ((cbrt(pi) ^ 8) * (cbrt(rho) ^ 16))
    2 * (rho / 2 <= params.dens_threshold ? 0.0 : 0.369279383191011 * (cbrt(rho) ^ 1) * (1.174 * x8 + (1 - x8) * (0.065 * x12 / (x12 + 0.065) + 1)) * (x2 <= params.zeta_threshold ? (cbrt(params.zeta_threshold) ^ 4) : (cbrt(x2) ^ 4)) * expm1(-4.9479 * (sqrt(2) ^ 1) * 3 ^ (1 // 6) * (cbrt(pi) ^ 1) * (cbrt(rho) ^ 2) / (sqrt(sqrt(sigma)) ^ 1)))
end

function vrho_unp(params, rho, sigma, tau)
    if rho <= params.dens_threshold
        return zero(rho)
    end
    x0 = rho / 2 <= params.dens_threshold
    x1 = (cbrt(rho) ^ 2)
    x2 = (sqrt(2) ^ 1) * 3 ^ (1 // 6) * (cbrt(pi) ^ 1) / (sqrt(sqrt(sigma)) ^ 1)
    x3 = expm1(-4.9479 * x1 * x2)
    x4 = (cbrt(2) ^ 2)
    x5 = tau * x4
    x6 = (cbrt(rho) ^ -8)
    x7 = (cbrt(pi) ^ -4)
    x8 = (5 // 9) * (cbrt(6) ^ 1) * x7
    x9 = x8 * (-sigma * x4 * x6 / 8 + x5 / (cbrt(rho) ^ 5))
    x10 = x9 <= 1
    x11 = x9 > 0.981830887265065
    x12 = 0.981830887265065 > x9
    x13 = (x12 ? x9 : 0.981830887265065)
    x14 = 1 - x13
    x15 = 0.667 / x14
    x16 = exp(-x13 * x15)
    x17 = x9 < 1.02206363082423
    x18 = 1.02206363082423 > x9
    x19 = 1 - (x18 ? 1.02206363082423 : x9)
    x20 = exp(0.8 / x19)
    x21 = (x10 ? (x11 ? 0.0 : x16) : (x17 ? 0.0 : -1.24 * x20))
    x22 = (cbrt(3) ^ 1)
    x23 = x22 * x7
    x24 = sigma * x23
    x25 = x24 * x6
    x26 = exp(-0.0822362693890472 * x25)
    x27 = (cbrt(3) ^ 2) * sigma^2 * x26 / (cbrt(pi) ^ 8)
    x28 = (sqrt(146) ^ 1)
    x29 = 1 - x9
    x30 = x29^2
    x31 = exp(-x30 / 2)
    x32 = (7 // 6480) * x25 * x28 + x28 * x29 * x31 / 100
    x33 = (5 // 486) * x25 + x32^2 + 0.000846052154208304 * x27 / (cbrt(rho) ^ 16)
    x34 = x33 + 0.065
    x35 = 0.065 / x34
    x36 = x33 * x35 + 1
    x37 = 1 - x21
    x38 = 1 <= params.zeta_threshold
    x39 = params.zeta_threshold - 1
    x40 = (x38 ? x39 : (x38 ? -x39 : 0.0)) + 1
    x41 = (x40 <= params.zeta_threshold ? (cbrt(params.zeta_threshold) ^ 4) : (cbrt(x40) ^ 4))
    x42 = x41 * (1.174 * x21 + x36 * x37)
    x43 = x3 * x42
    x44 = 0.369279383191011 * (cbrt(rho) ^ 1)
    x45 = (cbrt(rho) ^ -11)
    x46 = sigma * x4 * x45 / 3 - 5 // 3 * x5 * x6
    x47 = x46 * x8
    x48 = (x12 ? x47 : 0.0)
    x49 = (x10 ? (x11 ? 0.0 : x16 * (-0.667 * x13 * x48 / x14^2 - x15 * x48)) : (x17 ? 0.0 : -0.992 * x20 * (x18 ? 0.0 : x47) / x19^2))
    x50 = x24 * x45
    x51 = 2 ^ (5 // 6)
    x52 = (sqrt(73) ^ 1)
    x53 = x32 * (x22 * x30 * x31 * x46 * x51 * x52 * x7 / 90 - x23 * x31 * x46 * x51 * x52 / 90 - 7 // 1215 * x28 * x50) - 20 // 729 * x50 + 0.000556609382965262 * sigma^3 * x26 / (pi ^ 4 * rho^9) - 0.00451227815577762 * x27 / (cbrt(rho) ^ 19)
    2 * rho * (x0 ? 0.0 : -1.21810497339387 * x2 * x42 * (x3 + 1) + x3 * x41 * x44 * (-x36 * x49 + x37 * (-0.065 * x33 * x53 / x34^2 + x35 * x53) + 1.174 * x49) + 0.123093127730337 * x43 / x1) + 2 * (x0 ? 0.0 : x43 * x44)
end

function vsigma_unp(params, rho, sigma, tau)
    if rho <= params.dens_threshold
        return zero(rho)
    end
    x0 = 1 <= params.zeta_threshold
    x1 = params.zeta_threshold - 1
    x2 = (x0 ? x1 : (x0 ? -x1 : 0.0)) + 1
    x3 = (x2 <= params.zeta_threshold ? (cbrt(params.zeta_threshold) ^ 4) : (cbrt(x2) ^ 4))
    x4 = (sqrt(2) ^ 1) * 3 ^ (1 // 6) * (cbrt(pi) ^ 1)
    x5 = expm1(-4.9479 * (cbrt(rho) ^ 2) * x4 / (sqrt(sqrt(sigma)) ^ 1))
    x6 = (cbrt(pi) ^ -4)
    x7 = (cbrt(2) ^ 2)
    x8 = (cbrt(rho) ^ -8)
    x9 = sigma * x8
    x10 = (5 // 9) * (cbrt(6) ^ 1) * x6 * (-x7 * x9 / 8 + tau * x7 / (cbrt(rho) ^ 5))
    x11 = x10 <= 1
    x12 = x10 > 0.981830887265065
    x13 = 0.981830887265065 > x10
    x14 = (x13 ? x10 : 0.981830887265065)
    x15 = 1 - x14
    x16 = 0.667 / x15
    x17 = exp(-x14 * x16)
    x18 = x10 < 1.02206363082423
    x19 = 1.02206363082423 > x10
    x20 = 1 - (x19 ? 1.02206363082423 : x10)
    x21 = exp(0.8 / x20)
    x22 = (x11 ? (x12 ? 0.0 : x17) : (x18 ? 0.0 : -1.24 * x21))
    x23 = (cbrt(3) ^ 1) * x6
    x24 = x23 * x9
    x25 = exp(-0.0822362693890472 * x24)
    x26 = sigma^2 * x25
    x27 = (cbrt(3) ^ 2) / ((cbrt(pi) ^ 8) * (cbrt(rho) ^ 16))
    x28 = (sqrt(146) ^ 1)
    x29 = 1 - x10
    x30 = x29^2
    x31 = x28 * exp(-x30 / 2)
    x32 = (7 // 6480) * x24 * x28 + x29 * x31 / 100
    x33 = (5 // 486) * x24 + 0.000846052154208304 * x26 * x27 + x32^2
    x34 = x33 + 0.065
    x35 = 0.065 / x34
    x36 = x33 * x35 + 1
    x37 = 1 - x22
    x38 = x23 * x8
    x39 = -5 // 36 * x38
    x40 = (x13 ? x39 : 0.0)
    x41 = (x11 ? (x12 ? 0.0 : x17 * (-0.667 * x14 * x40 / x15^2 - x16 * x40)) : (x18 ? 0.0 : -0.992 * x21 * (x19 ? 0.0 : x39) / x20^2))
    x42 = x31 * x38 / 360
    x43 = 0.00169210430841661 * sigma * x25 * x27 + x32 * ((7 // 3240) * x28 * x38 - x30 * x42 + x42) + (5 // 486) * x38 - 0.000208728518611973 * x26 / (pi ^ 4 * rho^8)
    2 * rho * (rho / 2 <= params.dens_threshold ? 0.0 : 0.369279383191011 * (cbrt(rho) ^ 1) * x3 * x5 * (-x36 * x41 + x37 * (-0.065 * x33 * x43 / x34^2 + x35 * x43) + 1.174 * x41) + 0.456789365022701 * rho * x3 * x4 * (1.174 * x22 + x36 * x37) * (x5 + 1) / (sqrt(sqrt(sigma)) ^ 5))
end

function vtau_unp(params, rho, sigma, tau)
    if rho <= params.dens_threshold
        return zero(rho)
    end
    x0 = 1 <= params.zeta_threshold
    x1 = params.zeta_threshold - 1
    x2 = (x0 ? x1 : (x0 ? -x1 : 0.0)) + 1
    x3 = (cbrt(pi) ^ -4)
    x4 = (cbrt(2) ^ 2)
    x5 = (cbrt(rho) ^ -5)
    x6 = sigma / (cbrt(rho) ^ 8)
    x7 = (5 // 9) * (cbrt(6) ^ 1) * x3 * (tau * x4 * x5 - x4 * x6 / 8)
    x8 = x7 <= 1
    x9 = x7 > 0.981830887265065
    x10 = 0.981830887265065 > x7
    x11 = (x10 ? x7 : 0.981830887265065)
    x12 = 1 - x11
    x13 = 0.667 / x12
    x14 = exp(-x11 * x13)
    x15 = (cbrt(3) ^ 1) * x3
    x16 = x15 * x5
    x17 = (10 // 9) * x16
    x18 = (x10 ? x17 : 0.0)
    x19 = x7 < 1.02206363082423
    x20 = 1.02206363082423 > x7
    x21 = 1 - (x20 ? 1.02206363082423 : x7)
    x22 = exp(0.8 / x21)
    x23 = (x8 ? (x9 ? 0.0 : x14 * (-0.667 * x11 * x18 / x12^2 - x13 * x18)) : (x19 ? 0.0 : -0.992 * x22 * (x20 ? 0.0 : x17) / x21^2))
    x24 = x15 * x6
    x25 = (sqrt(146) ^ 1)
    x26 = 1 - x7
    x27 = x26^2
    x28 = x25 * exp(-x27 / 2)
    x29 = (7 // 6480) * x24 * x25 + x26 * x28 / 100
    x30 = (5 // 486) * x24 + x29^2 + 0.000846052154208304 * (cbrt(3) ^ 2) * sigma^2 * exp(-0.0822362693890472 * x24) / ((cbrt(pi) ^ 8) * (cbrt(rho) ^ 16))
    x31 = x30 + 0.065
    x32 = 1 / x31
    x33 = x16 * x28 / 45
    x34 = x27 * x33 - x33
    2 * rho * (rho / 2 <= params.dens_threshold ? 0.0 : 0.369279383191011 * (cbrt(rho) ^ 1) * (-x23 * (0.065 * x30 * x32 + 1) + 1.174 * x23 + (1 - (x8 ? (x9 ? 0.0 : x14) : (x19 ? 0.0 : -1.24 * x22))) * (-0.065 * x29 * x30 * x34 / x31^2 + 0.065 * x29 * x32 * x34)) * (x2 <= params.zeta_threshold ? (cbrt(params.zeta_threshold) ^ 4) : (cbrt(x2) ^ 4)) * expm1(-4.9479 * (sqrt(2) ^ 1) * 3 ^ (1 // 6) * (cbrt(pi) ^ 1) * (cbrt(rho) ^ 2) / (sqrt(sqrt(sigma)) ^ 1)))
end


end # module