# meta-GGA evaluation kernels.

function evaluate_mgga!(func::Functional, params::NamedTuple, n_spin::Int,
                        rho::AbstractMatrix, sigma::AbstractMatrix,
                        lapl::Union{AbstractMatrix,Nothing},
                        tau::Union{AbstractMatrix,Nothing},
                        out_zk, out_vrho, out_vsigma, out_vlapl, out_vtau,
                        needs_lapl::Bool, needs_tau::Bool)
    if n_spin == 1
        return evaluate_mgga_unp!(func, params, rho, sigma, lapl, tau,
                                  out_zk, out_vrho, out_vsigma, out_vlapl, out_vtau,
                                  needs_lapl, needs_tau)
    else
        return evaluate_mgga_pol!(func, params, rho, sigma, lapl, tau,
                                  out_zk, out_vrho, out_vsigma, out_vlapl, out_vtau,
                                  needs_lapl, needs_tau)
    end
end

function evaluate_mgga_unp!(func::Functional, params::NamedTuple,
                            rho::AbstractMatrix, sigma::AbstractMatrix,
                            lapl::Union{AbstractMatrix,Nothing},
                            tau::Union{AbstractMatrix,Nothing},
                            out_zk, out_vrho, out_vsigma, out_vlapl, out_vtau,
                            needs_lapl::Bool, needs_tau::Bool)
    n_points = size(rho, 2)
    

    r = selectdim(rho, 1, 1)
    s = selectdim(sigma, 1, 1)
    l = needs_lapl ? selectdim(lapl, 1, 1) : nothing
    t = needs_tau  ? selectdim(tau, 1, 1)  : nothing

    f_zk    = get_kernel(func, Val(:zk_unp))
    f_vrho  = get_kernel(func, Val(:vrho_unp))
    f_vsig  = get_kernel(func, Val(:vsigma_unp))
    f_vlapl = get_kernel(func, Val(:vlapl_unp))
    f_vtau  = get_kernel(func, Val(:vtau_unp))

    if out_zk !== nothing
        zk_out = reshape(out_zk, n_points)
        if needs_lapl && needs_tau
            map!(zk_out, r, s, l, t) do ri, si, li, ti
                f_zk(params, ri, si, li, ti)
            end
        elseif needs_tau
            map!(zk_out, r, s, t) do ri, si, ti
                f_zk(params, ri, si, ti)
            end
        elseif needs_lapl
            map!(zk_out, r, s, l) do ri, si, li
                f_zk(params, ri, si, li)
            end
        else
            map!(zk_out, r, s) do ri, si
                f_zk(params, ri, si)
            end
        end
    end

    if out_vrho !== nothing
        v = selectdim(reshape(out_vrho, 1, n_points), 1, 1)
        if needs_lapl && needs_tau
            map!(v, r, s, l, t) do ri, si, li, ti
                f_vrho(params, ri, si, li, ti)
            end
        elseif needs_tau
            map!(v, r, s, t) do ri, si, ti
                f_vrho(params, ri, si, ti)
            end
        elseif needs_lapl
            map!(v, r, s, l) do ri, si, li
                f_vrho(params, ri, si, li)
            end
        else
            map!(v, r, s) do ri, si
                f_vrho(params, ri, si)
            end
        end
    end

    if out_vsigma !== nothing
        v = selectdim(reshape(out_vsigma, 1, n_points), 1, 1)
        if needs_lapl && needs_tau
            map!(v, r, s, l, t) do ri, si, li, ti
                f_vsig(params, ri, si, li, ti)
            end
        elseif needs_tau
            map!(v, r, s, t) do ri, si, ti
                f_vsig(params, ri, si, ti)
            end
        elseif needs_lapl
            map!(v, r, s, l) do ri, si, li
                f_vsig(params, ri, si, li)
            end
        else
            map!(v, r, s) do ri, si
                f_vsig(params, ri, si)
            end
        end
    end

    if out_vlapl !== nothing
        v = selectdim(reshape(out_vlapl, 1, n_points), 1, 1)
        if needs_tau
            map!(v, r, s, l, t) do ri, si, li, ti
                f_vlapl(params, ri, si, li, ti)
            end
        elseif needs_lapl
            map!(v, r, s, l) do ri, si, li
                f_vlapl(params, ri, si, li)
            end
        else
            map!(v, r, s) do ri, si
                f_vlapl(params, ri, si)
            end
        end
    end

    if out_vtau !== nothing
        v = selectdim(reshape(out_vtau, 1, n_points), 1, 1)
        if needs_lapl
            map!(v, r, s, l, t) do ri, si, li, ti
                f_vtau(params, ri, si, li, ti)
            end
        else
            map!(v, r, s, t) do ri, si, ti
                f_vtau(params, ri, si, ti)
            end
        end
    end

    return nothing
