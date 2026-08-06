# meta-GGA evaluation kernels.

function evaluate_mgga!(mod::Module, params::NamedTuple, n_spin::Int,
                        rho::AbstractMatrix, sigma::AbstractMatrix,
                        lapl::Union{AbstractMatrix,Nothing}, tau::AbstractMatrix,
                        out_zk, out_vrho, out_vsigma, out_vlapl, out_vtau)
    n_points = size(rho, 2)
    needs_lapl = out_vlapl !== nothing
    needs_tau  = out_vtau !== nothing

    if n_spin == 1
        r = selectdim(rho, 1, 1)
        s = selectdim(sigma, 1, 1)
        l = needs_lapl ? selectdim(lapl, 1, 1) : nothing
        t = needs_tau  ? selectdim(tau, 1, 1)  : nothing

        if out_zk !== nothing
            f_zk = mod.zk
            zk_out = reshape(out_zk, n_points)
            if needs_lapl && needs_tau
                map!(zk_out, r, s, l, t) do ri, si, li, ti
                    gaa = gab = gbb = si / 4
                    la = lb = li / 2
                    ta = tb = ti / 2
                    f_zk(params, ri / 2, ri / 2, gaa, gab, gbb, la, lb, ta, tb)
                end
            elseif needs_tau
                map!(zk_out, r, s, t) do ri, si, ti
                    gaa = gab = gbb = si / 4
                    ta = tb = ti / 2
                    f_zk(params, ri / 2, ri / 2, gaa, gab, gbb, ta, tb)
                end
            else
                map!(zk_out, r, s) do ri, si
                    gaa = gab = gbb = si / 4
                    f_zk(params, ri / 2, ri / 2, gaa, gab, gbb)
                end
            end
        end

        if out_vrho !== nothing
            f_up = mod.vrho_up
            f_down = mod.vrho_down
            v = selectdim(reshape(out_vrho, 1, n_points), 1, 1)
            if needs_lapl && needs_tau
                map!(v, r, s, l, t) do ri, si, li, ti
                    gaa = gab = gbb = si / 4
                    la = lb = li / 2
                    ta = tb = ti / 2
                    (f_up(params, ri / 2, ri / 2, gaa, gab, gbb, la, lb, ta, tb)
                     + f_down(params, ri / 2, ri / 2, gaa, gab, gbb, la, lb, ta, tb)) / 2
                end
            elseif needs_tau
                map!(v, r, s, t) do ri, si, ti
                    gaa = gab = gbb = si / 4
                    ta = tb = ti / 2
                    (f_up(params, ri / 2, ri / 2, gaa, gab, gbb, ta, tb)
                     + f_down(params, ri / 2, ri / 2, gaa, gab, gbb, ta, tb)) / 2
                end
            else
                map!(v, r, s) do ri, si
                    gaa = gab = gbb = si / 4
                    (f_up(params, ri / 2, ri / 2, gaa, gab, gbb)
                     + f_down(params, ri / 2, ri / 2, gaa, gab, gbb)) / 2
                end
            end
        end

        if out_vsigma !== nothing
            f_aa = mod.vsigma_aa
            f_ab = mod.vsigma_ab
            f_bb = mod.vsigma_bb
            v = selectdim(reshape(out_vsigma, 1, n_points), 1, 1)
            if needs_lapl && needs_tau
                map!(v, r, s, l, t) do ri, si, li, ti
                    gaa = gab = gbb = si / 4
                    la = lb = li / 2
                    ta = tb = ti / 2
                    (f_aa(params, ri / 2, ri / 2, gaa, gab, gbb, la, lb, ta, tb)
                     + f_ab(params, ri / 2, ri / 2, gaa, gab, gbb, la, lb, ta, tb)
                     + f_bb(params, ri / 2, ri / 2, gaa, gab, gbb, la, lb, ta, tb)) / 4
                end
            elseif needs_tau
                map!(v, r, s, t) do ri, si, ti
                    gaa = gab = gbb = si / 4
                    ta = tb = ti / 2
                    (f_aa(params, ri / 2, ri / 2, gaa, gab, gbb, ta, tb)
                     + f_ab(params, ri / 2, ri / 2, gaa, gab, gbb, ta, tb)
                     + f_bb(params, ri / 2, ri / 2, gaa, gab, gbb, ta, tb)) / 4
                end
            else
                map!(v, r, s) do ri, si
                    gaa = gab = gbb = si / 4
                    (f_aa(params, ri / 2, ri / 2, gaa, gab, gbb)
                     + f_ab(params, ri / 2, ri / 2, gaa, gab, gbb)
                     + f_bb(params, ri / 2, ri / 2, gaa, gab, gbb)) / 4
                end
            end
        end

        if out_vlapl !== nothing
            f_up = mod.vlapl_up
            f_down = mod.vlapl_down
            v = selectdim(reshape(out_vlapl, 1, n_points), 1, 1)
            if needs_tau
                map!(v, r, s, l, t) do ri, si, li, ti
                    gaa = gab = gbb = si / 4
                    la = lb = li / 2
                    ta = tb = ti / 2
                    (f_up(params, ri / 2, ri / 2, gaa, gab, gbb, la, lb, ta, tb)
                     + f_down(params, ri / 2, ri / 2, gaa, gab, gbb, la, lb, ta, tb)) / 2
                end
            else
                map!(v, r, s, l) do ri, si, li
                    gaa = gab = gbb = si / 4
                    la = lb = li / 2
                    (f_up(params, ri / 2, ri / 2, gaa, gab, gbb, la, lb)
                     + f_down(params, ri / 2, ri / 2, gaa, gab, gbb, la, lb)) / 2
                end
            end
        end

        if out_vtau !== nothing
            f_up = mod.vtau_up
            f_down = mod.vtau_down
            v = selectdim(reshape(out_vtau, 1, n_points), 1, 1)
            if needs_lapl
                map!(v, r, s, l, t) do ri, si, li, ti
                    gaa = gab = gbb = si / 4
                    la = lb = li / 2
                    ta = tb = ti / 2
                    (f_up(params, ri / 2, ri / 2, gaa, gab, gbb, la, lb, ta, tb)
                     + f_down(params, ri / 2, ri / 2, gaa, gab, gbb, la, lb, ta, tb)) / 2
                end
            else
                map!(v, r, s, t) do ri, si, ti
                    gaa = gab = gbb = si / 4
                    ta = tb = ti / 2
                    (f_up(params, ri / 2, ri / 2, gaa, gab, gbb, ta, tb)
                     + f_down(params, ri / 2, ri / 2, gaa, gab, gbb, ta, tb)) / 2
                end
            end
        end

    else
        ru = selectdim(rho, 1, 1)
        rd = selectdim(rho, 1, 2)
        saa = selectdim(sigma, 1, 1)
        sab = selectdim(sigma, 1, 2)
        sbb = selectdim(sigma, 1, 3)
        la = needs_lapl ? selectdim(lapl, 1, 1) : nothing
        lb = needs_lapl ? selectdim(lapl, 1, 2) : nothing
        ta = needs_tau  ? selectdim(tau, 1, 1)  : nothing
        tb = needs_tau  ? selectdim(tau, 1, 2)  : nothing

        if out_zk !== nothing
            f_zk = mod.zk
            zk_out = reshape(out_zk, n_points)
            if needs_lapl && needs_tau
                map!(zk_out, ru, rd, saa, sab, sbb, la, lb, ta, tb) do rui, rdi, saai, sabi, sbbi, lai, lbi, tai, tbi
                    f_zk(params, rui, rdi, saai, sabi, sbbi, lai, lbi, tai, tbi)
                end
            elseif needs_tau
                map!(zk_out, ru, rd, saa, sab, sbb, ta, tb) do rui, rdi, saai, sabi, sbbi, tai, tbi
                    f_zk(params, rui, rdi, saai, sabi, sbbi, tai, tbi)
                end
            else
                map!(zk_out, ru, rd, saa, sab, sbb) do rui, rdi, saai, sabi, sbbi
                    f_zk(params, rui, rdi, saai, sabi, sbbi)
                end
            end
        end

        if out_vrho !== nothing
            f_up = mod.vrho_up
            f_down = mod.vrho_down
            v = reshape(out_vrho, 2, n_points)
            if needs_lapl && needs_tau
                map!(selectdim(v, 1, 1), ru, rd, saa, sab, sbb, la, lb, ta, tb) do rui, rdi, saai, sabi, sbbi, lai, lbi, tai, tbi
                    f_up(params, rui, rdi, saai, sabi, sbbi, lai, lbi, tai, tbi)
                end
                map!(selectdim(v, 1, 2), ru, rd, saa, sab, sbb, la, lb, ta, tb) do rui, rdi, saai, sabi, sbbi, lai, lbi, tai, tbi
                    f_down(params, rui, rdi, saai, sabi, sbbi, lai, lbi, tai, tbi)
                end
            elseif needs_tau
                map!(selectdim(v, 1, 1), ru, rd, saa, sab, sbb, ta, tb) do rui, rdi, saai, sabi, sbbi, tai, tbi
                    f_up(params, rui, rdi, saai, sabi, sbbi, tai, tbi)
                end
                map!(selectdim(v, 1, 2), ru, rd, saa, sab, sbb, ta, tb) do rui, rdi, saai, sabi, sbbi, tai, tbi
                    f_down(params, rui, rdi, saai, sabi, sbbi, tai, tbi)
                end
            else
                map!(selectdim(v, 1, 1), ru, rd, saa, sab, sbb) do rui, rdi, saai, sabi, sbbi
                    f_up(params, rui, rdi, saai, sabi, sbbi)
                end
                map!(selectdim(v, 1, 2), ru, rd, saa, sab, sbb) do rui, rdi, saai, sabi, sbbi
                    f_down(params, rui, rdi, saai, sabi, sbbi)
                end
            end
        end

        if out_vsigma !== nothing
            f_aa = mod.vsigma_aa
            f_ab = mod.vsigma_ab
            f_bb = mod.vsigma_bb
            v = reshape(out_vsigma, 3, n_points)
            if needs_lapl && needs_tau
                map!(selectdim(v, 1, 1), ru, rd, saa, sab, sbb, la, lb, ta, tb) do rui, rdi, saai, sabi, sbbi, lai, lbi, tai, tbi
                    f_aa(params, rui, rdi, saai, sabi, sbbi, lai, lbi, tai, tbi)
                end
                map!(selectdim(v, 1, 2), ru, rd, saa, sab, sbb, la, lb, ta, tb) do rui, rdi, saai, sabi, sbbi, lai, lbi, tai, tbi
                    f_ab(params, rui, rdi, saai, sabi, sbbi, lai, lbi, tai, tbi)
                end
                map!(selectdim(v, 1, 3), ru, rd, saa, sab, sbb, la, lb, ta, tb) do rui, rdi, saai, sabi, sbbi, lai, lbi, tai, tbi
                    f_bb(params, rui, rdi, saai, sabi, sbbi, lai, lbi, tai, tbi)
                end
            elseif needs_tau
                map!(selectdim(v, 1, 1), ru, rd, saa, sab, sbb, ta, tb) do rui, rdi, saai, sabi, sbbi, tai, tbi
                    f_aa(params, rui, rdi, saai, sabi, sbbi, tai, tbi)
                end
                map!(selectdim(v, 1, 2), ru, rd, saa, sab, sbb, ta, tb) do rui, rdi, saai, sabi, sbbi, tai, tbi
                    f_ab(params, rui, rdi, saai, sabi, sbbi, tai, tbi)
                end
                map!(selectdim(v, 1, 3), ru, rd, saa, sab, sbb, ta, tb) do rui, rdi, saai, sabi, sbbi, tai, tbi
                    f_bb(params, rui, rdi, saai, sabi, sbbi, tai, tbi)
                end
            else
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

        if out_vlapl !== nothing
            f_up = mod.vlapl_up
            f_down = mod.vlapl_down
            v = reshape(out_vlapl, 2, n_points)
            if needs_tau
                map!(selectdim(v, 1, 1), ru, rd, saa, sab, sbb, la, lb, ta, tb) do rui, rdi, saai, sabi, sbbi, lai, lbi, tai, tbi
                    f_up(params, rui, rdi, saai, sabi, sbbi, lai, lbi, tai, tbi)
                end
                map!(selectdim(v, 1, 2), ru, rd, saa, sab, sbb, la, lb, ta, tb) do rui, rdi, saai, sabi, sbbi, lai, lbi, tai, tbi
                    f_down(params, rui, rdi, saai, sabi, sbbi, lai, lbi, tai, tbi)
                end
            else
                map!(selectdim(v, 1, 1), ru, rd, saa, sab, sbb, la, lb) do rui, rdi, saai, sabi, sbbi, lai, lbi
                    f_up(params, rui, rdi, saai, sabi, sbbi, lai, lbi)
                end
                map!(selectdim(v, 1, 2), ru, rd, saa, sab, sbb, la, lb) do rui, rdi, saai, sabi, sbbi, lai, lbi
                    f_down(params, rui, rdi, saai, sabi, sbbi, lai, lbi)
                end
            end
        end

        if out_vtau !== nothing
            f_up = mod.vtau_up
            f_down = mod.vtau_down
            v = reshape(out_vtau, 2, n_points)
            if needs_lapl
                map!(selectdim(v, 1, 1), ru, rd, saa, sab, sbb, la, lb, ta, tb) do rui, rdi, saai, sabi, sbbi, lai, lbi, tai, tbi
                    f_up(params, rui, rdi, saai, sabi, sbbi, lai, lbi, tai, tbi)
                end
                map!(selectdim(v, 1, 2), ru, rd, saa, sab, sbb, la, lb, ta, tb) do rui, rdi, saai, sabi, sbbi, lai, lbi, tai, tbi
                    f_down(params, rui, rdi, saai, sabi, sbbi, lai, lbi, tai, tbi)
                end
            else
                map!(selectdim(v, 1, 1), ru, rd, saa, sab, sbb, ta, tb) do rui, rdi, saai, sabi, sbbi, tai, tbi
                    f_up(params, rui, rdi, saai, sabi, sbbi, tai, tbi)
                end
                map!(selectdim(v, 1, 2), ru, rd, saa, sab, sbb, ta, tb) do rui, rdi, saai, sabi, sbbi, tai, tbi
                    f_down(params, rui, rdi, saai, sabi, sbbi, tai, tbi)
                end
            end
        end
    end
    return nothing
end
