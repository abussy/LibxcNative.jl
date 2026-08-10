using LibxcNative
using Test

# Define CPU fallbacks for to_device/to_host before any GPU package can load.
include("compare_references.jl")

# ---------------------------------------------------------------------------
# GPU backend selection.  Usage:
#   Pkg.test("LibxcNative")                       # CPU tests
#   Pkg.test("LibxcNative"; test_args=["amdgpu"]) # AMDGPU/ROCArray tests
#   Pkg.test("LibxcNative"; test_args=["cuda"])   # NVIDIA/CuArray tests
# ---------------------------------------------------------------------------
backend = lowercase(get(ARGS, 1, "cpu"))
if backend == "amdgpu"
    using AMDGPU
    if !AMDGPU.functional()
        @warn "AMDGPU backend requested but AMDGPU.functional() == false; falling back to CPU"
        backend = "cpu"
    end
elseif backend == "cuda"
    using CUDA
    if !CUDA.functional()
        @warn "CUDA backend requested but CUDA.functional() == false; falling back to CPU"
        backend = "cpu"
    end
elseif backend != "cpu"
    error("Unknown test backend '$backend'. Use 'cpu', 'cuda', or 'amdgpu'.")
end

@testset verbose=true "LibxcNative.jl ($backend)" begin
    @testset verbose=true "API compatibility" begin
        test_api()
    end
    @testset verbose=true "CPU vs libxc references" begin
        test_against_references()
    end
end
