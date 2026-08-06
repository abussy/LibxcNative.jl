# GGA evaluation kernels.

function evaluate_gga!(mod::Module, params::NamedTuple, n_spin::Int,
                       rho::AbstractMatrix, sigma::AbstractMatrix,
                       out_zk, out_vrho, out_vsigma)
    n_points = size(rho, 2)

    if n_spin == 1
        r  = selectdim(rho, 1, 1)
        s  = selectdim(sigma, 1, 1)
        if out_zk !== nothing
            f_zk = mod.zk
            zk_out = reshape(out_zk, n_points)
            map!(zk_out, r, s) do ri, si
                gaa = gab = gbb = si / 4
                f_zk(params, ri / 2, ri / 2, gaa, gab, gbb)
            end
        end
        if out_vrho !== nothing
            f_up = mod.vrho_up
            f_down = mod.vrho_down
            v = selectdim(reshape(out_vrho, 1, n_points), 1, 1)
            map!(v, r, s) do ri, si
                gaa = gab = gbb = si / 4
                (f_up(params, ri / 2, ri / 2, gaa, gab, gbb)
                 + f_down(params, ri / 2, ri / 2, gaa, gab, gbb)) / 2
            end
        end
        if out_vsigma !== nothing
            f_aa = mod.vsigma_aa
            f_ab = mod.vsigma_ab
            f_bb = mod.vsigma_bb
            v = selectdim(reshape(out_vsigma, 1, n_points), 1, 1)
            map!(v, r, s) do ri, si
                gaa = gab = gbb = si / 4
                (f_aa(params, ri / 2, ri / 2, gaa, gab, gbb)
                 + f_ab(params, ri / 2, ri / 2, gaa, gab, gbb)
                 + f_bb(params, ri / 2, ri / 2, gaa, gab, gbb)) / 4
            end
        end
    else
        ru = selectdim(rho, 1, 1)
        rd = selectdim(rho, 1, 2)
        saa = selectdim(sigma, 1, 1)
        sab = selectdim(sigma, 1, 2)
        sbb = selectdim(sigma, 1, 3)
        if out_zk !== nothing
            f_zk = mod.zk
            zk_out = reshape(out_zk, n_points)
            map!(zk_out, ru, rd, saa, sab, sbb) do rui, rdi, saai, sabi, sbbi
                f_zk(params, rui, rdi, saai, sabi, sbbi)
            end
        end
        if out_vrho !== nothing
            f_up = mod.vrho_up
            f_down = mod.vrho_down
            v = reshape(out_vrho, 2, n_points)
            map!(selectdim(v, 1, 1), ru, rd, saa, sab, sbb) do rui, rdi, saai, sabi, sbbi
                f_up(params, rui, rdi, saai, sabi, sbbi)
            end
            map!(selectdim(v, 1, 2), ru, rd, saa, sab, sbb) do rui, rdi, saai, sabi, sbbi
                f_down(params, rui, rdi, saai, sabi, sbbi)
            end
        end
        if out_vsigma !== nothing
            f_aa = mod.vsigma_aa
            f_ab = mod.vsigma_ab
            f_bb = mod.vsigma_bb
            v = reshape(out_vsigma, 3, n_points)
            map!(selectdim(v, 1, 1), ru, rd, saa, sab, sbb) do rui, rdi, saai, sabi, sbbi
                f_aa(params, rui, rdi, saai, sabi, sbbi)
            end
            map!(selectdim(v, 1, 2), ru, rd, saa, sab, sbb) do rui, rdi, saai, sabi, sbbi
                f_ab(params, rui, rdi, saai, sabi, sbbi)
            end
            map!(selectdim(v, 1, 3), ru, rd, saa, sab, sbb) do rui, rdi, saai, sabi, sbbi
                f_bb(params, rui, rdi, saai, sabi, sbbi)
            end
        end
    end
    return nothing
end
