load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; load "/global/u2/t/tjling/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "/global/u2/t/tjling/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "/global/u2/t/tjling/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

    DATA_SIM_DIR = "/scratch2/scratchdirs/lgchen/projects/CWRFV3/cwrf_run/cumulus_test/1993/run_cu7_zml/run_cu7_zml" 
    OBS_PR_1992  = "/project/projectdirs/cwrf/cwrf/observation/pr/LAND_OCEAN.pr_rate_monthly.1992" 
    OBS_PR_1993  = "/project/projectdirs/cwrf/cwrf/observation/pr/LAND_OCEAN.pr_rate_monthly.1993" 
    OBS_T2M_1992 = "/project/projectdirs/cwrf/cwrf/observation/t2m/t2m_monthly2mm5.199201_199212"
    OBS_T2M_1993 = "/project/projectdirs/cwrf/cwrf/observation/t2m/t2m_monthly2mm5.199301_199312"

    MONTH     = (/ "Dec", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" /)
    MONTH_DIG = (/ "12", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12" /)
    DOFM      = (/ 31, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 /)  ; try to use array and then loop to simplify the code
    
    ; NTEST     = 3
    ; TEST_NAME = (/ "cu9-gfdl-sfcbl-0", "cu9-gfdl-sfcbl-4", "cu9-gfdl-tau-3600" /)

    NVAR     = 2
    VAR_NAME = (/ "T2M", "RAIN"/)

    NMON = 13   ; in the order as defined
    NX   = 195
    NY   = 138

    ; NREC = 31
 
    obs = new ((/NVAR, NMON, NY, NX/), "float")
    sim = new ((/NVAR + 2, NMON, NY, NX/), "float")
    obs = 0.0
    sim = 0.0

    ; data_tmp = new ((/91, NY, NX/), "float")
    ; data_tmp = 0.0


    setfileoption("bin", "ReadByteOrder", "BigEndian")

    ; observation
    obs(0, 0   , :, :) = fbindirread(OBS_T2M_1992, 11, (/ NY, NX /)    , "float")
    obs(0, 1:12, :, :) = fbindirread(OBS_T2M_1993, 0 , (/ 12, NY, NX /), "float")
    obs(1, 0   , :, :) = fbindirread(OBS_PR_1992 , 11, (/ NY, NX /)    , "float")
    obs(1, 1:12, :, :) = fbindirread(OBS_PR_1993 , 0 , (/ 12, NY, NX /), "float")

    ; simulation
    sim(0, :, :, :) = fbindirread(DATA_SIM_DIR + "/" + "run_cu7_zml_T2M_monthly.bin"     \
                    , 0, (/NMON, NY, NX/), "float")
    sim(1, :, :, :) = fbindirread(DATA_SIM_DIR + "/" + "run_cu7_zml_PR_monthly.bin"      \
                    , 0, (/NMON, NY, NX/), "float")
    sim(2, :, :, :) = fbindirread(DATA_SIM_DIR + "/" + "run_cu7_zml_RAINC_monthly.bin"   \
                    , 0, (/NMON, NY, NX/), "float")
    sim(3, :, :, :) = fbindirread(DATA_SIM_DIR + "/" + "run_cu7_zml_RAINNC_monthly.bin"  \
                    , 0, (/NMON, NY, NX/), "float")


    ; DRAWING

    wks_pdf = gsn_open_wks("pdf", "cu7-zml_1993")  ; ncgm(1), ps(up to 15), pdf(1), x11
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

    plot_pdf = new (8, graphic)

    do i = 0, NMON - 1

        res@cnLevelSelectionMode = "ManualLevels"  ; four methods for selecting the contour intervals displayed in a plot,
                                                   ; AutomaticLevels, ManualLevels, ExplicitLevels, EqualSpacedLevels

        res@cnLevelSpacingF = 1.0  
        res@cnMinLevelValF  = 0.0  
        res@cnMaxLevelValF  = 16.0 

        res@gsnRightString = MONTH(i)

        varString = "PR: "
        res@gsnLeftString = varString + "OBS"
        plot_pdf(0)  = gsn_csm_contour_map(wks_pdf, obs(1, i, 14:123, 14:180), res)
        res@gsnLeftString = varString + "ZML"
        plot_pdf(2)  = gsn_csm_contour_map(wks_pdf, sim(1, i, 14:123, 14:180) / DOFM(i), res)
       
        varString = "RAINC: "
        res@gsnLeftString = varString + "ZML"
        plot_pdf(6)  = gsn_csm_contour_map(wks_pdf, sim(2, i, 14:123, 14:180) / DOFM(i), res)        
        
        varString = "RAINNC: "
        res@gsnLeftString = varString + "ZML"
        plot_pdf(7)  = gsn_csm_contour_map(wks_pdf, sim(3, i, 14:123, 14:180) / DOFM(i), res)

        res@cnLevelSpacingF = 1.0
        res@cnMinLevelValF  = -10.0
        res@cnMaxLevelValF  = 10.0

        res@gsnLeftString = "PR: ZML - OBS"
        plot_pdf(4)  = gsn_csm_contour_map(wks_pdf, sim(1, i, 14:123, 14:180) / DOFM(i) - obs(1, i, 14:123, 14:180), res)

        res@cnLevelSpacingF = 1.0
        res@cnMinLevelValF  = -10.0
        res@cnMaxLevelValF  = 35.0       

        res@gsnLeftString = "T2M: OBS"
        plot_pdf(1)  = gsn_csm_contour_map(wks_pdf, obs(0, i, 14:123, 14:180), res) 
        res@gsnLeftString = "T2M: ZML"
        plot_pdf(3)  = gsn_csm_contour_map(wks_pdf, sim(0, i, 14:123, 14:180) - 273.15, res)

        res@cnLevelSpacingF = 1.0
        res@cnMinLevelValF  = -5.0
        res@cnMaxLevelValF  = 5.0

        res@gsnLeftString = "T2M: ZML - OBS"
        plot_pdf(5)  = gsn_csm_contour_map(wks_pdf, sim(0, i, 14:123, 14:180) -273.15 - obs(0, i, 14:123, 14:180), res)

        gsn_panel(wks_pdf, plot_pdf, (/ 4, 2 /), False)
    end do
end
