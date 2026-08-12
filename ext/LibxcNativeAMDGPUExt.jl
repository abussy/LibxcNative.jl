module LibxcNativeAMDGPUExt

using LibxcNative
using AMDGPU

LibxcNative.to_device(x::Array) = AMDGPU.ROCArray(x)
LibxcNative.to_device(x::AMDGPU.ROCArray) = x
LibxcNative.to_host(x::AMDGPU.ROCArray) = collect(x)

end
