; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "/global/u2/t/tjling/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "/global/u2/t/tjling/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "/global/u2/t/tjling/lib/ncarg/nclscripts/csm/contributed.ncl"

load "/global/u1/l/lgchen/lib/NCL/self_defined.ncl"


begin
    VAR_NM = (/"PR", "T2MAX", "T2MIN"/)
    N_VAR  = dimsizes(VAR_NM)

    DIR_DATA = "/global/scratch/sd/lgchen/data/ECHAM2CWRF/AMIP10/tmp_out"
    FN_VAR   = (/"1993_JJA_PR_daily.bin", "1993_JJA_T2MAX_daily.bin", "1993_JJA_T2MIN_daily.bin"/)

    NX   = 195
    NY   = 138
 
    var = new ((/N_VAR, NY, NX/), "float", 1.0e20)
    var = 0.0


    setfileoption("bin", "ReadByteOrder" , "BigEndian")
    setfileoption("bin", "WriteByteOrder", "BigEndian")

    rec_num = 30  ; for july 1
    do i_var = 0, N_VAR - 1
        var(i_var, :, :) = fbindirread(DIR_DATA + "/" + FN_VAR(i_var), rec_num, (/NY, NX/), "float")
    end do
    var(1:2, :, :) = var(1:2, :, :) - 273.15


    ; PLOTTING
    load "/global/u1/l/lgchen/lib/NCL/res_settings.ncl"

    wks_pdf = gsn_open_wks("pdf", "ECHAM2CWRF_June01")  ; ncgm(1), ps(up to 15), pdf(1), x11 
    ; gsn_define_colormap(wks_pdf, "gui_default") 
    gsn_merge_colormaps(wks_pdf, "gui_default", "posneg_1")

    res_2d@gsnSpreadColorStart = 2
    res_2d@gsnSpreadColorEnd   = 23

    var_min_level_val = (/0.0 , -10.0, -10.0/)
    var_max_level_val = (/16.0, 35.0 , 35.0 /)
    var_level_spacing = (/1.0 , 2.0  , 2.0  /)

    plot_pdf = new (3, graphic)

    res_2d@cnLevelSelectionMode = "ManualLevels"  

    res_2d@gsnRightString = "June 1, 1993"

    do i_var = 0, N_VAR - 1
        res_2d@cnMinLevelValF  = var_min_level_val(i_var)
        res_2d@cnMaxLevelValF  = var_max_level_val(i_var)
        res_2d@cnLevelSpacingF = var_level_spacing(i_var)

        res_2d@gsnLeftString = VAR_NM(i_var)

        plot_pdf(i_var) = gsn_csm_contour_map(wks_pdf, var(i_var, 14:123, 14:180), res_2d)
    end do    
    gsn_panel(wks_pdf, plot_pdf, (/3, 1/), False)
end
