load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
    ; DATA READ-IN AND PROCESSING

    ; REG_NAMES = (/"Central US", "Southeast US", "Atlantic Ocean"/)
    SIM_TIME = "Jul 1993"
    DATA_DIR = "/scratch/scratchdirs/lgchen/projects/PrAt2mOpt_AGU/freq_cc_rms_region/result_data/AnnualReport/final/Jul"
    NFILE    = 9
    FILES    = (/"org-opt_16-mem", "dyn-1-mon_16-mem_sa-1.0", "1-mon_6-mem_sa-1.0",  \
                 "ave_16-mem", "ave_6-mem", "opt_16-mem",  \
                 "opt_6-mem", "pbl-uw", "mp08-thompson_v3.1"/)
    FREQ_VAR = (/"FREQ_CC", "FREQ_RMS"/)
              
    ; cc_x  = new ((/40/), "float") 
    cc_x  = new (40, "float")
    cc_y  = new ((/NFILE, 40/), "float")
    rms_x = new (40, "float")
    rms_y = new ((/NFILE, 40/), "float") 

    ; freq_cc_rms_dir    = "./result_data/CentralUS"
    do i = 0, NFILE - 1
        fh = addfile(DATA_DIR + "/freq_cc_rms_Jul_" + FILES(i) + ".nc", "r")
        if (0 .eq. i) then
            cc_x  = fh->$FREQ_VAR(0)$(:, 0)
            rms_x = fh->$FREQ_VAR(1)$(:, 0)
        end if
        cc_y (i, :) = fh->FREQ_CC (:, 1)
        rms_y(i, :) = fh->FREQ_RMS(:, 1)    
    end do


    ; DRAWING

    wks_pdf = gsn_open_wks("ps", "freq_cc_rms_Jul_final")      
    ; wks_pdf = gsn_open_wks("ps", "freq_cc_rms_1993")      
    plot_pdf = new (2, graphic)

    res          = True
    res@gsnDraw  = False        ; the graphics in question will not be drawn when the gsn function is called
    res@gsnFrame = False        ; the frame will not be advanced when the gsn function is called
    res@txFont   = "Helvetica"  ; specifies the font used for the "TextItem" when txFontQuality is set 
                                ; to "High", 31 fonts which are categorized into 2 types: stroked using 
                                ; lines or filled as areas
    ; res@tfDoNDCOverlay = True  ; DataTransform = False; NDCViewport = True; NDCDataExtent

    res@vpHeightF = 0.30  ; change aspect ratio of plot
    res@vpWidthF  = 0.80


    ; res@xyLineThicknesses = (/2.0, 2.0, 2.0, 2.0, 2.0/)
    res@xyLineThicknessF = 3.0
    ; res@xyDashPatterns   = (/0, 1, 2, 3, 4, 5, 10, 15, 16/)
    res@xyDashPatterns   = (/0, 0, 0, 3, 4, 5, 10, 15, 16/)
    res@xyLineColors     = (/"black", "red", "green", "blue", "orange", "purple", "gold", "dark green", "dark violet"/)

    ; res@gsnRightString   = "MJJ 1993"

    ; tickmark
    res@tmYROn = False  ; Turn off minor ticks
    res@tmXTOn = False  ; Turn off minor ticks
    res@tmYLMinorOn = False  ; Turn off minor ticks
    res@tmXBMinorOn = False  ; Turn off minor ticks
    res@tmXBMajorLengthF = 0.005
    res@tmYLMajorLengthF = 0.005
    res@tmXBMajorOutwardLengthF = -0.002
    res@tmYLMajorOutwardLengthF = -0.002  ; res@tmYLMajorLengthF  ; -0.01
    res@tmXBLabelDeltaF = -1.2
    res@tmYLLabelDeltaF = -1.2

    ; add a legend
    res@pmLegendDisplayMode    = "Always"  ; turn on legend
    
    res@pmLegendSide           = "Top"     ; Change location of 
    res@pmLegendParallelPosF   = 0.8       ; move units right
    res@pmLegendOrthogonalPosF = -0.7      ; more neg = down
    
    res@pmLegendWidthF         = 0.08      ; Change width and
    res@pmLegendHeightF        = 0.16      ; height of legend.
    res@lgLabelFontHeightF     = 0.01      ; change font height
    res@lgPerimOn              = True      ; no box around
    ; labels for the legend
    res@xyExplicitLegendLabels = (/" ENS OPT 16-mem hindcast", " ENS LCR 16-mem forecast", " ENS LCR 6-mem forecast"   \
                               ,   " ENS AVE 16-mem forecast", " ENS AVE 6-mem forecast" , " ENS OPT 16-mem forecast"  \
                               ,   " ENS OPT 6-mem forecast" , " PBL-UW scheme"          , " CTL scheme"/)
                               
    res@gsnCenterStringFontHeightF = 0.02
    res@tiXAxisFontHeightF         = 0.02
    res@tiYAxisFontHeightF         = 0.02

    ; do i = 0, 2
        res@gsnCenterString = SIM_TIME

        ; res@tiMainString = "" 
        res@tiXAxisString = "Correlation Coefficient" 
        res@tiYAxisString = "Frequency (%)" 
        res@pmLegendDisplayMode = "Never"
        plot_pdf(0) = gsn_csm_xy(wks_pdf, cc_x(15:), 100*cc_y(:, 15:), res)

        ; res@tiMainString = "    " 
        res@gsnCenterString = ""
        res@tiXAxisString = "RMS Error (mm/day)" 
        res@tiYAxisString = "Frequency (%)"
        res@pmLegendDisplayMode = "Always" 
        plot_pdf(1) = gsn_csm_xy(wks_pdf, rms_x(0:29), 100*rms_y(:, 0:29), res)
        
        gsn_panel(wks_pdf, plot_pdf, (/2, 1/), False)
    ; end do
end
