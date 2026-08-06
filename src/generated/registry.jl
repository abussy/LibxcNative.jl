# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# ---------------------------------------------------------------------------
# Registry of the functionals generated from upstream libxc sources.
# ---------------------------------------------------------------------------

include("functionals/lda_x.jl")
include("functionals/lda_c_pw.jl")
include("functionals/lda_c_vwn.jl")
include("functionals/lda_xc_teter93.jl")
include("functionals/gga_x_pbe.jl")
include("functionals/gga_c_pbe.jl")
include("functionals/mgga_x_scan.jl")
include("functionals/mgga_c_scan.jl")

struct FunctionalSpec
    family::Symbol
    kind::Symbol
    flags::Vector{Symbol}
    needs_lapl::Bool
    needs_tau::Bool
    references::Vector{@NamedTuple{reference::String, doi::String, bibtex::String, key::String}}
end

const FUNCTIONAL_SPECS = Dict{Symbol, FunctionalSpec}(
    :lda_x => FunctionalSpec(
        :lda, :exchange, [:exc, :vxc], false, false, []
    ),
    :lda_c_pw => FunctionalSpec(
        :lda, :correlation, [:exc, :vxc], false, false, []
    ),
    :lda_c_vwn => FunctionalSpec(
        :lda, :correlation, [:exc, :vxc], false, false, []
    ),
    :lda_xc_teter93 => FunctionalSpec(
        :lda, :exchange_correlation, [:exc, :vxc], false, false, []
    ),
    :gga_x_pbe => FunctionalSpec(
        :gga, :exchange, [:exc, :vxc], false, false, []
    ),
    :gga_c_pbe => FunctionalSpec(
        :gga, :correlation, [:exc, :vxc], false, false, []
    ),
    :mgga_x_scan => FunctionalSpec(
        :mgga, :exchange, [:exc, :vxc, :needs_tau], false, true, []
    ),
    :mgga_c_scan => FunctionalSpec(
        :mgga, :correlation, [:exc, :vxc, :needs_tau], false, true, []
    ),
)

const FUNCTIONAL_MODULES = Dict{Symbol, Module}(
    :lda_x => lda_x,
    :lda_c_pw => lda_c_pw,
    :lda_c_vwn => lda_c_vwn,
    :lda_xc_teter93 => lda_xc_teter93,
    :gga_x_pbe => gga_x_pbe,
    :gga_c_pbe => gga_c_pbe,
    :mgga_x_scan => mgga_x_scan,
    :mgga_c_scan => mgga_c_scan,
)
