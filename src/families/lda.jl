# LDA evaluation kernels.

function evaluate_lda!(mod::Module, params::NamedTuple, n_spin::Int,
                       rho::AbstractMatrix, out_zk, out_vrho)
    n_points = size(rho, 2)

    if n_spin == 1
        r = selectdim(rho, 1, 1)
        if out_zk !== nothing
            f_zk = mod.zk
            zk_out = reshape(out_zk, n_points)
            map!(zk_out, r) do ri
                f_zk(params, ri / 2, ri / 2)
            end
        end
        if out_vrho !== nothing
            f_up = mod.vrho_up
            f_down = mod.vrho_down
            v = selectdim(reshape(out_vrho, 1, n_points), 1, 1)
            map!(v, r) do ri
                (f_up(params, ri / 2, ri / 2) + f_down(params, ri / 2, ri / 2)) / 2
            end
        end
    else
        ru = selectdim(rho, 1, 1)
        rd = selectdim(rho, 1, 2)
        if out_zk !== nothing
            f_zk = mod.zk
            zk_out = reshape(out_zk, n_points)
            map!(zk_out, ru, rd) do rui, rdi
                f_zk(params, rui, rdi)
            end
        end
        if out_vrho !== nothing
            f_up = mod.vrho_up
            f_down = mod.vrho_down
            v = reshape(out_vrho, 2, n_points)
            map!(selectdim(v, 1, 1), ru, rd) do rui, rdi
                f_up(params, rui, rdi)
            end
            map!(selectdim(v, 1, 2), ru, rd) do rui, rdi
                f_down(params, rui, rdi)
            end
        end
    end
    return nothing
end
