; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "/global/u2/t/tjling/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "/global/u2/t/tjling/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "/global/u2/t/tjling/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

    DATA_SIM_DIR  = "./data" 
    DATA_OBS_FILE = "/scratch/scratchdirs/lgchen/data/obs_qiao/LAND_OCEAN.pr_rate_monthly.1993" 
                
    MONTH     = (/ "May", "Jun", "Jul" /)
    MONTH_DIG = (/ "05", "06", "07" /)
    DOFM      = (/ 31, 30, 31 /)  ; try to use array and then loop to simplify the code
    
    NAPR    = 5
    NREF    = 3
    APR_VAR = (/"APR_AS", "APR_GR", "APR_MC", "APR_ST", "APR_W"/)
    REF_NAME = (/"REF: OBS-RAINNC (NONNEGATIVE)", "REF: OBS-RAINNC (COULD BE NEGATIVE)", "REF: OBS"/)

    NMON = 3   ; in the order as defined
    NX   = 195
    NY   = 138
 
    obs        = new ((/NMON, NY, NX/), "float")
    obs_rainnc = new ((/NMON, NY, NX/), "float")
    rain       = new ((/NMON, NY, NX/), "float")
    rainc      = new ((/NMON, NY, NX/), "float")
    rainnc     = new ((/NMON, NY, NX/), "float")
    obs        = 0.0
    obs_rainnc = 0.0
    rain       = 0.0
    rainc      = 0.0
    rainnc     = 0.0

    apr        = new ((/NMON,       NAPR, NY, NX/), "float")
    apr_weight = new ((/NMON, NREF, NAPR, NY, NX/), "float")
    apr        = 0.0
    apr_weight = 0.0 

    data_tmp   = new ((/NY, NX/), "float")
    data_tmp   = 0.0

    setfileoption("bin","ReadByteOrder","BigEndian")

    ; observation
    do i = 0, NMON - 1
        obs(i, :, :) = fbindirread(DATA_OBS_FILE, i + 4, (/ NY, NX /), "float")
    end do    

    start_day = 1
    ; mon_rec_start = (/0 , 30, 60/)
    ; mon_rec_end   = (/29, 59, 90/)
    mon_rec   = (/0, 30, 60, 91/)
    do i = 0, NMON - 1
        do j = mon_rec(i), mon_rec(i+1) - 1
            data_tmp = fbindirread(DATA_SIM_DIR + "/" + "OBS-RAINNC_19930502-19930731_g3_xing_wjet.bin"  \
                     , j, (/NY, NX/), "float")
            obs_rainnc(i, :, :) = obs_rainnc(i, :, :) + data_tmp(:, :)

            data_tmp = fbindirread(DATA_SIM_DIR + "/" + "daily_RAIN_cu3-g3_xing_wjet_19930502-19930731.bin"  \
                     , j, (/NY, NX/), "float")
            rain(i, :, :) = rain(i, :, :) + data_tmp(:, :)

            data_tmp = fbindirread(DATA_SIM_DIR + "/" + "daily_RAINC_cu3-g3_xing_wjet_19930502-19930731.bin"  \
                     , j, (/NY, NX/), "float")
            rainc(i, :, :) = rainc(i, :, :) + data_tmp(:, :)

            data_tmp = fbindirread(DATA_SIM_DIR + "/" + "daily_RAINNC_cu3-g3_xing_wjet_19930502-19930731.bin"  \
                     , j, (/NY, NX/), "float")
            rainnc(i, :, :) = rainnc(i, :, :) + data_tmp(:, :)

            data_tmp = fbindirread(DATA_SIM_DIR + "/" + "daily_APR_AS_cu3-g3_xing_wjet_19930502-19930731.bin"  \
                     , j, (/NY, NX/), "float")
            apr(i, 0, :, :) = apr(i, 0, :, :) + data_tmp(:, :)

            data_tmp = fbindirread(DATA_SIM_DIR + "/" + "daily_APR_GR_cu3-g3_xing_wjet_19930502-19930731.bin"  \
                     , j, (/NY, NX/), "float")
            apr(i, 1, :, :) = apr(i, 1, :, :) + data_tmp(:, :)

            data_tmp = fbindirread(DATA_SIM_DIR + "/" + "daily_APR_MC_cu3-g3_xing_wjet_19930502-19930731.bin"  \
                     , j, (/NY, NX/), "float")
            apr(i, 2, :, :) = apr(i, 2, :, :) + data_tmp(:, :)

            data_tmp = fbindirread(DATA_SIM_DIR + "/" + "daily_APR_ST_cu3-g3_xing_wjet_19930502-19930731.bin"  \
                     , j, (/NY, NX/), "float")
            apr(i, 3, :, :) = apr(i, 3, :, :) + data_tmp(:, :)

            data_tmp = fbindirread(DATA_SIM_DIR + "/" + "daily_APR_W_cu3-g3_xing_wjet_19930502-19930731.bin"  \
                     , j, (/NY, NX/), "float")
            apr(i, 4, :, :) = apr(i, 4, :, :) + data_tmp(:, :)
        end do

        obs_rainnc(i, :, :) = obs_rainnc(i, :, :) / (mon_rec(i+1) - mon_rec(i))
        rain      (i, :, :) = rain      (i, :, :) / (mon_rec(i+1) - mon_rec(i))
        rainc     (i, :, :) = rainc     (i, :, :) / (mon_rec(i+1) - mon_rec(i))
        rainnc    (i, :, :) = rainnc    (i, :, :) / (mon_rec(i+1) - mon_rec(i)) 
        
        do j = 0, NAPR - 1
            apr(i, j, :, :) = apr(i, j, :, :) / (mon_rec(i+1) - mon_rec(i))
        end do 

        if (i .eq. 0)
            ; do j = 0, NAPR - 1
            ;     apr_weight(i, 0, j, :, :) = fbindirread(DATA_SIM_DIR + "/ref_obs-rainnc-nonneg/May/weight.bin"  \
            ;                               , j, (/NY, NX/), "float")
            ;     apr_weight(i, 1, j, :, :) = fbindirread(DATA_SIM_DIR + "/ref_obs-rainnc-neg/May/weight.bin"  \
            ;                               , j, (/NY, NX/), "float")
            ;     apr_weight(i, 2, j, :, :) = fbindirread(DATA_SIM_DIR + "/ref_obs/May/weight.bin"  \
            ;                               , j, (/NY, NX/), "float")               
            ; end do

            apr_weight(i, 0, :, :, :) = fbindirread(DATA_SIM_DIR + "/ref_obs-rainnc-nonneg/May/weight.bin"  \
                                      , 0, (/NAPR, NY, NX/), "float")
            apr_weight(i, 1, :, :, :) = fbindirread(DATA_SIM_DIR + "/ref_obs-rainnc-neg/May/weight.bin"  \
                                      , 0, (/NAPR, NY, NX/), "float")
            apr_weight(i, 2, :, :, :) = fbindirread(DATA_SIM_DIR + "/ref_obs/May/weight.bin"  \
                                      , 0, (/NAPR, NY, NX/), "float")
        end if
        if (i .eq. 1)
            apr_weight(i, 0, :, :, :) = fbindirread(DATA_SIM_DIR + "/ref_obs-rainnc-nonneg/Jun/weight.bin"  \
                                      , 0, (/NAPR, NY, NX/), "float")
            apr_weight(i, 1, :, :, :) = fbindirread(DATA_SIM_DIR + "/ref_obs-rainnc-neg/Jun/weight.bin"  \
                                      , 0, (/NAPR, NY, NX/), "float")
            apr_weight(i, 2, :, :, :) = fbindirread(DATA_SIM_DIR + "/ref_obs/Jun/weight.bin"  \
                                      , 0, (/NAPR, NY, NX/), "float")
        end if        
        if (i .eq. 2)
            apr_weight(i, 0, :, :, :) = fbindirread(DATA_SIM_DIR + "/ref_obs-rainnc-nonneg/Jul/weight.bin"  \
                                      , 0, (/NAPR, NY, NX/), "float")
            apr_weight(i, 1, :, :, :) = fbindirread(DATA_SIM_DIR + "/ref_obs-rainnc-neg/Jul/weight.bin"  \
                                      , 0, (/NAPR, NY, NX/), "float")
            apr_weight(i, 2, :, :, :) = fbindirread(DATA_SIM_DIR + "/ref_obs/Jul/weight.bin"  \
                                      , 0, (/NAPR, NY, NX/), "float")
        end if 
    end do

    apr_weight = apr_weight > 0.0
    apr_weight = apr_weight < 1.0

    ; do i = 0, NMON - 1
    ;     do j = 0, NREF - 1
    ;         do k = 0, NAPR - 1
    ;             do m = 0, NY - 1
    ;                 do n = 0, NX - 1
    ;                     if (apr_weight(i, j, k, m, n) .lt. 1.0e-10) then
    ;                         apr_weight(i, j, k, m, n) = 0.0
    ;                     end if
    ;                 end do
    ;             end do
    ;         end do
    ;     end do
    ; end do

    ; DRAWING

    wks_pdf = gsn_open_wks("pdf", "APR_WEIGHT_MJJ_1993_2")  ; ncgm(1), ps(up to 15), pdf(1), x11
    gsn_define_colormap(wks_pdf, "gui_default")  ; default: "hlu_default", 32 colors; gui_default: 24 colors
                                                 ; predefined color map: 87 in all; use named colors (around 752) 
                                                 ; and RGB triplets to create your own color map/table

    res                = True
    res@gsnDraw        = False  ; False  ; the graphics in question will not be drawn when the gsn function is called
    res@gsnFrame       = False  ; False  ; the frame will not be advanced when the gsn function is called
    res@txFont         = "Helvetica"  ; specifies the font used for the "TextItem" when txFontQuality is set 
                                      ; to "High", 31 fonts which are categorized into 2 types: stroked using 
                                      ; lines or filled as areas
    res@tfDoNDCOverlay = True  ; DataTransform = False; NDCViewport = True; NDCDataExtent
        
    res@mpLimitMode       = "Corners" ; This resource of type NhlTMapLimitMode specifies how MapTransformation 
                                      ; determines the extent of the projected globe that is mapped into the 
                                      ; viewport area. 8 possible settings. 
    res@mpLeftCornerLatF  = 15.22807  ; with "Corners" option above, MapTransformation maps into the viewport 
                                      ; a rectangular area with one corner at the point mpLeftCornerLatF and 
                                      ; mpLeftCornerLonF, and the opposite corner at the point mpRightCornerLatF 
                                      ; and mpRightCornerLonF.
    res@mpLeftCornerLonF  = -120.7703 
    res@mpRightCornerLatF = 49.03231  ; latitude
    res@mpRightCornerLonF = -52.39819 ; longitude

    res@pmTickMarkDisplayMode = "Always"                  ; This resource of type NhlTAnnotationDisplayMode 
                                                          ; determines whether the plot object displays a TickMark object 
    res@mpFillOn              = False                     ; switch for drawing of MapPlot area fill
    res@mpOutlineDrawOrder    = "PostDraw"                ; This resource of type NhlTDrawOrder determines when 
                                                          ; MapPlot area outlines are drawn relative to other 
                                                          ; elements of the plot
    res@mpOutlineBoundarySets = "GeophysicalAndUSStates"  ; MapPlot will draw area outlines for geophysical features: 
                                                          ; continents, oceans, islands, and inland water areas; as 
                                                          ; well as the states of U.S.

    res@mpProjection        = "LambertConformal"          ; defines the projection used for the map transformation, 17 in all
    res@mpLambertParallel1F = 60.                         ; for lambert conformal projection
    res@mpLambertParallel2F = 30.
    res@mpLambertMeridianF  = -95.5                       ; central meridian (line of longitude in degrees) of lambert 
                                                          ; conformal projection

    res@cnLineLabelsOn    = False ; if contour line labels will or will not appear in the contour plot
    res@cnFillOn          = True  ; whether the areas between contour levels are filled with a solid color
                                  ; if it's on, you can choose between three fill methods by setting the resource cnFillMode 
    res@cnLinesOn         = False ; no contour lines will appear in the contour plot, regardless of the values contained in 
                                  ; the cnLevelFlags array resource 
    res@gsnSpreadColors   = True  ; If set to True when calling any gsn function that produces vectors and/or contours, 
                                  ; then the colors used will be spread across the whole color map. the color range is
                                  ; determined by gsnSpreadColorStart and gsnSpreadColorEnd
    res@lbLabelAutoStride = True  ; If true, LabelBar labels are checked for overlap before being drawn. If overlap would  
                                  ; otherwise occur, a stride is set through the labels such that overlap will be avoided.

    res@lbOrientation            = "Vertical" ; whether the labelbar boxes are arranged horizontally in a row or vertically in a column.
    res@pmLabelBarOrthogonalPosF = -0.01 ; move label bar closer. pmLabelBarOrthogonalPosF sets the coordinate of the 
                                         ; base location of the LabelBar object annotation orthogonal to the current pmLabelBarSide.
    res@lbLabelStride            = 2  ; Determines which labels actually are rendered the LabelBar is drawn. For example, 
                                      ; if the stride is set to 2, only every other label will be drawn, starting with the first label.

    res@gsnAddCyclic = False  ; For geo-referenced data, a longitude cyclic point is added as a default to ensure a gap 
                              ; is not plotted at the Greenwich Meridian. This resource only applies to gsn_csm plotting 
                              ; routines that overlay data on a map.
    ; res@tfDoNDCOverlay = True ; 

    plot_pdf_ref = new (6 , graphic)
    plot_pdf_wgt = new (20, graphic)

    dayofmon = 30

    print ("before drawing ...")

    do i = 0, NMON - 1
        res@gsnRightString = MONTH(i) 

        res@cnLevelSelectionMode = "ManualLevels"  ; four methods for selecting the contour intervals displayed in a plot,
                                                   ; AutomaticLevels, ManualLevels, ExplicitLevels, EqualSpacedLevels

        res@cnLevelSpacingF = 1.0  
        res@cnMinLevelValF  = 0.0  
        res@cnMaxLevelValF  = 16.0 

        res@gsnLeftString = "OBS"
        print ("before drawing obs ...")
        plot_pdf_ref(0)   = gsn_csm_contour_map(wks_pdf, obs       (i, :, :), res)
        res@gsnLeftString = "RAIN"
        print ("before drawing rain ...")
        plot_pdf_ref(2)   = gsn_csm_contour_map(wks_pdf, rain      (i, :, :), res)
        res@gsnLeftString = "RAINC"
        print ("before drawing rainc ...")
        plot_pdf_ref(3)   = gsn_csm_contour_map(wks_pdf, rainc     (i, :, :), res)
        res@gsnLeftString = "RAINNC"
        print ("before drawing rainnc ...")
        plot_pdf_ref(4)   = gsn_csm_contour_map(wks_pdf, rainnc    (i, :, :), res)

        res@cnLevelSpacingF = 1.0  
        res@cnMinLevelValF  = -10.0  
        res@cnMaxLevelValF  = 10.0

        res@gsnLeftString = "OBS - RAINNC"
        print ("before drawing obs - rainnc ...")
        plot_pdf_ref(1)   = gsn_csm_contour_map(wks_pdf, obs_rainnc(i, :, :), res)
        ; plot_pdf_ref(1)   = gsn_csm_contour_map(wks_pdf, obs(i, :, :) - rainnc(i, :, :), res)

        print ("before gsn_panel for ref ...")
        gsn_panel(wks_pdf, plot_pdf_ref, (/ 3, 2 /), False)

 
        res@cnLevelSpacingF = 1.0  
        res@cnMinLevelValF  = 0.0  
        res@cnMaxLevelValF  = 16.0 

        do j = 0, 4
            res@gsnLeftString = APR_VAR(j)
            print ("before drawing apr ...")
            plot_pdf_wgt(4*j) = gsn_csm_contour_map(wks_pdf, apr(i, j, :, :), res)          
        end do

        res@cnLevelSpacingF = 0.05
        res@cnMinLevelValF  = 0.0  
        res@cnMaxLevelValF  = 1.0 

        do k = 0, NREF - 1
            do j = 0, 4
                res@gsnLeftString = REF_NAME(k) + APR_VAR(j)
                print ("before drawing apr_weight ...")
                ; print (apr_weight(i, k, j, :, :))
                plot_pdf_wgt(4*j + k + 1) = gsn_csm_contour_map(wks_pdf, apr_weight(i, k, j, :, :), res)
            end do
        end do

        print ("before gsn_panel for apr_weight  ...")
        gsn_panel(wks_pdf, plot_pdf_wgt, (/ 5, 4 /), False)

    end do  
end
