using LibxcNative
using Test
using JSON

const REF_DIR = joinpath(@__DIR__, "references")

# Universal tolerance for all reference comparisons.
const ATOL = 1e-15
const RTOL = sqrt(ATOL)

"""Return the sorted list of reference JSON files."""
function reference_files()
    sort(filter(f -> endswith(f, ".json"), readdir(REF_DIR)))
end

"""Load all references as (label, data) tuples, sorted alphabetically.

The label contains the functional name and spin polarization so the test
summary is self-describing.
"""
function load_references()
    map(reference_files()) do f
        data = JSON.parsefile(joinpath(REF_DIR, f))
        name = data["functional"]
        n_spin = data["n_spin"]
        label = "$name (n_spin = $n_spin)"
        label => data
    end
end

"""Read a JSON input field and reshape it to the layout LibxcNative expects.

For n_spin == 2 the JSON stores one vector per grid point; `stack` turns that
into a dim × npoints matrix.  The result is always a CPU `Array{Float64}`;
the caller can move it to a GPU with `to_device` if desired.
"""
parse_input(data, field) = Float64.(stack(data["inputs"][field]))

"""Evaluate a functional and compare all available reference fields."""
function compare_reference(data)
    name = Symbol(data["functional"])
    n_spin = data["n_spin"]
    fun = Functional(name; n_spin=n_spin)

    rho   = to_device(parse_input(data, "rho"))
    sigma = to_device(parse_input(data, "sigma"))
    lapl  = to_device(parse_input(data, "lapl"))
    tau   = to_device(parse_input(data, "tau"))
    result = evaluate(fun; rho=rho, sigma=sigma, lapl=lapl, tau=tau)

    expected = data["expected"]

    # zk (energy per particle) is a direct evaluation.
    @testset "zk" begin
        @test isapprox(to_host(result.zk), Float64.(expected["zk"]); rtol=RTOL, atol=ATOL)
    end

    # Potentials are symbolic derivatives of zk.  The generated code uses
    # different algebraic simplifications than upstream libxc, so small
    # differences accumulate.
    for field in ("vrho", "vsigma", "vlapl", "vtau")
        haskey(expected, field) || continue
        @testset "$field" begin
            got = getproperty(result, Symbol(field))
            # For n_spin == 1 LibxcNative returns a vector, for n_spin == 2 a
            # dim × npoints matrix.  Bring both to the same layout as the JSON.
            got_arr = n_spin == 1 ? to_host(vec(got)) : to_host(got)
            ref_arr = Float64.(stack(expected[field]))
            @test isapprox(got_arr, ref_arr; rtol=RTOL, atol=ATOL)
        end
    end
end

function test_against_references()
    refs = load_references()
    @testset verbose=true "$label" for (label, data) in refs
        compare_reference(data)
    end
end

function test_api()
    @testset "available_functionals" begin
        @test :lda_x in available_functionals()
    end
    @testset "family detection" begin
        @test Functional(:lda_x).family == :lda
        @test Functional(:gga_x_pbe).family == :gga
        @test Functional(:mgga_x_scan).family == :mgga
    end
    @testset "flags" begin
        @test !is_hybrid(Functional(:lda_x))
        @test !is_vv10(Functional(:lda_x))
    end
    @testset "derivatives" begin
        @test supported_derivatives(Functional(:lda_x)) == [0, 1]
        @test supported_derivatives(Functional(:mgga_x_scan)) == [0, 1]
    end
    @testset "error paths" begin
        @test_throws ArgumentError Functional(:lda_x; n_spin=0)
        @test_throws ArgumentError Functional(:lda_x; n_spin=3)
        @test_throws ArgumentError Functional(:nonexistent)
        @test_throws ArgumentError evaluate(Functional(:gga_x_pbe); rho=[1.0])
        @test_throws ArgumentError evaluate(Functional(:mgga_x_scan); rho=[1.0], sigma=[1.0])
        @test_throws ArgumentError evaluate(Functional(:lda_x); rho=[1.0], derivatives=[2])
    end
    @testset "evaluate! in-place" begin
        fun = Functional(:lda_x; n_spin=1)
        n = 10
        rho = Float64[1.0 for _ in 1:n]
        zk = zeros(Float64, n)
        vrho = zeros(Float64, n)
        result = evaluate!(fun; rho=rho, zk=zk, vrho=vrho)
        @test result.zk === zk
        @test result.vrho === vrho
        @test all(!iszero, zk)
        @test all(!iszero, vrho)
    end
end
