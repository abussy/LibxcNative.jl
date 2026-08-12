module LibxcNativeCUDAExt

using LibxcNative
using CUDA

LibxcNative.to_device(x::Array) = CUDA.CuArray(x)
LibxcNative.to_device(x::CUDA.CuArray) = x
LibxcNative.to_host(x::CUDA.CuArray) = collect(x)

end
