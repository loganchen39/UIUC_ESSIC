load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; load "/global/u2/t/tjling/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "/global/u2/t/tjling/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "/global/u2/t/tjling/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

    SIM_DIR      = "/scratch/scratchdirs/lgchen/data/sim_1993/var_ln" 
    ; OBS_PR_1992  = "/project/projectdirs/cwrf/cwrf/observation/pr/LAND_OCEAN.pr_rate_monthly.1992" 
    OBS_PR_1993  = "/project/projectdirs/cwrf/cwrf/observation/pr/LAND_OCEAN.pr_rate_monthly.1993" 
    ; OBS_T2M_1992 = "/project/projectdirs/cwrf/cwrf/observation/t2m/t2m_monthly2mm5.199201_199212"
    OBS_T2M_1993 = "/project/projectdirs/cwrf/observation/t2m/monthly/t2m_30km_monthly.stn+cru.1993"

    NSSN = 4
    SEASON  = (/"DJF", "MAM", "JJA", "SON"/)

    ; NMON      = 13   ; in the order as defined
    ; MONTH     = (/ "Dec", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" /)
    ; MONTH_DIG = (/ "12", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12" /)
    DOFM        = (/31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31/)  ; array and then loop
    
    N_PBL_SCHEME         = 8
    PBL_SCHEME_NAME_FILE = (/"CWRF-CSSP", "acm", "boulac", "gfs", "myj", "qnse", "uw", "ysu"/)  ; CWRF-CSSP as CTL
    PBL_SCHEME_NAME_PLOT = (/"CTL"      , "ACM", "BOULAC", "GFS", "MYJ", "QNSE", "UW", "YSU"/)

    NVAR     = 3
    VAR_NAME = (/"PBLH", "PR", "T2M"/)

    NX   = 195
    NY   = 138

    ; NREC = 31
 
    obs = new ((/              NVAR-1, NSSN, NY, NX/), "float")
    sim = new ((/N_PBL_SCHEME, NVAR  , NSSN, NY, NX/), "float")
    obs = 0.0
    sim = 0.0

    data_tmp = new ((/13, NY, NX/), "float")
    data_tmp = 0.0

    obs@missingvalue = 1.0e20
    obs@_FillValue   = 1.0e20
    sim@missingvalue = 1.0e20
    sim@_FillValue   = 1.0e20
    data_tmp@missingvalue = 1.0e20
    data_tmp@_FillValue   = 1.0e20


    setfileoption("bin", "ReadByteOrder", "BigEndian")

    ; observation
    data_tmp(1:12, :, :) = fbindirread(OBS_PR_1993, 0, (/12, NY, NX/), "float")
    data_tmp(0   , :, :) = data_tmp(12, :, :)
    do i_ssn = 0, NSSN - 1
        obs(0, i_ssn, :, :) = dim_avg_n(data_tmp(i_ssn*3:i_ssn*3+2, :, :), 0)
    end do

    data_tmp(1:12, :, :) = fbindirread(OBS_T2M_1993, 0 , (/12, NY, NX/), "float")
    data_tmp(0   , :, :) = data_tmp(12, :, :)
    data_tmp = where((data_tmp .gt. 1000.), data_tmp@missingvalue, data_tmp)
    do i_ssn = 0, NSSN - 1
        obs(1, i_ssn, :, :) = dim_avg_n(data_tmp(i_ssn*3:i_ssn*3+2, :, :), 0)
    end do

    ; simulation
    do i_scheme = 0, N_PBL_SCHEME - 1
        do i_var = 0, NVAR - 1
            data_tmp(:, :, :) = fbindirread(SIM_DIR+"/"+PBL_SCHEME_NAME_FILE(i_scheme)  \
                +"_"+VAR_NAME(i_var)+"_monthly.bin", 0, (/13, NY, NX/), "float")

            if (i_var .eq. 1) then
                do i = 1, 12
                    data_tmp(i, :, :) = data_tmp(i, :, :) / DOFM(i-1)
                end do
            end if

            if (i_var .eq. 2) then
                data_tmp(1:12, :, :) = data_tmp(1:12, :, :) - 273.15
            end if

            data_tmp(0, :, :) = data_tmp(12, :, :)

            do i_ssn = 0, NSSN - 1
                sim(i_scheme, i_var, i_ssn, :, :) = dim_avg_n(data_tmp(i_ssn*3:i_ssn*3+2, :, :), 0)
            end do
        end do
    end do    


    ; DRAWING

    wks_pdf = gsn_open_wks("pdf", "PBLH_SM_1993")  ; ncgm(1), ps(up to 15), pdf(1), x11
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

    plot_pdf = new (9, graphic)
    plot_tmp = new (1, graphic)

    ; for pblh
    do i_ssn = 0, NSSN - 1
        res@cnLevelSelectionMode = "ManualLevels"  ; four methods for selecting the contour intervals displayed in a plot,
                                                   ; AutomaticLevels, ManualLevels, ExplicitLevels, EqualSpacedLevels

        res@gsnRightString  = SEASON(i_ssn)

        res@cnLevelSpacingF = 100.0
        res@cnMinLevelValF  = 0.0
        res@cnMaxLevelValF  = 2000.0  ; originally 3000

        varString           = "PBLH: "
        do i_scheme = 0, N_PBL_SCHEME - 1
            res@gsnLeftString   = varString + PBL_SCHEME_NAME_PLOT(i_scheme)
            plot_pdf(i_scheme) = gsn_csm_contour_map(wks_pdf, sim(i_scheme, 0, i_ssn, 14:123, 14:180), res) 
        end do
        gsn_panel(wks_pdf, plot_pdf(0:7), (/4, 2/), False)

        res@cnLevelSpacingF = 50.0
        res@cnMinLevelValF  = -500.0
        res@cnMaxLevelValF  = 500.0

        do i_scheme = 1, N_PBL_SCHEME - 1
            res@gsnLeftString   = varString + PBL_SCHEME_NAME_PLOT(i_scheme) + " - CTL"
            plot_pdf(i_scheme) = gsn_csm_contour_map(wks_pdf, sim(i_scheme, 0, i_ssn, 14:123, 14:180)  \
                - sim(0, 0, i_ssn, 14:123, 14:180), res) 
        end do
        gsn_panel(wks_pdf, plot_pdf(0:7), (/4, 2/), False)       
    end do

    ; for pr and t2m
    do i_var = 1, NVAR - 1
        do i_ssn = 0, NSSN - 1
            res@cnLevelSelectionMode = "ManualLevels"  

            res@gsnRightString  = SEASON(i_ssn)

            if (i_var .eq. 1) then
                res@cnLevelSpacingF = 1.0
                res@cnMinLevelValF  = 0.0
                res@cnMaxLevelValF  = 10.0  ; originally 16.0 for monthly mean
            end if

            if (i_var .eq. 2) then
                res@cnLevelSpacingF = 1.0
                res@cnMinLevelValF  = -10.0
                res@cnMaxLevelValF  = 35.0               
            end if

            varString = VAR_NAME(i_var) + ": "
            res@gsnLeftString  = varString + "OBS"
            plot_pdf(0) = gsn_csm_contour_map(wks_pdf, obs(i_var-1, i_ssn, 14:123, 14:180), res)

            do i_scheme = 0, N_PBL_SCHEME - 1
                res@gsnLeftString  = varString + PBL_SCHEME_NAME_PLOT(i_scheme)
                plot_pdf(i_scheme+1) = gsn_csm_contour_map(wks_pdf, sim(i_scheme, i_var, i_ssn, 14:123, 14:180), res) 
            end do
            gsn_panel(wks_pdf, plot_pdf, (/3, 3/), False)

            if (i_var .eq. 1) then
                res@cnLevelSpacingF = 0.5
                res@cnMinLevelValF  = -5.0
                res@cnMaxLevelValF  = 5.0
            end if

            if (i_var .eq. 2) then
                res@cnLevelSpacingF = 0.5
                res@cnMinLevelValF  = -5.0
                res@cnMaxLevelValF  = 5.0               
            end if

            plot_tmp = plot_pdf(1)

            do i_scheme = 0, N_PBL_SCHEME - 1
                res@gsnLeftString  = varString + PBL_SCHEME_NAME_PLOT(i_scheme) + " - OBS"
                plot_pdf(i_scheme+1) = gsn_csm_contour_map(wks_pdf, sim(i_scheme, i_var, i_ssn, 14:123, 14:180)  \
                    - obs(i_var-1, i_ssn, 14:123, 14:180), res) 
            end do
            gsn_panel(wks_pdf, plot_pdf, (/3, 3/), False)

            do i_scheme = 1, N_PBL_SCHEME - 1
                res@gsnLeftString  = varString + PBL_SCHEME_NAME_PLOT(i_scheme) + " - CTL"
                plot_pdf(i_scheme+1) = gsn_csm_contour_map(wks_pdf, sim(i_scheme, i_var, i_ssn, 14:123, 14:180)  \
                    - sim(0, i_var, i_ssn, 14:123, 14:180), res) 
            end do
            plot_pdf(1) = plot_tmp
            gsn_panel(wks_pdf, plot_pdf, (/3, 3/), False)           
        end do
    end do    
end
