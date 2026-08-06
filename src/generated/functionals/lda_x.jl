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
    ifelse((rho_down + rho_up) * (-(-rho_down + rho_up) / (rho_down + rho_up) + 1) / 2 <= params.dens_threshold, 0, -0.369279383191011 * (rho_down + rho_up)^(1 // 3) * ifelse(-(-rho_down + rho_up) / (rho_down + rho_up) + 1 <= params.zeta_threshold, params.zeta_threshold^(4 // 3), (-(-rho_down + rho_up) / (rho_down + rho_up) + 1)^(4 // 3))) + ifelse((rho_down + rho_up) * ((-rho_down + rho_up) / (rho_down + rho_up) + 1) / 2 <= params.dens_threshold, 0, -0.369279383191011 * (rho_down + rho_up)^(1 // 3) * ifelse((-rho_down + rho_up) / (rho_down + rho_up) + 1 <= params.zeta_threshold, params.zeta_threshold^(4 // 3), ((-rho_down + rho_up) / (rho_down + rho_up) + 1)^(4 // 3)))
end

function vrho_up(params, rho_up, rho_down)
    (rho_down + rho_up) * (ifelse((rho_down + rho_up) * (-(-rho_down + rho_up) / (rho_down + rho_up) + 1) / 2 <= params.dens_threshold, 0, -0.369279383191011 * (rho_down + rho_up)^(1 // 3) * ifelse(-(-rho_down + rho_up) / (rho_down + rho_up) + 1 <= params.zeta_threshold, 0, ((4 // 3) * (-rho_down + rho_up) / (rho_down + rho_up)^2 - 4 // 3 / (rho_down + rho_up)) * (-(-rho_down + rho_up) / (rho_down + rho_up) + 1)^(1 // 3)) - 0.123093127730337 * ifelse(-(-rho_down + rho_up) / (rho_down + rho_up) + 1 <= params.zeta_threshold, params.zeta_threshold^(4 // 3), (-(-rho_down + rho_up) / (rho_down + rho_up) + 1)^(4 // 3)) / (rho_down + rho_up)^(2 // 3)) + ifelse((rho_down + rho_up) * ((-rho_down + rho_up) / (rho_down + rho_up) + 1) / 2 <= params.dens_threshold, 0, -0.369279383191011 * (rho_down + rho_up)^(1 // 3) * ifelse((-rho_down + rho_up) / (rho_down + rho_up) + 1 <= params.zeta_threshold, 0, (-4 // 3 * (-rho_down + rho_up) / (rho_down + rho_up)^2 + (4 // 3) / (rho_down + rho_up)) * ((-rho_down + rho_up) / (rho_down + rho_up) + 1)^(1 // 3)) - 0.123093127730337 * ifelse((-rho_down + rho_up) / (rho_down + rho_up) + 1 <= params.zeta_threshold, params.zeta_threshold^(4 // 3), ((-rho_down + rho_up) / (rho_down + rho_up) + 1)^(4 // 3)) / (rho_down + rho_up)^(2 // 3))) + ifelse((rho_down + rho_up) * (-(-rho_down + rho_up) / (rho_down + rho_up) + 1) / 2 <= params.dens_threshold, 0, -0.369279383191011 * (rho_down + rho_up)^(1 // 3) * ifelse(-(-rho_down + rho_up) / (rho_down + rho_up) + 1 <= params.zeta_threshold, params.zeta_threshold^(4 // 3), (-(-rho_down + rho_up) / (rho_down + rho_up) + 1)^(4 // 3))) + ifelse((rho_down + rho_up) * ((-rho_down + rho_up) / (rho_down + rho_up) + 1) / 2 <= params.dens_threshold, 0, -0.369279383191011 * (rho_down + rho_up)^(1 // 3) * ifelse((-rho_down + rho_up) / (rho_down + rho_up) + 1 <= params.zeta_threshold, params.zeta_threshold^(4 // 3), ((-rho_down + rho_up) / (rho_down + rho_up) + 1)^(4 // 3)))
end

function vrho_down(params, rho_up, rho_down)
    (rho_down + rho_up) * (ifelse((rho_down + rho_up) * (-(-rho_down + rho_up) / (rho_down + rho_up) + 1) / 2 <= params.dens_threshold, 0, -0.369279383191011 * (rho_down + rho_up)^(1 // 3) * ifelse(-(-rho_down + rho_up) / (rho_down + rho_up) + 1 <= params.zeta_threshold, 0, ((4 // 3) * (-rho_down + rho_up) / (rho_down + rho_up)^2 + (4 // 3) / (rho_down + rho_up)) * (-(-rho_down + rho_up) / (rho_down + rho_up) + 1)^(1 // 3)) - 0.123093127730337 * ifelse(-(-rho_down + rho_up) / (rho_down + rho_up) + 1 <= params.zeta_threshold, params.zeta_threshold^(4 // 3), (-(-rho_down + rho_up) / (rho_down + rho_up) + 1)^(4 // 3)) / (rho_down + rho_up)^(2 // 3)) + ifelse((rho_down + rho_up) * ((-rho_down + rho_up) / (rho_down + rho_up) + 1) / 2 <= params.dens_threshold, 0, -0.369279383191011 * (rho_down + rho_up)^(1 // 3) * ifelse((-rho_down + rho_up) / (rho_down + rho_up) + 1 <= params.zeta_threshold, 0, (-4 // 3 * (-rho_down + rho_up) / (rho_down + rho_up)^2 - 4 // 3 / (rho_down + rho_up)) * ((-rho_down + rho_up) / (rho_down + rho_up) + 1)^(1 // 3)) - 0.123093127730337 * ifelse((-rho_down + rho_up) / (rho_down + rho_up) + 1 <= params.zeta_threshold, params.zeta_threshold^(4 // 3), ((-rho_down + rho_up) / (rho_down + rho_up) + 1)^(4 // 3)) / (rho_down + rho_up)^(2 // 3))) + ifelse((rho_down + rho_up) * (-(-rho_down + rho_up) / (rho_down + rho_up) + 1) / 2 <= params.dens_threshold, 0, -0.369279383191011 * (rho_down + rho_up)^(1 // 3) * ifelse(-(-rho_down + rho_up) / (rho_down + rho_up) + 1 <= params.zeta_threshold, params.zeta_threshold^(4 // 3), (-(-rho_down + rho_up) / (rho_down + rho_up) + 1)^(4 // 3))) + ifelse((rho_down + rho_up) * ((-rho_down + rho_up) / (rho_down + rho_up) + 1) / 2 <= params.dens_threshold, 0, -0.369279383191011 * (rho_down + rho_up)^(1 // 3) * ifelse((-rho_down + rho_up) / (rho_down + rho_up) + 1 <= params.zeta_threshold, params.zeta_threshold^(4 // 3), ((-rho_down + rho_up) / (rho_down + rho_up) + 1)^(4 // 3)))
end


end # module