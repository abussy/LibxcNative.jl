# LDA evaluation kernels.

function evaluate_lda!(func::Functional, params::NamedTuple, n_spin::Int,
                       rho::AbstractMatrix, out_zk, out_vrho)
    n_points = size(rho, 2)
    T = eltype(rho)

    if n_spin == 1
        r = selectdim(rho, 1, 1)
        if out_zk !== nothing
            zk_out = reshape(out_zk, n_points)
            f_zk = get_kernel(func, Val(:zk_unp))
            map!(zk_out, r) do ri
                f_zk(params, ri)
            end
        end
        if out_vrho !== nothing
            v = selectdim(reshape(out_vrho, 1, n_points), 1, 1)
            f_vrho = get_kernel(func, Val(:vrho_unp))
            map!(v, r) do ri
                f_vrho(params, ri)
            end
        end
    else
        f_zk   = get_kernel(func, Val(:zk))
        f_up   = get_kernel(func, Val(:vrho_up))
        f_down = get_kernel(func, Val(:vrho_down))
        ru = selectdim(rho, 1, 1)
        rd = selectdim(rho, 1, 2)
        if out_zk !== nothing
            zk_out = reshape(out_zk, n_points)
            map!(zk_out, ru, rd) do rui, rdi
                rui_c = max(rui, zero(T))
                rdi_c = max(rdi, zero(T))
                f_zk(params, rui_c, rdi_c)
            end
        end
        if out_vrho !== nothing
            v = reshape(out_vrho, 2, n_points)
            map!(selectdim(v, 1, 1), ru, rd) do rui, rdi
                rui_c = max(rui, zero(T))
                rdi_c = max(rdi, zero(T))
                f_up(params, rui_c, rdi_c)
            end
            map!(selectdim(v, 1, 2), ru, rd) do rui, rdi
                rui_c = max(rui, zero(T))
                rdi_c = max(rdi, zero(T))
                f_down(params, rui_c, rdi_c)
            end
        end
    end
    return nothing
end
