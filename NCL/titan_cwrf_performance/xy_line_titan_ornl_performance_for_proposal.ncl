load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "/nas/lgchen/lib/NCL/self_defined.ncl"


begin
    setfileoption("bin", "ReadByteOrder" , "BigEndian")
    setfileoption("bin", "WriteByteOrder", "BigEndian")

    ; CPU_NUM    = (/64, 128, 192, 256, 320/)
    ; N_CPU_CASE = dimsizes(CPU_NUM)
    ; walltime   = (/1*60.0+42.0+35.0/60, 58.0+41.0/60, 46.0+9.0/60, 39.0 + 24.0/60, 35.0 + 54.0/60/)
    ; ; walltime = (/102.58, 58.68, 46.15, 39.4, 35.9/)
    ; mem        = (/10136, 10140, 10128, 10144, 10148/)
    ; vmem       = (/77588, 80360, 77588, 77584, 77748/)

    ; CPU_NUM    = (/32, 64, 96, 128, 160, 192, 224, 256, 288, 320/)
    ; N_CPU_CASE = dimsizes(CPU_NUM)  ; 10

    CPU_NUM    = (/32, 64, 96, 128, 160, 192, 224, 256/)
    N_CPU_CASE = dimsizes(CPU_NUM)  ; 8

    ; walltime_us_io   = (/3*60+18+17.0/60, 1*60.0+42.0+35.0/60, 1*60+19+5.0/60, 58.0+41.0/60, 55+20.0/60  \
    ;     , 46.0+9.0/60, 52+55.0/60, 39.0 + 24.0/60, 48+29.0/60, 35.0 + 54.0/60/)
    ; walltime_us_io = (/198.28, 102.58, 79.08, 58.68, 55.33, 46.15, 52.92, 39.4, 48.48, 35.9/)
    walltime_us_io = (/198.28, 102.58, 79.08, 58.68, 55.33, 46.15, 52.92, 39.4/)

    ; walltime_us_noio = (/1.0e20 (32cpu), 99 + 2.0/60 (64cpu), 71 + 54.0/60 (96cpu), 54 + 48.0/60 (128cpu), 46 + 52.0/60 (160cpu)  \
    ;     , 41 + 22.0/60 (192cpu), 37 + 28.0/60 (224cpu), 33+47.0/60 (256cpu), 31+12.0/60 (288cpu), 28+48.0/60 (320cpu)/)
    ; walltime_us_noio = (/1.0e20, 99 + 2.0/60, 71 + 54.0/60, 54 + 48.0/60, 46 + 52.0/60, 41 + 22.0/60, 37 + 28.0/60, 33+47.0/60, 31+12.0/60, 28+48.0/60/)
      walltime_us_noio = (/1.0e20, 99 + 2.0/60, 71 + 54.0/60, 54 + 48.0/60, 46 + 52.0/60, 41 + 22.0/60, 37 + 28.0/60, 33+47.0/60/)
      ; walltime_us_noio = (/1.0e20, 99.03, 71.9, 54.8, 46.87, 41.37, 37.47, 33.78/)

    ; walltime_cn_io   = (/115 + 12.0/60 (160cpu), 103 + 2.0/60 (192cpu), 93 + 12.0/60(224cpu), 85 + 10.0/60 (256cpu), 77 + 54.0/60 (288cpu), 73 + 42.0/60 (320cpu)/)

    ; walltime_cn_noio = (/1.0e20 (32cpu), 2*(115 + 31.0/60) (64cpu), 2*(77+55.0/60) (96cpu), 1.0e20 (128cpu), 98 + 37.0/60 (160cpu)  \
    ;     , 86 + 42.0/60 (192cpu), 77 + 34.0/60(224cpu), 69 + 5.0/60 (256cpu), 62 + 28.0/60 (288cpu), 57 + 17.0/60 (320cpu)/)
    ; walltime_cn_noio = (/1.0e20, 2*(115 + 31.0/60), 2*(77+55.0/60), 2*(62+18.0/60), 98 + 37.0/60  \
    ;     , 86 + 42.0/60, 77 + 34.0/60, 69 + 5.0/60, 62 + 28.0/60, 57 + 17.0/60/)
    ; walltime_cn_noio = (/1.0e20, 2*(115 + 31.0/60), 2*(77+55.0/60), 2*(62+18.0/60), 98 + 37.0/60  \
    ;     , 86 + 42.0/60, 77 + 34.0/60, 69 + 5.0/60/)
    walltime_cn_noio = (/1.0e20, 231.03, 155.83, 124.6, 98.62  \
        , 86.7, 77.57, 69.08/)

    walltime = new((/3, 8/), "float", 1.0e20)
    walltime(0, :) = walltime_us_io
    walltime(1, :) = walltime_us_noio
    walltime(2, :) = walltime_cn_noio


    ; PLOTTING
    load "/nas/lgchen/lib/NCL/res_settings.ncl"

    wks_pdf = gsn_open_wks("pdf", "titan_cwrf_performance")

    plot_pdf = new (1, graphic)


    res_1d@gsnDraw  = False
    res_1d@gsnFrame = False
    res_1d@txFont   = "Helvetica"
    ; res_1d@tfDoNDCOverlay = True  ; DataTransform = False; NDCViewport = True; NDCDataExtent

    res_1d@vpHeightF = 0.3  ; 0.4  ;0.2  ; 0.3 ; 0.6  ; change aspect ratio of plot
    res_1d@vpWidthF  = 0.3  ; 0.9  ;0.8  ; 0.5 ; 0.4

    ; res_1d@xyLineThicknesses = (/2.0, 2.0/)
    res_1d@xyLineThicknessF = 2.0
    ; res_1d@xyDashPatterns   = (/0, 1/)
    delete(res_1d@xyLineColors)
    res_1d@xyLineColors     = (/"black", "blue", "red"/)


    ; tickmark
    res_1d@tmYROn                  = False
    res_1d@tmXTOn                  = False
    res_1d@tmYLMinorOn             = False
    res_1d@tmXBMinorOn             = False
    res_1d@tmXBMajorLengthF        = 0.005
    res_1d@tmYLMajorLengthF        = 0.005
    res_1d@tmXBMajorOutwardLengthF = -0.002
    res_1d@tmYLMajorOutwardLengthF = -0.002
    res_1d@tmXBLabelDeltaF         = -1.2
    res_1d@tmYLLabelDeltaF         = -1.2
    res_1d@tmXBLabelFontHeightF    = 0.01
    res_1d@tmYLLabelFontHeightF    = 0.01
    res_1d@tmXBMode                = "Explicit"  ; "Manual"
    res_1d@tmYLMode                = "Manual"    ; "Explicit"

    ; res_1d@trXMinF          = 0
    ; res_1d@trXMaxF          = 29*12 - 1
    ; res_1d@tmXBTickStartF   = 0
    ; res_1d@tmXBTickEndF     = 29*12 - 1
    ; res_1d@tmXBTickSpacingF = 0.2

    delete(res_1d@tmXBValues)
    delete(res_1d@tmXBLabels)
    res_1d@tmXBValues = ispan(0, 9, 1)
    res_1d@tmXBLabels = (/"32", "64", "96", "128", "160", "192", "224", "256", "288", "320"/)


    ; add a legend
    res_1d@pmLegendDisplayMode    = "Always"  ; "Never"

    res_1d@pmLegendSide           = "Top"  ; "Bottom"
    res_1d@pmLegendParallelPosF   = 0.6   ; 0.8   ; 0.75   ; move units right
    res_1d@pmLegendOrthogonalPosF = -0.5  ; -0.4  ; -0.3  ; -0.2   ; -0.5  ; -0.7  ; more neg = down
    res_1d@pmLegendWidthF         = 0.04  ; 0.06  ; 0.08  ; 0.10  ; 0.2
    res_1d@pmLegendHeightF        = 0.06  ; 0.10  ; 0.05  ; 0.16 ; 0.5
    res_1d@lgLabelFontHeightF     = 0.01  ; 0.006 ; 0.02
    res_1d@lgPerimOn              = False     ; no box around
    delete(res_1d@xyExplicitLegendLabels)
    ; res_1d@xyExplicitLegendLabels = (/" US (195*138*36, IO)", " US (195*138*36)", " China (301*251*36)"/)  ; legend labels
    res_1d@xyExplicitLegendLabels = (/" D30km (195*138*36, IO)", " D30km (195*138*36)", " D18km (301*251*36)"/)  ; legend labels
    res_1d@lgItemOrder          = (/2, 1, 0/)


    ; res_1d@gsnCenterStringFontHeightF = 0.02
    res_1d@gsnLeftStringFontHeightF = 0.015
    res_1d@tiXAxisFontHeightF    = 0.01  ; 0.02
    res_1d@tiYAxisFontHeightF    = 0.01  ; 0.02

    max_walltime = max(walltime)
    min_walltime = min(walltime)

    res_1d@trYMinF          = 0    ; 20   ; 30   ; 0.8*min_walltime  ; 1.0  ; 0.0
    res_1d@trYMaxF          = 250  ; 200  ; 110  ; 1.2*max_walltime  ; 6.0  ; 1.2*rmse_max
    res_1d@tmYLTickStartF   = 50    ; 20   ; for "Manual"
    ; res_1d@tmYLTickEndF   = 1.0
    res_1d@tmYLTickSpacingF = 50   ; 30   ; 20.0
    ; res_1d@tmYLValues     = (/4, 8, 12/)  ; for "Explicit" @tmXBMode, not showing the labels

    res_1d@trXMinF          = 0.0
    res_1d@trXMaxF          = 7  ; 9  ; 4
    res_1d@tmXBTickStartF   = 0  ; 0.0
    res_1d@tmXBTickEndF     = 7  ; 9  ; 4  ; 28*12 - 1
    res_1d@tmXBTickSpacingF = 1
    ; res_1d@tmXBValues     = (/0.0, 0.2, 0.4, 0.6, 0.8, 1.0/)  ; for "Explicit" @tmXBMode

    res_1d@gsnLeftString = "CWRF performance"
    res_1d@tiYAxisString = "CPU time (minute)"
    res_1d@tiXAxisString = "CPU number"
    plot_pdf(0) = gsn_csm_y(wks_pdf, walltime, res_1d)

    gsn_panel(wks_pdf, plot_pdf, (/1, 1/), res_panel)
end
