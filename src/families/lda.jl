# LDA evaluation kernels.

function evaluate_lda!(func::Functional, params::NamedTuple, n_spin::Int,
                       rho::AbstractMatrix, out_zk, out_vrho)
    if n_spin == 1
        return evaluate_lda_unp!(func, params, rho, out_zk, out_vrho)
    else
        return evaluate_lda_pol!(func, params, rho, out_zk, out_vrho)
    end
end

function evaluate_lda_unp!(func::Functional, params::NamedTuple,
                           rho::AbstractMatrix, out_zk, out_vrho)
    n_points = size(rho, 2)
    

    r = selectdim(rho, 1, 1)
    f_zk   = get_kernel(func, Val(:zk_unp))
    f_vrho = get_kernel(func, Val(:vrho_unp))

    if out_zk !== nothing
        zk_out = reshape(out_zk, n_points)
        map!(zk_out, r) do ri
            f_zk(params, ri)
        end
    end
    if out_vrho !== nothing
        v = selectdim(reshape(out_vrho, 1, n_points), 1, 1)
        map!(v, r) do ri
            f_vrho(params, ri)
        end
    end
    return nothing
end

function evaluate_lda_pol!(func::Functional, params::NamedTuple,
                           rho::AbstractMatrix, out_zk, out_vrho)
    n_points = size(rho, 2)
    

    f_zk   = get_kernel(func, Val(:zk))
    f_up   = get_kernel(func, Val(:vrho_up))
    f_down = get_kernel(func, Val(:vrho_down))
    ru = selectdim(rho, 1, 1)
    rd = selectdim(rho, 1, 2)

    if out_zk !== nothing
        zk_out = reshape(out_zk, n_points)
        map!(zk_out, ru, rd) do rui, rdi
            rui_c = max(rui, zero(rui))
            rdi_c = max(rdi, zero(rui))
            f_zk(params, rui_c, rdi_c)
        end
    end
    if out_vrho !== nothing
        v = reshape(out_vrho, 2, n_points)
        map!(selectdim(v, 1, 1), ru, rd) do rui, rdi
            rui_c = max(rui, zero(rui))
            rdi_c = max(rdi, zero(rui))
            f_up(params, rui_c, rdi_c)
        end
        map!(selectdim(v, 1, 2), ru, rd) do rui, rdi
            rui_c = max(rui, zero(rui))
            rdi_c = max(rdi, zero(rui))
            f_down(params, rui_c, rdi_c)
        end
    end
    return nothing
end
