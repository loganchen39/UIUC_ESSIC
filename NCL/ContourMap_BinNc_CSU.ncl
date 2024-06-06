load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

    DATA_SIM_ROOT = "/scratch/scratchdirs/lgchen/projects/CWRFV3/CWRF_SVN_WORK/CWRFV3.1.1/run_cu8_randall_nofb"
    DATA_SIM      = (/ "run_cu8_randall_nofb_franklin" /)
    DATA_OBS_ROOT = "/scratch/scratchdirs/lgchen/data/obs_zhangfeng"
    DATA_OBS_RT   = "observation"  ; rain and surface air temprature t2m
    
    VAR  = (/ "AT2M", "RAIN", "RAINC", "RAINNC" /) 
                      
    MONTH     = (/ "May", "Jun", "Jul" /)
    MONTH_DIG = (/ "05", "06", "07" /)
    DOFM      = (/ 31, 30, 30 /)  

    NMONTH  = 3   ; in the order as defined
    NSCHEME = 1   ; in the order as defined 
    NVAR    = 4  ; in the order as defined
    NX      = 195
    NY      = 138
    
    data_obs = new ((/ NMONTH, NVAR, NY, NX /), "float")  
    data_obs = 0.
    data_sim = new ((/ NSCHEME, NMONTH, NVAR, NY, NX /), "float")
    data_sim = 0.

    ; read-in observation data first
    ; comment: we could read all these observation data in a loop with those named indices, then use them,
    ; and release the memory resource as soon as they are no longer used.

    setfileoption("bin","ReadByteOrder","BigEndian")  ; built-in function

    ; AT2M
    do i = 0, NMONTH - 1 
        data_obs(i, 0, :, :) = fbindirread(DATA_OBS_ROOT + "/" + DATA_OBS_RT + "/"  \
            + "obs_ta.195x138.1993.monthly", i + 4, (/ NY, NX /), "float")
    end do

    ; RAIN
    do i = 0, NMONTH - 1
        data_obs(i, 1, :, :) = fbindirread(DATA_OBS_ROOT + "/" + DATA_OBS_RT + "/"  \
            + "US_MEX.pr_rate.195x138.monthly.19930112", i + 4, (/ NY, NX /), "float")
    end do


    ; calculate result data from numerical simulation with several radiation schemes

    ; for rest schemes
    str_date_tmp = new ((/ 1 /), string)

 
    do j = 0, NMONTH - 1
        do k = 1, DOFM(j)
            str_date_tmp = k
            if (k .lt. 10)          
                nc_name_tmp = "wrfout_d01_1993-" + MONTH_DIG(j) + "-0" + str_date_tmp + "_00:00:00.nc"
            else
                nc_name_tmp = "wrfout_d01_1993-" + MONTH_DIG(j) + "-"  + str_date_tmp + "_00:00:00.nc"
            end if
            nc_file = addfile(DATA_SIM_ROOT + "/" + DATA_SIM(0) + "/" + nc_name_tmp, "r")
            
            if (j .eq. 0 .and. k .eq. 1)
                do m = 1, 7
                    data_sim(0, j, 0, :, :) = data_sim(0, j, 0, :, :) + nc_file->AT2M(m, :, :)
                end do
            else
                do m = 0, 7
                    data_sim(0, j, 0, :, :) = data_sim(0, j, 0, :, :) + nc_file->AT2M(m, :, :)
                end do         
            end if
        end do

        if (j .eq. 0) ; May
            nc_name_tmp = "wrfout_d01_1993-06-01_00:00:00.nc"
            nc_file     = addfile(DATA_SIM_ROOT + "/" + DATA_SIM(0) + "/" + nc_name_tmp, "r")
            data_sim(0, j, 0, :, :) = data_sim(0, j, 0, :, :) + nc_file->AT2M(0, :, :)

            data_sim(0, j, 0, :, :) = data_sim(0, j, 0, :, :) / 248
        else  ; June, July
            data_sim(0, j, 0, :, :) = data_sim(0, j, 0, :, :) / 240       
        end if
    end do      

    ; RAIN
    
    ; May
    nc_name_tmp = "wrfout_d01_1993-06-01_00:00:00.nc"
    nc_file     = addfile(DATA_SIM_ROOT + "/" + DATA_SIM(0) + "/" + nc_name_tmp, "r")
 
    data_sim(0, 0, 1, :, :) = nc_file->RAINC(0, :, :) + nc_file->RAINNC(0, :, :)
    data_sim(0, 0, 1, :, :) = data_sim(0, 0, 1, :, :) / 31.
    data_sim(0, 0, 2, :, :) = nc_file->RAINC(0, :, :) 
    data_sim(0, 0, 2, :, :) = data_sim(0, 0, 2, :, :) / 31.
    data_sim(0, 0, 3, :, :) = nc_file->RAINNC(0, :, :) 
    data_sim(0, 0, 3, :, :) = data_sim(0, 0, 3, :, :) / 31.

    ; Jun
    nc_name_tmp_1 = "wrfout_d01_1993-07-01_00:00:00.nc"
    nc_file_1     = addfile(DATA_SIM_ROOT + "/" + DATA_SIM(0) + "/" + nc_name_tmp_1, "r")

    data_sim(0, 1, 1, :, :) = nc_file_1->RAINC(0, :, :) + nc_file_1->RAINNC(0, :, :) \
                               - (nc_file->RAINC(0, :, :) + nc_file->RAINNC(0, :, :)) 
    data_sim(0, 1, 1, :, :) = data_sim(0, 1, 1, :, :) / 30.
    data_sim(0, 1, 2, :, :) = nc_file_1->RAINC(0, :, :) - nc_file->RAINC(0, :, :)
    data_sim(0, 1, 2, :, :) = data_sim(0, 1, 2, :, :) / 30.
    data_sim(0, 1, 3, :, :) = nc_file_1->RAINNC(0, :, :) - nc_file->RAINNC(0, :, :)
    data_sim(0, 1, 3, :, :) = data_sim(0, 1, 3, :, :) / 30.

    ; Jul
    nc_name_tmp = "wrfout_d01_1993-07-31_00:00:00.nc"
    nc_file     = addfile(DATA_SIM_ROOT + "/" + DATA_SIM(0) + "/" + nc_name_tmp, "r")

    data_sim(0, 2, 1, :, :) = nc_file->RAINC(0, :, :) + nc_file->RAINNC(0, :, :) \
                               - (nc_file_1->RAINC(0, :, :) + nc_file_1->RAINNC(0, :, :)) 
    data_sim(0, 2, 1, :, :) = data_sim(0, 2, 1, :, :) / 30.
    data_sim(0, 2, 2, :, :) = nc_file->RAINC(0, :, :) - nc_file_1->RAINC(0, :, :)
    data_sim(0, 2, 2, :, :) = data_sim(0, 2, 2, :, :) / 30.
    data_sim(0, 2, 3, :, :) = nc_file->RAINNC(0, :, :) - nc_file_1->RAINNC(0, :, :)
    data_sim(0, 2, 3, :, :) = data_sim(0, 2, 3, :, :) / 30.

    ; DRAWING

    wks_pdf = gsn_open_wks("pdf", "DDC_MJJ_1993")  ; ncgm(1), ps(up to 15), pdf(1), x11
    gsn_define_colormap(wks_pdf, "gui_default")  
        ; default: "hlu_default", 32 colors; gui_default: 24 colors predefined color map: 87 in all
        ; use named colors (around 752) and RGB triplets to create your own color map/table

    res                = True
    res@gsnDraw        = False  ; the graphics in question will not be drawn when the gsn function is called
    res@gsnFrame       = False  ; the frame will not be advanced when the gsn function is called
    res@txFont         = "Helvetica"  
        ; specifies the font used for the "TextItem" when txFontQuality is set to "High", 
        ; 31 fonts which are categorized into 2 types: stroked using lines or filled as areas
    res@tfDoNDCOverlay = True  ; DataTransform = False; NDCViewport = True; NDCDataExtent
        
    res@mpLimitMode       = "Corners" 
        ; This resource of type NhlTMapLimitMode specifies how MapTransformation 
        ; determines the extent of the projected globe that is mapped into the 
        ; viewport area. 8 possible settings. 
    res@mpLeftCornerLatF  = 15.22807  
        ; with "Corners" option above, MapTransformation maps into the viewport 
        ; a rectangular area with one corner at the point mpLeftCornerLatF and 
        ; mpLeftCornerLonF, and the opposite corner at the point mpRightCornerLatF 
        ; and mpRightCornerLonF.
    res@mpLeftCornerLonF  = -120.7703 
    res@mpRightCornerLatF = 49.03231  ; latitude
    res@mpRightCornerLonF = -52.39819 ; longitude

    res@pmTickMarkDisplayMode = "Always"                  
        ; This resource of type NhlTAnnotationDisplayMode determines whether the 
        ; plot object displays a TickMark object 
    res@mpFillOn              = False  ; switch for drawing of MapPlot area fill
    res@mpOutlineDrawOrder    = "PostDraw"                
        ; This resource of type NhlTDrawOrder determines when MapPlot area outlines 
        ; are drawn relative to other elements of the plot
    res@mpOutlineBoundarySets = "GeophysicalAndUSStates"  
        ; MapPlot will draw area outlines for geophysical features: continents, oceans, 
        ; islands, and inland water areas; as well as the states of U.S.

    res@mpProjection        = "LambertConformal"  ; defines the projection used for the map transformation, 17 in all
    res@mpLambertParallel1F = 60.    ; for lambert conformal projection
    res@mpLambertParallel2F = 30.
    res@mpLambertMeridianF  = -95.5  ; central meridian (line of longitude in degrees) of lambert conformal projection

    res@cnLineLabelsOn    = False ; if contour line labels will or will not appear in the contour plot
    res@cnFillOn          = True  
        ; whether the areas between contour levels are filled with a solid color
        ; if it's on, you can choose between three fill methods by setting the resource cnFillMode 
    res@cnLinesOn         = False 
        ; no contour lines will appear in the contour plot, regardless of the values  
        ; contained in the cnLevelFlags array resource 
    res@gsnSpreadColors   = True  
        ; If set to True when calling any gsn function that produces vectors and/or contours, 
        ; then the colors used will be spread across the whole color map. the color range is
        ; determined by gsnSpreadColorStart and gsnSpreadColorEnd
    res@lbLabelAutoStride = True  
        ; If true, LabelBar labels are checked for overlap before being drawn. If overlap would  
        ; otherwise occur, a stride is set through the labels such that overlap will be avoided.

    res@lbOrientation            = "Vertical" 
        ; whether the labelbar boxes are arranged horizontally in a row or vertically in a column.
    res@pmLabelBarOrthogonalPosF = -0.01 
        ; move label bar closer. pmLabelBarOrthogonalPosF sets the coordinate of the 
        ; base location of the LabelBar object annotation orthogonal to the current pmLabelBarSide.
    res@lbLabelStride            = 2  
        ; Determines which labels actually are rendered the LabelBar is drawn. For example, 
        ; if the stride is set to 2, only every other label will be drawn, starting with the first label.

    res@gsnAddCyclic = False  
        ; For geo-referenced data, a longitude cyclic point is added as a default to ensure a gap 
        ; is not plotted at the Greenwich Meridian. This resource only applies to gsn_csm plotting 
        ; routines that overlay data on a map.
    ; res@tfDoNDCOverlay = True ; 
    
    plot_pdf = new (6, graphic)
    do i = 0, NMONTH - 1
        res@cnLevelSelectionMode = "ManualLevels"  
            ; four methods for selecting the contour intervals displayed in a plot,
            ; AutomaticLevels, ManualLevels, ExplicitLevels, EqualSpacedLevels

        ; AT2M
        varString = "AT2M" 

        res@cnLevelSpacingF = 1.0  
        res@cnMinLevelValF  = 0.0  
        res@cnMaxLevelValF  = 35.0 
 
        ; observation 
        res@gsnLeftString = "OBS " + varString
        res@gsnRightString = MONTH(i) 
        plot_pdf(0) = gsn_csm_contour_map(wks_pdf, data_obs(i, 0, :, :), res)

        ; simulation
        res@gsnLeftString = "csu" + " " + varString
        plot_pdf(1) = gsn_csm_contour_map(wks_pdf, data_sim(0, i, 0, :, :) - 273.15, res)

        ; RAIN
        varString = "RAIN" 

        res@cnLevelSpacingF = 1.0  
        res@cnMinLevelValF  = 0.0  
        res@cnMaxLevelValF  = 16.0 
 
        ; observation 
        res@gsnLeftString = "OBS " + varString
        res@gsnRightString = MONTH(i) 
        plot_pdf(2) = gsn_csm_contour_map(wks_pdf, data_obs(i, 1, :, :), res)

        ; simulation
        res@gsnLeftString = "csu" + " " + varString
        plot_pdf(3) = gsn_csm_contour_map(wks_pdf, data_sim(0, i, 1, :, :), res)

        varString = "RAINC"
        res@gsnLeftString = "csu" + " " + varString
        plot_pdf(4) = gsn_csm_contour_map(wks_pdf, data_sim(0, i, 2, :, :), res)

        varString = "RAINNC"
        res@gsnLeftString = "csu" + " " + varString
        plot_pdf(5) = gsn_csm_contour_map(wks_pdf, data_sim(0, i, 3, :, :), res)   

        gsn_panel(wks_pdf, plot_pdf, (/ 3, 2 /), False)
    end do  

end

