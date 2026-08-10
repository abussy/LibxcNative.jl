module LibxcNativeCUDAExt

using LibxcNative
using CUDA

# This extension is loaded when CUDA.jl is available.  LibxcNative's generic
# AbstractArray kernels already use map!/map, so CUDA's CuArray dispatch
# is picked up automatically once CUDA (and its map! overloads) are loaded.

# Provide GPU transfer methods for the test harness in test/compare_references.jl.
if isdefined(Main, :to_device) && isdefined(Main, :to_host)
    Main.to_device(x::Array) = CUDA.CuArray(x)
    Main.to_device(x::CUDA.CuArray) = x
    Main.to_host(x::CUDA.CuArray) = collect(x)
end

end
