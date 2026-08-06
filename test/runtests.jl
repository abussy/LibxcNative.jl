using LibxcNative
using Test

include("compare_references.jl")

@testset verbose=true "LibxcNative.jl" begin
    @testset verbose=true "API compatibility" begin
        test_api()
    end
    @testset verbose=true "CPU vs libxc references" begin
        test_against_references()
    end
end
