using LibxcNative
using Test
using JSON

const REF_DIR = joinpath(@__DIR__, "references")

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

    @testset "zk" begin
        @test isapprox(to_host(result.zk), Float64.(expected["zk"]); rtol=1e-10, atol=1e-12)
    end

    for field in ("vrho", "vsigma", "vlapl", "vtau")
        haskey(expected, field) || continue
        @testset "$field" begin
            got = getproperty(result, Symbol(field))
            # For n_spin == 1 LibxcNative returns a vector, for n_spin == 2 a
            # dim × npoints matrix.  Bring both to the same layout as the JSON.
            got_arr = n_spin == 1 ? to_host(vec(got)) : to_host(got)
            ref_arr = Float64.(stack(expected[field]))
            @test isapprox(got_arr, ref_arr; rtol=5e-5, atol=1e-10)
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
end
