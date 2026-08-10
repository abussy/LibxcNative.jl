module LibxcNativeAMDGPUExt

using LibxcNative
using AMDGPU

# This extension is loaded when AMDGPU.jl is available.  LibxcNative's generic
# AbstractArray kernels already use map!/map, so AMDGPU's ROCArray dispatch
# is picked up automatically once AMDGPU (and its map! overloads) are loaded.

# Provide GPU transfer methods for the test harness in test/compare_references.jl.
if isdefined(Main, :to_device) && isdefined(Main, :to_host)
    Main.to_device(x::Array) = AMDGPU.ROCArray(x)
    Main.to_device(x::AMDGPU.ROCArray) = x
    Main.to_host(x::AMDGPU.ROCArray) = collect(x)
end

end
