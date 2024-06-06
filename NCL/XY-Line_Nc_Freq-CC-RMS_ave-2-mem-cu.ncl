load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
    DATA_DIR  = "/scratch/scratchdirs/lgchen/data/result_data/freq_cc_rms"
    NFILE     = 12
    NCOMBI    = NFILE*(NFILE-1)/2
    FN_MEM    = (/"CTL", "bmj_cwp3", "ctl_scuOff", "cu1", "cu1_ishall0", "run_cu2_bmj", "run_cu4_gd"  \
              ,   "run_cu5_gdl", "run_cu7_zml", "run_cu8_randall", "run_cu9_gfdl", "run_cu10_mit"/)
    FN_ABB    = (/"CTL", "bmj_cwp3", "ctl_scuOff", "nkf", "nkf_ishall0", "bmj", "gd"  \
              ,   "gdl", "zml", "randall", "gfdl", "mit"/)

    DOFM_1993 = (/31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31/)
    NTM       = 12 + 4 + 1
    TM_MEM    = (/"Jan.", "Feb.", "Mar.", "Apr.", "May" , "Jun."  \
              ,   "Jul.", "Aug.", "Sep.", "Oct.", "Nov.", "Dec."  \
              ,   "Spr.", "Sum.", "Aut.", "Win.", "Year"/)
    FREQ_VAR  = (/"FREQ_CC", "FREQ_RMS"/)

    COMBI_MEM = new ((/NFILE*(NFILE-1)/2/), "string")

    cnt_mem = 0

    do i = 0, NFILE - 2
        do j = i + 1, NFILE - 1
            COMBI_MEM(cnt_mem) = FN_ABB(i) + " & " +FN_ABB(j)
            cnt_mem = cnt_mem + 1
        end do
    end do
              
    ; cc_x  = new ((/40/), "float") 
    cc_x  = new (40, "float")
    cc_y  = new ((/NFILE*(NFILE-1)/2, 12+4+1, 40/), "float")
    rms_x = new (40, "float")
    rms_y = new ((/NFILE*(NFILE-1)/2, 12+4+1, 40/), "float") 

    cnt_mem = 0

    do i = 0, NFILE - 2
        do j = i + 1, NFILE - 1
            cnt_tm = 0

            ; for 12 months
            do k = 1, 12
                if (k .le. 9) then
                    fh = addfile(DATA_DIR + "/freq_cc_rms_" + FN_MEM(i) + "-" + FN_MEM(j)  \
                       + "_PR_19930" + k + "01-19930" + k + DOFM_1993(k-1) + ".nc", "r")
                else
                    fh = addfile(DATA_DIR + "/freq_cc_rms_" + FN_MEM(i) + "-" + FN_MEM(j)  \
                       + "_PR_1993" + k + "01-1993" + k + DOFM_1993(k-1) + ".nc", "r")
                end if
                
                if (i .eq. 0 .and. j .eq. 1 .and. k .eq. 1) then
                    cc_x  = fh->$FREQ_VAR(0)$(:, 0)
                    rms_x = fh->$FREQ_VAR(1)$(:, 0)
                end if
                
                cc_y (cnt_mem, cnt_tm, :) = fh->$FREQ_VAR(0)$(:, 1)
                rms_y(cnt_mem, cnt_tm, :) = fh->$FREQ_VAR(1)$(:, 1)

                cnt_tm = cnt_tm + 1
            end do

            ; for 4 seasons
            do k = 1, 4
                sm = 3*(k-1) + 1
                em = 3*k
                if (k .le. 3) then
                    fh = addfile(DATA_DIR + "/freq_cc_rms_" + FN_MEM(i) + "-" + FN_MEM(j)  \
                       + "_PR_19930" + sm + "01-19930" + em + DOFM_1993(em-1) + ".nc", "r")
                else
                    fh = addfile(DATA_DIR + "/freq_cc_rms_" + FN_MEM(i) + "-" + FN_MEM(j)  \
                       + "_PR_1993" + sm + "01-1993" + em + DOFM_1993(em-1) + ".nc", "r")
                end if

                cc_y (cnt_mem, cnt_tm, :) = fh->$FREQ_VAR(0)$(:, 1)
                rms_y(cnt_mem, cnt_tm, :) = fh->$FREQ_VAR(1)$(:, 1)

                cnt_tm = cnt_tm + 1
            end do

            ; for 1 year
            fh = addfile(DATA_DIR + "/freq_cc_rms_" + FN_MEM(i) + "-" + FN_MEM(j)  \
               + "_PR_19930101-19931231" + ".nc", "r")
          
            cc_y (cnt_mem, cnt_tm, :) = fh->$FREQ_VAR(0)$(:, 1)
            rms_y(cnt_mem, cnt_tm, :) = fh->$FREQ_VAR(1)$(:, 1)

            cnt_mem = cnt_mem + 1
        end do 
    end do


    ; DRAWING

    wks_pdf = gsn_open_wks("pdf", "freq_cc_rms_ave-2-mem-cu_1993")      
    ; wks_pdf = gsn_open_wks("ps", "freq_cc_rms_1993")      
    plot_pdf = new (12, graphic)

    res          = True
    res@gsnDraw  = False        ; the graphics in question will not be drawn when the gsn function is called
    res@gsnFrame = False        ; the frame will not be advanced when the gsn function is called
    res@txFont   = "Helvetica"  ; specifies the font used for the "TextItem" when txFontQuality is set 
                                ; to "High", 31 fonts which are categorized into 2 types: stroked using 
                                ; lines or filled as areas
    ; res@tfDoNDCOverlay = True  ; DataTransform = False; NDCViewport = True; NDCDataExtent

    res@vpHeightF = 0.3  ; 0.6  ; change aspect ratio of plot
    res@vpWidthF  = 0.8  ; 0.4

    ; res@xyLineThicknesses = (/2.0, 2.0, 2.0, 2.0, 2.0/)
    res@xyLineThicknessF = 2.0
    res@xyDashPatterns   = (/0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 16/)
    ; res@xyLineColors     = (/"black", "red", "green", "blue", "orange", "purple", "pink", "dark green"  \
    ;                      ,   "dodger blue", "deep sky blue", "dark sea green"/)
    res@xyLineColors     = (/"dark sea green", "red", "green", "blue", "orange", "purple", "pink", "dark green"  \
                         ,   "dodger blue", "deep sky blue", "black"/)

    ; res@gsnRightString   = "MJJ 1993"

    ; tickmark
    res@tmYROn = False  ; Turn off minor ticks
    res@tmXTOn = False  ; Turn off minor ticks
    res@tmYLMinorOn = False  ; Turn off minor ticks
    res@tmXBMinorOn = False  ; Turn off minor ticks
    res@tmXBMajorLengthF = 0.005
    res@tmYLMajorLengthF = 0.005
    res@tmXBMajorOutwardLengthF = -0.002
    res@tmYLMajorOutwardLengthF = -0.002
    res@tmXBLabelDeltaF = -1.2
    res@tmYLLabelDeltaF = -1.2

    ; add a legend
    res@pmLegendDisplayMode    = "Always"  ; turn on legend
    
    ; res@pmLegendSide           = "Bottom"     ; Change location of 
    res@pmLegendSide           = "Top"     ; Change location of 
    res@pmLegendParallelPosF   = 0.8       ; move units right
    res@pmLegendOrthogonalPosF = -0.7      ; more neg = down
    
    ; res@pmLegendWidthF         = 0.20      ; Change width and
    ; res@pmLegendHeightF        = 0.50      ; height of legend.
    ; res@lgLabelFontHeightF     = 0.02      ; change font height
    res@pmLegendWidthF         = 0.08      ; Change width and
    res@pmLegendHeightF        = 0.16      ; height of legend.
    res@lgLabelFontHeightF     = 0.01      ; change font height

    res@lgPerimOn              = True      ; no box around
    ; labels for the legend
    ; res@xyExplicitLegendLabels = (/" G3"," ave", " org-opt", " 0.0", " 0.25", " 0.5", " 0.75", " 1.0"/)
    res@lgItemOrder            = (/10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0/)        
                       
    ; res@gsnCenterStringFontHeightF = 0.02
    res@tiXAxisFontHeightF         = 0.02
    res@tiYAxisFontHeightF         = 0.02

    res@trYMinF = 0
    cc_y_max    = max(cc_y(:, :, 15:))
    rms_y_max   = max(rms_y(:, :, 0:29))

    ; temperary
    cc_y(21, :, :)  = cc_y(0, :, :)
    rms_y(21, :, :) = rms_y(0, :, :)
    COMBI_MEM(21)   = COMBI_MEM(0)

    do i = 0, NTM - 1
        res@gsnRightString = TM_MEM(i)

        do j = 1, 1  ; 5
            res@xyExplicitLegendLabels = COMBI_MEM(11*j : 11*j+10)
            if (j .eq. 0) then
                res@tiYAxisString = "Frequency (%)"
            else
                res@tiYAxisString = ""
            end if

            res@pmLegendDisplayMode = "Never"
            res@tiXAxisString = "Correlation Coefficient"
            res@trYMaxF       = ceil(100*cc_y_max)
            plot_pdf(j)       = gsn_csm_xy(wks_pdf, cc_x(15:), 100*cc_y (11*j : 11*j+10, i, 15:), res)
    
            res@pmLegendDisplayMode = "Always"
            res@tiXAxisString = "RMS Error (mm/day)"
            res@trYMaxF       = ceil(100*rms_y_max)
            ; plot_pdf(j+6)     = gsn_csm_xy(wks_pdf, rms_x(0:29), 100*rms_y(11*j : 11*j+10, i, 0:29), res)
            plot_pdf(j+1)     = gsn_csm_xy(wks_pdf, rms_x(0:29), 100*rms_y(11*j : 11*j+10, i, 0:29), res)
        end do

        gsn_panel(wks_pdf, plot_pdf(1:2), (/2, 1/), False)
    end do

end
