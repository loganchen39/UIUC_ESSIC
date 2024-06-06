load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

    OBS_ROOT = "/project/projectdirs/cwrf/observation"
    SIM_ROOT = "/scratch/scratchdirs/lgchen/data/sim_multi-cu_plot"
    
    NVAR = 4
    VAR  = (/"T2M", "PR", "RAINC", "RAINNC"/)
                      
    NMONTH    = 4
    MONTH     = (/"May", "Jun", "Jul", "Aug"/)
    MONTH_DIG = (/"05" , "06" , "07" , "08" /)
    DOFM      = (/31   , 30   , 31   , 31   /)  

    NSCHEME = 3
    SCHEME  = (/"cu_2-3_scuOff", "run_cu2_bmj", "CWRF-CSSP"/)
    
    NX = 195
    NY = 138
    
    obs = new ((/NMONTH, 2, NY, NX/), "float")
    obs = 0.
    sim = new ((/NSCHEME, NMONTH, NVAR, NY, NX/), "float")
    sim = 0.

    data_tmp = new ((/13, NY, NX/), "float")
    data_tmp = 0.0

    obs@missingvalue      = 1.0e20
    obs@_FillValue        = 1.0e20
    sim@missingvalue      = 1.0e20
    sim@_FillValue        = 1.0e20
    data_tmp@missingvalue = 1.0e20
    data_tmp@_FillValue   = 1.0e20


    setfileoption("bin","ReadByteOrder","BigEndian")

    ; observation: T2M
    data_tmp(0:11, :, :) = fbindirread(OBS_ROOT + "/t2m/monthly/t2m_30km_monthly.stn+cru.1993"  \
        , 0, (/12, NY, NX/), "float")
    obs(:, 0, :, :)      = data_tmp(4:7, :, :)

    ; observation: PR
    data_tmp(0:11, :, :) = fbindirread(OBS_ROOT + "/pr/LAND_OCEAN.pr_rate_monthly.1993"  \
        , 0, (/12, NY, NX/), "float")
    obs(:, 1, :, :)      = data_tmp(4:7, :, :)

    ; simulation
    do i_scheme = 0, NSCHEME - 1
        if (i_scheme .eq. 0) then
            do i_var = 0, NVAR - 1
                data_tmp(0:4, :, :) = fbindirread(SIM_ROOT+"/"+VAR(i_var)+"/"+SCHEME(i_scheme)  \
                    +"_"+VAR(i_var)+"_monthly.bin", 0, (/5, NY, NX/), "float")
                sim(i_scheme, :, i_var, :, :) = data_tmp(0:3, :, :)

                if (i_var .eq. 0) then
                    sim(i_scheme, :, i_var, :, :) = sim(i_scheme, :, i_var, :, :) - 273.15
                else
                    do i_month = 0, NMONTH - 1
                        sim(i_scheme, i_month, i_var, :, :) = sim(i_scheme, i_month, i_var, :, :) / DOFM(i_month)
                    end do
                end if
            end do            
        else
            do i_var = 0, NVAR - 1
                data_tmp(:, :, :) = fbindirread(SIM_ROOT+"/"+VAR(i_var)+"/"+SCHEME(i_scheme)  \
                    +"_"+VAR(i_var)+"_monthly.bin", 0, (/13, NY, NX/), "float")
                sim(i_scheme, :, i_var, :, :) = data_tmp(5:8, :, :)

                if (i_var .eq. 0) then 
                    sim(i_scheme, :, i_var, :, :) = sim(i_scheme, :, i_var, :, :) - 273.15
                else
                    do i_month = 0, NMONTH - 1
                        sim(i_scheme, i_month, i_var, :, :) = sim(i_scheme, i_month, i_var, :, :) / DOFM(i_month) 
                    end do
                end if
            end do
        end if
    end do


    ; DRAWING

    wks_pdf = gsn_open_wks("pdf", "MULTI-CU-2-3_scuOff_MJJA_1993")  ; ncgm(1), ps(up to 15), pdf(1), x11
    gsn_define_colormap(wks_pdf, "gui_default")  ; default: "hlu_default", 32 colors; gui_default: 24 colors
                                                 ; predefined color map: 87 in all; use named colors (around 752) 
                                                 ; and RGB triplets to create your own color map/table

    res                = True
    res@gsnDraw        = False  ; the graphics in question will not be drawn when the gsn function is called
    res@gsnFrame       = False  ; the frame will not be advanced when the gsn function is called
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
    
    plot_pdf = new (10, graphic)

    res@cnLevelSelectionMode = "ManualLevels"

    ; T2M
    do i_month = 0, NMONTH - 1
        res@gsnRightString = MONTH(i_month)

        res@cnLevelSpacingF = 1.0
        res@cnMinLevelValF  = 0.0
        res@cnMaxLevelValF  = 35.0

        res@gsnLeftString = VAR(0) + ": OBS"
        plot_pdf(0) = gsn_csm_contour_map(wks_pdf, obs(i_month, 0, 14:123, 14:180), res)
        
        do i_scheme = 0, NSCHEME - 1 
            res@gsnLeftString = VAR(0) + ": " + SCHEME(i_scheme)
            res@cnLevelSpacingF = 1.0
            res@cnMinLevelValF  = 0.0
            res@cnMaxLevelValF  = 35.0
            plot_pdf((i_scheme+1)*2) = gsn_csm_contour_map(wks_pdf, sim(i_scheme, i_month, 0, 14:123, 14:180), res)

            res@gsnLeftString = VAR(0) + ": " + SCHEME(i_scheme) + " - OBS"
            res@cnLevelSpacingF = 0.5
            res@cnMinLevelValF  = -5.0
            res@cnMaxLevelValF  = 5.0
            plot_pdf((i_scheme+1)*2+1) = gsn_csm_contour_map(wks_pdf, sim(i_scheme, i_month, 0, 14:123, 14:180)  \
                - obs(i_month, 0, 14:123, 14:180), res)
        end do

        res@gsnLeftString = VAR(0) + ": " + "0.5*(cu2+cu3)"
        res@cnLevelSpacingF = 1.0 
        res@cnMinLevelValF  = 0.0 
        res@cnMaxLevelValF  = 35.0
        plot_pdf(8) = gsn_csm_contour_map(wks_pdf  \
            , 0.5*(sim(1, i_month, 0, 14:123, 14:180)+sim(2, i_month, 0, 14:123, 14:180)), res)

        res@gsnLeftString = VAR(0) + ": " + "0.5*(cu2+cu3) - OBS"
        res@cnLevelSpacingF = 0.5 
        res@cnMinLevelValF  = -5.0
        res@cnMaxLevelValF  = 5.0
        plot_pdf(9) = gsn_csm_contour_map(wks_pdf  \
            , 0.5*(sim(1, i_month, 0, 14:123, 14:180)+sim(2, i_month, 0, 14:123, 14:180))  \
            - obs(i_month, 0, 14:123, 14:180), res)

        gsn_panel(wks_pdf, plot_pdf, (/5, 2/), False)
    end do

    ; PR
    do i_month = 0, NMONTH - 1
        res@gsnRightString = MONTH(i_month)

        res@cnLevelSpacingF = 1.0
        res@cnMinLevelValF  = 0.0
        res@cnMaxLevelValF  = 16.0

        res@gsnLeftString = VAR(1) + ": OBS"
        plot_pdf(0) = gsn_csm_contour_map(wks_pdf, obs(i_month, 1, 14:123, 14:180), res)
        
        do i_scheme = 0, NSCHEME - 1 
            res@gsnLeftString = VAR(1) + ": " + SCHEME(i_scheme)
            res@cnLevelSpacingF = 1.0
            res@cnMinLevelValF  = 0.0
            res@cnMaxLevelValF  = 16.0
            plot_pdf((i_scheme+1)*2) = gsn_csm_contour_map(wks_pdf, sim(i_scheme, i_month, 1, 14:123, 14:180), res)

            res@gsnLeftString = VAR(1) + ": " + SCHEME(i_scheme) + " - OBS"
            res@cnLevelSpacingF = 0.5
            res@cnMinLevelValF  = -5.0
            res@cnMaxLevelValF  = 5.0
            plot_pdf((i_scheme+1)*2+1) = gsn_csm_contour_map(wks_pdf, sim(i_scheme, i_month, 1, 14:123, 14:180)  \
                - obs(i_month, 1, 14:123, 14:180), res)
        end do

        res@gsnLeftString = VAR(1) + ": " + "0.5*(cu2+cu3)"
        res@cnLevelSpacingF = 1.0 
        res@cnMinLevelValF  = 0.0 
        res@cnMaxLevelValF  = 16.0
        plot_pdf(8) = gsn_csm_contour_map(wks_pdf  \
            , 0.5*(sim(1, i_month, 1, 14:123, 14:180)+sim(2, i_month, 1, 14:123, 14:180)), res)

        res@gsnLeftString = VAR(1) + ": " + "0.5*(cu2+cu3) - OBS"
        res@cnLevelSpacingF = 0.5 
        res@cnMinLevelValF  = -5.0
        res@cnMaxLevelValF  = 5.0
        plot_pdf(9) = gsn_csm_contour_map(wks_pdf  \
            , 0.5*(sim(1, i_month, 1, 14:123, 14:180)+sim(2, i_month, 1, 14:123, 14:180))  \
            - obs(i_month, 1, 14:123, 14:180), res)

        gsn_panel(wks_pdf, plot_pdf, (/5, 2/), False)
    end do

    ; ; RAINC & RAINNC
    plot_pdf_2 = new (8, graphic)

    res@cnLevelSpacingF = 1.0
    res@cnMinLevelValF  = 0.0
    res@cnMaxLevelValF  = 16.0

    do i_month = 0, NMONTH - 1
        res@gsnRightString = MONTH(i_month)

        do i_scheme = 0, NSCHEME - 1
            res@gsnLeftString = "RAINC: " + SCHEME(i_scheme)
            plot_pdf_2(i_scheme) = gsn_csm_contour_map(wks_pdf, sim(i_scheme, i_month, 2, 14:123, 14:180), res)

            res@gsnLeftString = "RAINNC: " + SCHEME(i_scheme)
            plot_pdf_2(i_scheme + 4) = gsn_csm_contour_map(wks_pdf, sim(i_scheme, i_month, 3, 14:123, 14:180), res)
        end do
   
        res@gsnLeftString = "RAINC: 0.5*(cu2+cu3)"
        plot_pdf_2(3) = gsn_csm_contour_map(wks_pdf  \
            , 0.5*(sim(1, i_month, 2, 14:123, 14:180)+sim(2, i_month, 2, 14:123, 14:180)), res)
 
        res@gsnLeftString = "RAINNC: 0.5*(cu2+cu3)"
        plot_pdf_2(7) = gsn_csm_contour_map(wks_pdf  \
            , 0.5*(sim(1, i_month, 3, 14:123, 14:180)+sim(2, i_month, 3, 14:123, 14:180)), res)

        gsn_panel(wks_pdf, plot_pdf_2, (/4, 2/), False)
    end do   

end
