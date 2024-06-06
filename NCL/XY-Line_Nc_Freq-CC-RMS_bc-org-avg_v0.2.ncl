load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
    DIR_DATA_ROOT = "/global/scratch/sd/lgchen/projects/PrEnsOpt/data/out"
    ; Bias-Corrected Parameter Table: (training_wdw, forecast_lean, exp, plot)
    N_BCPT        = 32
    BCPT          = (/(/"30", "1" , "False", "True" /), (/"30", "1" , "True", "True" /)  \
                  ,   (/"20", "1" , "False", "True" /), (/"20", "1" , "True", "True" /)  \
                  ,   (/"20", "2" , "False", "True" /), (/"20", "2" , "True", "True" /)  \
                  ,   (/"20", "3" , "False", "True" /), (/"20", "3" , "True", "True" /)  \
                  ,   (/"20", "7" , "False", "True" /), (/"20", "7" , "True", "True" /)  \
                  ,   (/"20", "10", "False", "True" /), (/"20", "10", "True", "True" /)  \
                  ,   (/"14", "1" , "False", "True" /), (/"14", "1" , "True", "True" /)  \
                  ,   (/"14", "2" , "False", "True" /), (/"14", "2" , "True", "True" /)  \
                  ,   (/"14", "3" , "False", "True" /), (/"14", "3" , "True", "True" /)  \
                  ,   (/"14", "7" , "False", "True" /), (/"14", "7" , "True", "True" /)  \
                  ,   (/"14", "10", "False", "True" /), (/"14", "10", "True", "True" /)  \
                  ,   (/"10", "1" , "False", "True" /), (/"10", "1" , "True", "True" /)  \
                  ,   (/"10", "2" , "False", "True" /), (/"10", "2" , "True", "True" /)  \
                  ,   (/"10", "3" , "False", "True" /), (/"10", "3" , "True", "True" /)  \
                  ,   (/"10", "7" , "False", "True" /), (/"10", "7" , "True", "True" /)  \
                  ,   (/"10", "10", "False", "True" /), (/"10", "10", "True", "True" /)/)


    N_SCHM    = 40  ; 40 = 1 + 8 + 11 + 7 + 8 + 5 
    ; FN_SCHM = (/"ctl_bc-exp", "ctl_bc-noexp", "ave", "ctl", "sf_eri", "sf_narr", "cu_g3", "bl_qnse"/)
    ; IDX_SF_ERI = 35
    FN_SCHM   = (/"sf_eri", "ctl", "bl_acm", "bl_boulac", "bl_gfs", "bl_myj", "bl_orooff", "bl_qnse"  \
              ,   "bl_uw", "bl_ysu", "cu_bmj", "cu_bmjcwp3", "cu_csu", "cu_g3", "cu_gd"     \
              ,   "cu_gfdl", "cu_mit", "cu_nkf", "cu_rad_feedbackoff", "cu_shallow_off"     \
              ,   "cu_zml", "mp_lin", "mp_morrison", "mp_thompson", "mp_wdm6", "mp_wsm5"    \
              ,   "mp_wsm6", "mp_zhao", "ra_aerosoloff", "ra_cam", "ra_cawcr", "ra_cccma"   \
              ,   "ra_doclavg", "ra_fuliou", "ra_gfdl", "ra_rrtmg",  "sf_narr"     \  ; eri, narr
              ,   "sf_noah", "sf_px", "sf_uomoff"/)

    CYR       = "1993"
    N_SSN     = 4
    SSN       = (/(/"MAM", "03", "01", "05", "31"/)  \
              ,   (/"JJA", "06", "01", "08", "31"/)  \
              ,   (/"SON", "09", "01", "11", "30"/)  \
              ,   (/"DJF", "01", "01", "02", "28"/)/)

    N_VAR     = 2
    FREQ_VAR  = (/"FREQ_CC", "FREQ_RMS"/)

    N_SEG     = 40   
    x_var     = new ((/N_VAR,                        N_SEG/), "float")
    y_var_bc  = new ((/N_VAR, N_BCPT, N_SCHM, N_SSN, N_SEG/), "float")
    y_var_avg = new ((/N_VAR,                 N_SSN, N_SEG/), "float")
    y_var_org = new ((/N_VAR,         N_SCHM, N_SSN, N_SEG/), "float")
    y_var_max = new ((/N_VAR/), "float")
    y_plot    = new ((/N_VAR,     1 + N_SCHM, N_SSN, N_SEG/), "float")
    y_2       = new ((/2, N_SEG/), "float")
    ; cc_x    = new (N_SEG, "float")
    ; cc_y    = new ((/N_SCHM, N_SSN, N_SEG/), "float")
    ; rms_x   = new (N_SEG, "float")
    ; rms_y   = new ((/N_SCHM, N_SSN, N_SEG/), "float")

    ; get avg CC and RMSE
    DIR_DATA = "freq_cc_rms_1993_bc-org_ln-1"
    do i_ssn = 0, N_SSN - 1
        fh = addfile(DIR_DATA_ROOT + "/" + DIR_DATA + "/freq_cc_rms_ave_" + CYR  \
            + SSN(i_ssn, 1) + SSN(i_ssn, 2) + "-" + CYR + SSN(i_ssn, 3) + SSN(i_ssn, 4)  \
            + ".nc", "r")

        do i_var = 0, N_VAR - 1
            y_var_avg(i_var, i_ssn, :) = fh->$FREQ_VAR(i_var)$(:, 1) 
        end do
    end do 

    ; get org CC and RMSE
    DIR_DATA = "freq_cc_rms_1993_org"
    do i_schm = 0, N_SCHM - 1
        do i_ssn = 0, N_SSN - 1
            fh = addfile(DIR_DATA_ROOT + "/" + DIR_DATA + "/freq_cc_rms_"      \
                + FN_SCHM(i_schm) + "_" + CYR + SSN(i_ssn, 1) + SSN(i_ssn, 2)  \
                + "-" + CYR + SSN(i_ssn, 3) + SSN(i_ssn, 4) + ".nc", "r")
                
            if (i_schm .eq. 0 .and. i_ssn .eq. 0) then
                do i_var = 0, N_VAR - 1
                    x_var(i_var, :) = fh->$FREQ_VAR(i_var)$(:, 0)
                end do 
            end if

            do i_var = 0, N_VAR - 1
                y_var_org(i_var, i_schm, i_ssn, :) = fh->$FREQ_VAR(i_var)$(:, 1)
            end do
        end do
    end do

    do i_bcpt = 0, N_BCPT - 1
        if (BCPT(i_bcpt, 3) .eq. "True")
            if (BCPT(i_bcpt, 2) .eq. "True")
                print ("using exp, i_bcpt = " + i_bcpt)
                DIR_DATA = "freq_cc_rms_1993_bc/" + BCPT(i_bcpt, 0) + "_" + BCPT(i_bcpt, 1) + "_exp"
            else
                print ("using noexp, i_bcpt = " + i_bcpt)
                DIR_DATA = "freq_cc_rms_1993_bc/" + BCPT(i_bcpt, 0) + "_" + BCPT(i_bcpt, 1) + "_noexp"
            end if
        end if 

        do i_schm = 0, N_SCHM - 1
            do i_ssn = 0, N_SSN - 1
                fh = addfile(DIR_DATA_ROOT + "/" + DIR_DATA + "/freq_cc_rms_"         \
                    + FN_SCHM(i_schm) + "_bc_" + CYR + SSN(i_ssn, 1) + SSN(i_ssn, 2)  \
                    + "-" + CYR + SSN(i_ssn, 3) + SSN(i_ssn, 4) + ".nc", "r")
                    
                if (i_schm .eq. 0 .and. i_ssn .eq. 0) then
                    do i_var = 0, N_VAR - 1
                        x_var(i_var, :) = fh->$FREQ_VAR(i_var)$(:, 0)
                    end do 
                end if

                do i_var = 0, N_VAR - 1
                    y_var_bc(i_var, i_bcpt, i_schm, i_ssn, :) = fh->$FREQ_VAR(i_var)$(:, 1)
                end do
            end do
        end do

    end do


    ; DRAWING

    wks_pdf  = gsn_open_wks("pdf", "freq_cc_rms_1993_bc_org_avg_2")      
    plot_pdf = new (8, graphic)

    res          = True
    res@gsnDraw  = False        
        ; the graphics in question will not be drawn when the gsn function is called
    res@gsnFrame = False        
        ; the frame will not be advanced when the gsn function is called
    res@txFont   = "Helvetica"  
        ; specifies the font used for the "TextItem" when txFontQuality is set to "High",
        ; 31 fonts which are categorized into 2 types: stroked using lines or filled
        ; as areas
    ; res@tfDoNDCOverlay = True  ; DataTransform = False; NDCViewport = True; NDCDataExtent

    res@vpHeightF = 0.3  ; 0.5 ; 0.6  ; change aspect ratio of plot
    res@vpWidthF  = 0.8  ; 0.5 ; 0.4

    ; tickmark
    res@tmYROn                  = False
    res@tmXTOn                  = False
    res@tmYLMinorOn             = False
    res@tmXBMinorOn             = False
    res@tmXBMajorLengthF        = 0.005
    res@tmYLMajorLengthF        = 0.005
    res@tmXBMajorOutwardLengthF = -0.002
    res@tmYLMajorOutwardLengthF = -0.002
    res@tmXBLabelDeltaF         = -1.2
    res@tmYLLabelDeltaF         = -1.2

    ; add a legend
    res@pmLegendDisplayMode    = "Never"  ; "Always"; turn on legend
    res@pmLegendSide           = "Top"    ; Change location of the legend
    res@pmLegendParallelPosF   = 0.8      ; move units right
    res@pmLegendOrthogonalPosF = -0.8     ; more neg = down
    res@pmLegendWidthF         = 0.15     ; 0.08  ; 0.20 ; Change width and height of legend.
    res@pmLegendHeightF        = 0.2      ; 0.16  ; 0.50
    res@lgLabelFontHeightF     = 0.015    ; 0.01  ; 0.02 ; change font height
    res@lgPerimOn              = True     ; box around
    ; res@xyExplicitLegendLabels = (/"ctl_bc-exp", "ctl_bc-noexp", "avg", "ctl", "sf_eri"  \
    ;     , "sf_narr", "cu_g3","bl_qnse"/)  ; labels for the legend
    ; res@lgItemOrder            = (/4, 3, 2, 1, 0/)        
                       
    res@tiXAxisFontHeightF     = 0.02
    res@tiYAxisFontHeightF     = 0.02

    res@trYMinF  = 0
    y_var_max(0) = max(y_var_bc(0, :, :, :, 15:  ))
    y_var_max(1) = max(y_var_bc(1, :, :, :, 0 :29))

    res@xyLineThicknesses = (/2.0, 2.0, 2.0, 2.0, 2.0/)
    res@xyDashPatterns    = (/0  , 1  , 2  , 3  , 4  /)
    res@xyLineColors      = (/"red", "green", "blue", "orange", "black"/)
        

    do i_bcpt = 0, N_BCPT/2 - 1
        y_plot(:, 0       , :, :) = y_var_avg(:, :, :)
        y_plot(:, 1:N_SCHM, :, :) = y_var_bc (:, 2*i_bcpt, 0 : N_SCHM - 1, :, :)
        do i_ssn = 0, N_SSN - 1
            res@gsnRightString = SSN(i_ssn, 0)
            res@tiYAxisString  = "Frequency (%)"

            res@pmLegendDisplayMode = "Never"
            res@tiXAxisString       = "Correlation Coefficient"
            res@trYMaxF             = ceil(100*y_var_max(0))
            plot_pdf(2*i_ssn)       = gsn_csm_xy(wks_pdf, x_var(0, 15: ), 100*y_plot(0, :, i_ssn, 15: ), res)

            if (i_ssn .eq. 0)
                if (BCPT(2*i_bcpt, 2) .eq. "False")
                    res@gsnLeftString = BCPT(2*i_bcpt, 0) + "_" + BCPT(2*i_bcpt, 1) + "_noexp"
                else
                    res@gsnLeftString = BCPT(2*i_bcpt, 0) + "_" + BCPT(2*i_bcpt, 1) + "_exp"
                end if
            else
                res@gsnLeftString = ""
            end if
            res@tiXAxisString   = "RMS Error (mm/day)" 
            res@trYMaxF         = ceil(100*y_var_max(1))
            plot_pdf(2*i_ssn+1) = gsn_csm_xy(wks_pdf, x_var(1, 0:29), 100*y_plot(1, :, i_ssn, 0:29), res)
        end do
        gsn_panel(wks_pdf, plot_pdf(:), (/4, 2/), False)

        y_plot(:, 0       , :, :) = y_var_avg(:, :, :)
        y_plot(:, 1:N_SCHM, :, :) = y_var_bc (:, 2*i_bcpt+1, 0:N_SCHM-1, :, :)
        do i_ssn = 0, N_SSN - 1
            res@gsnRightString = SSN(i_ssn, 0)
            res@tiYAxisString  = "Frequency (%)"

            res@pmLegendDisplayMode = "Never"
            res@tiXAxisString       = "Correlation Coefficient"
            res@trYMaxF             = ceil(100*y_var_max(0))
            plot_pdf(2*i_ssn)       = gsn_csm_xy(wks_pdf, x_var(0, 15: ), 100*y_plot(0, :, i_ssn, 15: ), res)

            if (i_ssn .eq. 0)
                if (BCPT(2*i_bcpt+1, 2) .eq. "False")
                    res@gsnLeftString = BCPT(i_bcpt, 0) + "_" + BCPT(i_bcpt, 1) + "_noexp"
                else
                    res@gsnLeftString = BCPT(i_bcpt, 0) + "_" + BCPT(i_bcpt, 1) + "_exp"
                end if
            else
                res@gsnLeftString = ""
            end if
            res@tiXAxisString   = "RMS Error (mm/day)" 
            res@trYMaxF         = ceil(100*y_var_max(1))
            plot_pdf(2*i_ssn+1) = gsn_csm_xy(wks_pdf, x_var(1, 0:29), 100*y_plot(1, :, i_ssn, 0:29), res)
        end do
        gsn_panel(wks_pdf, plot_pdf(:), (/4, 2/), False)

        do i_ssn = 0, N_SSN - 1
            y_plot(:, 0, i_ssn, :) = y_var_avg(:,    i_ssn, :)
            y_plot(:, 1, i_ssn, :) = y_var_org(:, 0, i_ssn, :)  ; sf_eri_org
        end do

        do i_schm = 0, N_SCHM - 1  ; 0
            do i_ssn = 0, N_SSN - 1
                y_plot(:, 2, i_ssn, :) = y_var_org(:,             i_schm, i_ssn, :)
                y_plot(:, 3, i_ssn, :) = y_var_bc (:, 2*i_bcpt  , i_schm, i_ssn, :)
                y_plot(:, 4, i_ssn, :) = y_var_bc (:, 2*i_bcpt+1, i_schm, i_ssn, :)
            end do

            do i_ssn = 0, N_SSN - 1
                res@gsnRightString = SSN(i_ssn, 0)
                res@tiYAxisString  = "Frequency (%)"

                res@pmLegendDisplayMode = "Never"
                res@tiXAxisString       = "Correlation Coefficient"
                res@trYMaxF             = ceil(100*y_var_max(0))
                plot_pdf(2*i_ssn)       = gsn_csm_xy(wks_pdf, x_var(0, 15: ), 100*y_plot(0, 0:4, i_ssn, 15: ), res)

                if (i_ssn .eq. 0)
                    res@gsnLeftString = BCPT(i_bcpt, 0) + "_" + BCPT(i_bcpt, 1)

                    res@pmLegendDisplayMode = "Always"

                    res@xyExplicitLegendLabels = (/"avg", "sf_eri_org", FN_SCHM(i_schm) + "_org"  \
                        , FN_SCHM(i_schm) + "_bc_noexp", FN_SCHM(i_schm) + "_bc_exp"/)  ; labels for the legend
                    res@lgItemOrder            = (/4, 3, 2, 1, 0/)
                else
                    res@gsnLeftString = ""

                    res@pmLegendDisplayMode = "Never"
                end if
                res@tiXAxisString   = "RMS Error (mm/day)" 
                res@trYMaxF         = ceil(100*y_var_max(1))
                plot_pdf(2*i_ssn+1) = gsn_csm_xy(wks_pdf, x_var(1, 0:29), 100*y_plot(1, 0:4, i_ssn, 0:29), res)
            end do
            gsn_panel(wks_pdf, plot_pdf(:), (/4, 2/), False)
        end do

    end do

    ; do i_ssn = 0, N_SSN - 1
    ;     res@gsnRightString = SSN(i_ssn, 0)
    ;     res@tiYAxisString  = "Frequency (%)"

    ;     res@pmLegendDisplayMode = "Never"
    ;     res@tiXAxisString       = "Correlation Coefficient"
    ;     res@trYMaxF             = ceil(100*y_var_max(0))
    ;     plot_pdf(2*i_ssn)       = gsn_csm_xy(wks_pdf, x_var(0, 15: ), 100*y_var_bc(0, :, i_ssn, 15: ), res)

    ;     if (i_ssn .eq. 0)
    ;         res@pmLegendDisplayMode = "Always"
    ;     else
    ;         res@pmLegendDisplayMode = "Never"
    ;     end if
    ;     res@tiXAxisString       = "RMS Error (mm/day)" 
    ;     res@trYMaxF             = ceil(100*y_var_max(1))
    ;     plot_pdf(2*i_ssn+1)     = gsn_csm_xy(wks_pdf, x_var(1, 0:29), 100*y_var_bc(1, :, i_ssn, 0:29), res)
    ; end do
    ; gsn_panel(wks_pdf, plot_pdf(:), (/4, 2/), False)

    ; do i_schm = 1, N_SCHM - 1
    ;     res@gsnLeftString = FN_SCHM(i_schm)

    ;     do i_ssn = 0, N_SSN - 1
    ;         res@gsnRightString  = SSN(i_ssn, 0)
    ;         res@tiYAxisString   = "Frequency (%)"

    ;         res@tiXAxisString   = "Correlation Coefficient"
    ;         res@trYMaxF         = ceil(100*y_var_max(0))
    ;         y_2(0, :)           = y_var_bc(0, 0     , i_ssn, :)
    ;         y_2(1, :)           = y_var_bc(0, i_schm, i_ssn, :)
    ;         plot_pdf(2*i_ssn)   = gsn_csm_xy(wks_pdf, x_var(0, 15: ), 100*y_2(:, 15: ), res)

    ;         res@tiXAxisString   = "RMS Error (mm/day)"
    ;         res@trYMaxF         = ceil(100*y_var_max(1))
    ;         y_2(0, :)           = y_var_bc(1, 0     , i_ssn, :)
    ;         y_2(1, :)           = y_var_bc(1, i_schm, i_ssn, :)
    ;         plot_pdf(2*i_ssn+1) = gsn_csm_xy(wks_pdf, x_var(1, 0:29), 100*y_2(:, 0:29), res)
    ;     end do
    ;     gsn_panel(wks_pdf, plot_pdf(:), (/4, 2/), False)
    ; end do

end
