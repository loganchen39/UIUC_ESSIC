; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "/global/u2/t/tjling/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "/global/u2/t/tjling/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "/global/u2/t/tjling/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

    DATA_SIM_DIR  = "/scratch/scratchdirs/lgchen/projects/PrAt2mOpt_AGU/nc2bin_daily/result_data/gfdl_1993" 
    DATA_OBS_FILE = "/project/projectdirs/cwrf/cwrf/observation/pr/LAND_OCEAN.pr_rate_monthly.1993" 
                
    MONTH     = (/ "May", "Jun", "Jul" /)
    MONTH_DIG = (/ "05", "06", "07" /)
    DOFM      = (/ 31, 30, 31 /)  ; try to use array and then loop to simplify the code
    
    NTEST     = 3
    TEST_NAME = (/ "cu9-gfdl-sfcbl-0", "cu9-gfdl-sfcbl-4", "cu9-gfdl-tau-3600" /)

    NVAR     = 3
    VAR_NAME = (/"RAIN", "RAINC", "RAINNC"/)

    NMON = 3   ; in the order as defined
    NX   = 195
    NY   = 138

    ; NREC = 31
 
    obs = new ((/NMON, NY, NX/), "float")
    sim = new ((/NTEST, NVAR, NMON, NY, NX/), "float")
    obs = 0.0
    sim = 0.0

    data_tmp = new ((/91, NY, NX/), "float")
    data_tmp = 0.0


    setfileoption("bin","ReadByteOrder","BigEndian")

    ; observation
    do i = 0, NMON - 1
        obs(i, :, :) = fbindirread(DATA_OBS_FILE, i+4, (/ NY, NX /), "float")
    end do

    start_day = 1
    mon_rec   = (/0, 30, 60, 91/)

    do i = 0, NTEST - 1
        do j = 0, NVAR - 1
            data_tmp = fbindirread(DATA_SIM_DIR + "/" + "daily_" + VAR_NAME(j) + "_" + TEST_NAME(i)  \
                     + "_19930502-19930731.bin", 0, (/91, NY, NX/), "float")

            do k = 0, NMON - 1
                sim(i, j, k, :, :) = dim_avg_n(data_tmp(mon_rec(k):mon_rec(k+1)-1, :, :), 0)
            end do
        end do
    end do


    ; DRAWING

    wks_pdf = gsn_open_wks("pdf", "gfdl_test_MJJ1993")  ; ncgm(1), ps(up to 15), pdf(1), x11
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
    ; res@mpLeftCornerLatF  = 15.22807  ; with "Corners" option above, MapTransformation maps into the viewport 
    ;                                   ; a rectangular area with one corner at the point mpLeftCornerLatF and 
    ;                                   ; mpLeftCornerLonF, and the opposite corner at the point mpRightCornerLatF 
    ;                                   ; and mpRightCornerLonF.
    ; res@mpLeftCornerLonF  = -120.7703 
    ; res@mpRightCornerLatF = 49.03231  ; latitude
    ; res@mpRightCornerLonF = -52.39819 ; longitude
    res@mpLeftCornerLatF  = 19.768133
    res@mpLeftCornerLonF  = -118.259
    res@mpRightCornerLatF = 47.4818
    res@mpRightCornerLonF = -60.0576

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

    plot_pdf_rain = new (12, graphic)
    ; plot_pdf_apr  = new (10, graphic)

    dayofmon = 31

    ; print ("before drawing ...")

    do i = 0, NMON - 1

        res@cnLevelSelectionMode = "ManualLevels"  ; four methods for selecting the contour intervals displayed in a plot,
                                                   ; AutomaticLevels, ManualLevels, ExplicitLevels, EqualSpacedLevels

        res@cnLevelSpacingF = 1.0  
        res@cnMinLevelValF  = 0.0  
        res@cnMaxLevelValF  = 16.0 

        res@gsnRightString = MONTH(i)

        varString = "PR"
        res@gsnLeftString = "OBS " + varString
        plot_pdf_rain(0)  = gsn_csm_contour_map(wks_pdf, obs(i, 14:123, 14:180), res)
 
        do j = 0, NVAR - 1
            varString = VAR_NAME(j)
            do k = 0, NTEST - 1
                res@gsnLeftString = VAR_NAME(j) + "  " + TEST_NAME(k)
                plot_pdf_rain((j+1)*3+k) = gsn_csm_contour_map(wks_pdf, sim(k, j, i, 14:123, 14:180), res)
            end do
        end do


        ; do j = 0, 2  ; VAR
        ;     do k = 0, NTEST - 1  ; TEST
        ;         res@gsnLeftString      = VAR_NAME(j) + "  " + TEST_NAME(k)
        ;         plot_pdf_rain(j*2+k+2) = gsn_csm_contour_map(wks_pdf, sim(k, j, :, :), res)
        ;     end do
        ; end do
        gsn_panel(wks_pdf, plot_pdf_rain, (/ 4, 3 /), False)

        ; res@cnLevelSpacingF = 1.0  
        ; res@cnMinLevelValF  = -10.0  
        ; res@cnMaxLevelValF  = 10.0 
        ; do j = 0, 2  ; VAR
        ;     res@gsnLeftString  = "GR3-GR0: " + VAR_NAME(j)
        ;     plot_pdf_rain(j+1) = gsn_csm_contour_map(wks_pdf, sim(1, j, :, :) - sim(0, j, :, :), res)
        ; end do
        ; gsn_panel(wks_pdf, plot_pdf_rain(0:3), (/ 4, 1 /), False)    

        ; res@cnLevelSpacingF = 1.0  
        ; res@cnMinLevelValF  = 0.0  
        ; res@cnMaxLevelValF  = 16.0 
        ; do j = 0, 4  ; VAR
        ;     do k = 0, 1  ; TEST
        ;         res@gsnLeftString = VAR_NAME(j+3) + "  " + TEST_NAME(k)
        ;         plot_pdf_apr(j*2+k)   = gsn_csm_contour_map(wks_pdf, sim(k, j+3, :, :), res)
        ;     end do
        ; end do
        ; gsn_panel(wks_pdf, plot_pdf_apr, (/ 5, 2 /), False)

        ; res@cnLevelSpacingF = 1.0  
        ; res@cnMinLevelValF  = -10.0  
        ; res@cnMaxLevelValF  = 10.0 
        ; do j = 0, 4  ; VAR
        ;     res@gsnLeftString = "GR3-GR0: " + VAR_NAME(j+3)
        ;     plot_pdf_apr(j)   = gsn_csm_contour_map(wks_pdf, sim(1, j+3, :, :) - sim(0, j+3, :, :), res)
        ; end do
        ; gsn_panel(wks_pdf, plot_pdf_apr(0:4), (/ 5, 1 /), False)
    end do
end