end

function evaluate_mgga_pol!(func::Functional, params::NamedTuple,
                            rho::AbstractMatrix, sigma::AbstractMatrix,
                            lapl::Union{AbstractMatrix,Nothing},
                            tau::Union{AbstractMatrix,Nothing},
                            out_zk, out_vrho, out_vsigma, out_vlapl, out_vtau,
                            needs_lapl::Bool, needs_tau::Bool)
    n_points = size(rho, 2)
    

    f_zk       = get_kernel(func, Val(:zk))
    f_vrho_up  = get_kernel(func, Val(:vrho_up))
    f_vrho_dn  = get_kernel(func, Val(:vrho_down))
    f_vsig_aa  = get_kernel(func, Val(:vsigma_aa))
    f_vsig_ab  = get_kernel(func, Val(:vsigma_ab))
    f_vsig_bb  = get_kernel(func, Val(:vsigma_bb))
    f_vlapl_up = get_kernel(func, Val(:vlapl_up))
    f_vlapl_dn = get_kernel(func, Val(:vlapl_down))
    f_vtau_up  = get_kernel(func, Val(:vtau_up))
    f_vtau_dn  = get_kernel(func, Val(:vtau_down))

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
        zk_out = reshape(out_zk, n_points)
        if needs_lapl && needs_tau
            map!(zk_out, ru, rd, saa, sab, sbb, la, lb, ta, tb) do rui, rdi, saai, sabi, sbbi, lai, lbi, tai, tbi
                rui_c = max(rui, zero(rui))
                rdi_c = max(rdi, zero(rui))
                f_zk(params, rui_c, rdi_c, saai, sabi, sbbi, lai, lbi, tai, tbi)
            end
        elseif needs_tau
            map!(zk_out, ru, rd, saa, sab, sbb, ta, tb) do rui, rdi, saai, sabi, sbbi, tai, tbi
                rui_c = max(rui, zero(rui))
                rdi_c = max(rdi, zero(rui))
                f_zk(params, rui_c, rdi_c, saai, sabi, sbbi, tai, tbi)
            end
        else
            map!(zk_out, ru, rd, saa, sab, sbb) do rui, rdi, saai, sabi, sbbi
                rui_c = max(rui, zero(rui))
                rdi_c = max(rdi, zero(rui))
                f_zk(params, rui_c, rdi_c, saai, sabi, sbbi)
            end
        end
    end

    if out_vrho !== nothing
        v = reshape(out_vrho, 2, n_points)
        if needs_lapl && needs_tau
            map!(selectdim(v, 1, 1), ru, rd, saa, sab, sbb, la, lb, ta, tb) do rui, rdi, saai, sabi, sbbi, lai, lbi, tai, tbi
                rui_c = max(rui, zero(rui))
                rdi_c = max(rdi, zero(rui))
                f_vrho_up(params, rui_c, rdi_c, saai, sabi, sbbi, lai, lbi, tai, tbi)
            end
            map!(selectdim(v, 1, 2), ru, rd, saa, sab, sbb, la, lb, ta, tb) do rui, rdi, saai, sabi, sbbi, lai, lbi, tai, tbi
                rui_c = max(rui, zero(rui))
                rdi_c = max(rdi, zero(rui))
                f_vrho_dn(params, rui_c, rdi_c, saai, sabi, sbbi, lai, lbi, tai, tbi)
            end
        elseif needs_tau
            map!(selectdim(v, 1, 1), ru, rd, saa, sab, sbb, ta, tb) do rui, rdi, saai, sabi, sbbi, tai, tbi
                rui_c = max(rui, zero(rui))
                rdi_c = max(rdi, zero(rui))
                f_vrho_up(params, rui_c, rdi_c, saai, sabi, sbbi, tai, tbi)
            end
            map!(selectdim(v, 1, 2), ru, rd, saa, sab, sbb, ta, tb) do rui, rdi, saai, sabi, sbbi, tai, tbi
                rui_c = max(rui, zero(rui))
                rdi_c = max(rdi, zero(rui))
                f_vrho_dn(params, rui_c, rdi_c, saai, sabi, sbbi, tai, tbi)
            end
        else
            map!(selectdim(v, 1, 1), ru, rd, saa, sab, sbb) do rui, rdi, saai, sabi, sbbi
                rui_c = max(rui, zero(rui))
                rdi_c = max(rdi, zero(rui))
                f_vrho_up(params, rui_c, rdi_c, saai, sabi, sbbi)
            end
            map!(selectdim(v, 1, 2), ru, rd, saa, sab, sbb) do rui, rdi, saai, sabi, sbbi
                rui_c = max(rui, zero(rui))
                rdi_c = max(rdi, zero(rui))
                f_vrho_dn(params, rui_c, rdi_c, saai, sabi, sbbi)
            end
        end
    end

    if out_vsigma !== nothing
        v = reshape(out_vsigma, 3, n_points)
        if needs_lapl && needs_tau
            map!(selectdim(v, 1, 1), ru, rd, saa, sab, sbb, la, lb, ta, tb) do rui, rdi, saai, sabi, sbbi, lai, lbi, tai, tbi
                rui_c = max(rui, zero(rui))
                rdi_c = max(rdi, zero(rui))
                f_vsig_aa(params, rui_c, rdi_c, saai, sabi, sbbi, lai, lbi, tai, tbi)
            end
            map!(selectdim(v, 1, 2), ru, rd, saa, sab, sbb, la, lb, ta, tb) do rui, rdi, saai, sabi, sbbi, lai, lbi, tai, tbi
                rui_c = max(rui, zero(rui))
                rdi_c = max(rdi, zero(rui))
                f_vsig_ab(params, rui_c, rdi_c, saai, sabi, sbbi, lai, lbi, tai, tbi)
            end
            map!(selectdim(v, 1, 3), ru, rd, saa, sab, sbb, la, lb, ta, tb) do rui, rdi, saai, sabi, sbbi, lai, lbi, tai, tbi
                rui_c = max(rui, zero(rui))
                rdi_c = max(rdi, zero(rui))
                f_vsig_bb(params, rui_c, rdi_c, saai, sabi, sbbi, lai, lbi, tai, tbi)
            end
        elseif needs_tau
            map!(selectdim(v, 1, 1), ru, rd, saa, sab, sbb, ta, tb) do rui, rdi, saai, sabi, sbbi, tai, tbi
                rui_c = max(rui, zero(rui))
                rdi_c = max(rdi, zero(rui))
                f_vsig_aa(params, rui_c, rdi_c, saai, sabi, sbbi, tai, tbi)
            end
            map!(selectdim(v, 1, 2), ru, rd, saa, sab, sbb, ta, tb) do rui, rdi, saai, sabi, sbbi, tai, tbi
                rui_c = max(rui, zero(rui))
                rdi_c = max(rdi, zero(rui))
                f_vsig_ab(params, rui_c, rdi_c, saai, sabi, sbbi, tai, tbi)
            end
            map!(selectdim(v, 1, 3), ru, rd, saa, sab, sbb, ta, tb) do rui, rdi, saai, sabi, sbbi, tai, tbi
                rui_c = max(rui, zero(rui))
                rdi_c = max(rdi, zero(rui))
                f_vsig_bb(params, rui_c, rdi_c, saai, sabi, sbbi, tai, tbi)
            end
        else
            map!(selectdim(v, 1, 1), ru, rd, saa, sab, sbb) do rui, rdi, saai, sabi, sbbi
                rui_c = max(rui, zero(rui))
                rdi_c = max(rdi, zero(rui))
                f_vsig_aa(params, rui_c, rdi_c, saai, sabi, sbbi)
            end
            map!(selectdim(v, 1, 2), ru, rd, saa, sab, sbb) do rui, rdi, saai, sabi, sbbi
                rui_c = max(rui, zero(rui))
                rdi_c = max(rdi, zero(rui))
                f_vsig_ab(params, rui_c, rdi_c, saai, sabi, sbbi)
            end
            map!(selectdim(v, 1, 3), ru, rd, saa, sab, sbb) do rui, rdi, saai, sabi, sbbi
                rui_c = max(rui, zero(rui))
                rdi_c = max(rdi, zero(rui))
                f_vsig_bb(params, rui_c, rdi_c, saai, sabi, sbbi)
            end
        end
    end

    if out_vlapl !== nothing
        v = reshape(out_vlapl, 2, n_points)
        if needs_tau
            map!(selectdim(v, 1, 1), ru, rd, saa, sab, sbb, la, lb, ta, tb) do rui, rdi, saai, sabi, sbbi, lai, lbi, tai, tbi
                rui_c = max(rui, zero(rui))
                rdi_c = max(rdi, zero(rui))
                f_vlapl_up(params, rui_c, rdi_c, saai, sabi, sbbi, lai, lbi, tai, tbi)
            end
            map!(selectdim(v, 1, 2), ru, rd, saa, sab, sbb, la, lb, ta, tb) do rui, rdi, saai, sabi, sbbi, lai, lbi, tai, tbi
                rui_c = max(rui, zero(rui))
                rdi_c = max(rdi, zero(rui))
                f_vlapl_dn(params, rui_c, rdi_c, saai, sabi, sbbi, lai, lbi, tai, tbi)
            end
        else
            map!(selectdim(v, 1, 1), ru, rd, saa, sab, sbb, la, lb) do rui, rdi, saai, sabi, sbbi, lai, lbi
                rui_c = max(rui, zero(rui))
                rdi_c = max(rdi, zero(rui))
                f_vlapl_up(params, rui_c, rdi_c, saai, sabi, sbbi, lai, lbi)
            end
            map!(selectdim(v, 1, 2), ru, rd, saa, sab, sbb, la, lb) do rui, rdi, saai, sabi, sbbi, lai, lbi
                rui_c = max(rui, zero(rui))
                rdi_c = max(rdi, zero(rui))
                f_vlapl_dn(params, rui_c, rdi_c, saai, sabi, sbbi, lai, lbi)
            end
        end
    end

    if out_vtau !== nothing
        v = reshape(out_vtau, 2, n_points)
        if needs_lapl
            map!(selectdim(v, 1, 1), ru, rd, saa, sab, sbb, la, lb, ta, tb) do rui, rdi, saai, sabi, sbbi, lai, lbi, tai, tbi
                rui_c = max(rui, zero(rui))
                rdi_c = max(rdi, zero(rui))
                f_vtau_up(params, rui_c, rdi_c, saai, sabi, sbbi, lai, lbi, tai, tbi)
            end
            map!(selectdim(v, 1, 2), ru, rd, saa, sab, sbb, la, lb, ta, tb) do rui, rdi, saai, sabi, sbbi, lai, lbi, tai, tbi
                rui_c = max(rui, zero(rui))
                rdi_c = max(rdi, zero(rui))
                f_vtau_dn(params, rui_c, rdi_c, saai, sabi, sbbi, lai, lbi, tai, tbi)
            end
        else
            map!(selectdim(v, 1, 1), ru, rd, saa, sab, sbb, ta, tb) do rui, rdi, saai, sabi, sbbi, tai, tbi
                rui_c = max(rui, zero(rui))
                rdi_c = max(rdi, zero(rui))
                f_vtau_up(params, rui_c, rdi_c, saai, sabi, sbbi, tai, tbi)
            end
            map!(selectdim(v, 1, 2), ru, rd, saa, sab, sbb, ta, tb) do rui, rdi, saai, sabi, sbbi, tai, tbi
                rui_c = max(rui, zero(rui))
                rdi_c = max(rdi, zero(rui))
                f_vtau_dn(params, rui_c, rdi_c, saai, sabi, sbbi, tai, tbi)
            end
        end
    end

    return nothing
end
