# GGA evaluation kernels.

function evaluate_gga!(func::Functional, params::NamedTuple, n_spin::Int,
                       rho::AbstractMatrix, sigma::AbstractMatrix,
                       out_zk, out_vrho, out_vsigma)
    n_points = size(rho, 2)
    T = eltype(rho)
    f_zk   = get_kernel(func, Val(:zk))
    f_up   = get_kernel(func, Val(:vrho_up))
    f_down = get_kernel(func, Val(:vrho_down))
    f_aa   = get_kernel(func, Val(:vsigma_aa))
    f_ab   = get_kernel(func, Val(:vsigma_ab))
    f_bb   = get_kernel(func, Val(:vsigma_bb))

    if n_spin == 1
        r  = selectdim(rho, 1, 1)
        s  = selectdim(sigma, 1, 1)
        if out_zk !== nothing
            zk_out = reshape(out_zk, n_points)
            f_zk = get_kernel(func, Val(:zk_unp))
            map!(zk_out, r, s) do ri, si
                f_zk(params, ri, si)
            end
        end
        if out_vrho !== nothing
            v = selectdim(reshape(out_vrho, 1, n_points), 1, 1)
            f_vrho = get_kernel(func, Val(:vrho_unp))
            map!(v, r, s) do ri, si
                f_vrho(params, ri, si)
            end
        end
        if out_vsigma !== nothing
            v = selectdim(reshape(out_vsigma, 1, n_points), 1, 1)
            f_vsigma = get_kernel(func, Val(:vsigma_unp))
            map!(v, r, s) do ri, si
                f_vsigma(params, ri, si)
            end
        end
    else
        ru = selectdim(rho, 1, 1)
        rd = selectdim(rho, 1, 2)
        saa = selectdim(sigma, 1, 1)
        sab = selectdim(sigma, 1, 2)
        sbb = selectdim(sigma, 1, 3)
        if out_zk !== nothing
            zk_out = reshape(out_zk, n_points)
            map!(zk_out, ru, rd, saa, sab, sbb) do rui, rdi, saai, sabi, sbbi
                rui_c = max(rui, zero(T))
                rdi_c = max(rdi, zero(T))
                f_zk(params, rui_c, rdi_c, saai, sabi, sbbi)
            end
        end
        if out_vrho !== nothing
            v = reshape(out_vrho, 2, n_points)
            map!(selectdim(v, 1, 1), ru, rd, saa, sab, sbb) do rui, rdi, saai, sabi, sbbi
                rui_c = max(rui, zero(T))
                rdi_c = max(rdi, zero(T))
                f_up(params, rui_c, rdi_c, saai, sabi, sbbi)
            end
            map!(selectdim(v, 1, 2), ru, rd, saa, sab, sbb) do rui, rdi, saai, sabi, sbbi
                rui_c = max(rui, zero(T))
                rdi_c = max(rdi, zero(T))
                f_down(params, rui_c, rdi_c, saai, sabi, sbbi)
            end
        end
        if out_vsigma !== nothing
            v = reshape(out_vsigma, 3, n_points)
            map!(selectdim(v, 1, 1), ru, rd, saa, sab, sbb) do rui, rdi, saai, sabi, sbbi
                rui_c = max(rui, zero(T))
                rdi_c = max(rdi, zero(T))
                f_aa(params, rui_c, rdi_c, saai, sabi, sbbi)
            end
            map!(selectdim(v, 1, 2), ru, rd, saa, sab, sbb) do rui, rdi, saai, sabi, sbbi
                rui_c = max(rui, zero(T))
                rdi_c = max(rdi, zero(T))
                f_ab(params, rui_c, rdi_c, saai, sabi, sbbi)
            end
            map!(selectdim(v, 1, 3), ru, rd, saa, sab, sbb) do rui, rdi, saai, sabi, sbbi
                rui_c = max(rui, zero(T))
                rdi_c = max(rdi, zero(T))
                f_bb(params, rui_c, rdi_c, saai, sabi, sbbi)
            end
        end
    end
    return nothing
end
