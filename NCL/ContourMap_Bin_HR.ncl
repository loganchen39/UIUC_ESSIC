load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
    DATA_SIM_ROOT = "/scratch/scratchdirs/lgchen/projects/postprocess/output"
    ; DATA_SIM    = (/"run_cu8_randall_nofb_franklin"/)
    DATA_OBS_ROOT = "/project/projectdirs/cwrf/cwrf/observation"
    ; DATA_OBS_RT = "observation"  ; rain and surface air temprature t2m
    
    VAR = (/"T2M", "PR"/) 
                      
    MONTH     = (/"Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct"/)
    MONTH_DIG = (/"03", "04", "05", "06", "07", "08", "09", "10"/)
    DOFM      = (/31, 30, 31, 30, 31, 31, 30, 31/)  

    NMONTH  = 8  ; in the order as defined
    NSCHEME = 2  ; in the order as defined 
    NVAR    = 2  ; in the order as defined
    NX      = 195
    NY      = 138

    SPV     = 1.0e20
    
    data_obs = new ((/NMONTH, NVAR, NY, NX/), "float")  
    data_obs = 0.
    data_sim = new ((/NSCHEME, NMONTH, NVAR, NY, NX/), "float")
    data_sim = 0.
    data_tmp = new ((/NY, NX/), "float")
    data_tmp = 0.

    data_obs@missingvalue = SPV
    data_obs@_FillVaulue  = SPV
    data_sim@missingvalue = SPV
    data_sim@_FillVaulue  = SPV
    data_tmp@missingvalue = SPV
    data_tmp@_FillVaulue  = SPV
    
    ; read-in observation data first
    ; comment: we could read all these observation data in a loop with those named indices, then use them,
    ; and release the memory resource as soon as they are no longer used.

    setfileoption("bin", "ReadByteOrder", "BigEndian")  ; built-in function

    ; T2M
    do i = 0, NMONTH - 1 
        data_obs(i, 0, :, :) = fbindirread(DATA_OBS_ROOT + "/t2m/"     \
                             + "t2m_monthly2mm5.199301_199312", i + 2  \
                             , (/NY, NX/), "float")
    end do
    ; print (data_obs(5, 0, :, :))
    ; print (data_obs(7, 0, :, :))

    ; RAIN
    do i = 0, NMONTH - 1
        data_obs(i, 1, :, :) = fbindirread(DATA_OBS_ROOT + "/pr/"  \
                             + "LAND_OCEAN.pr_rate_monthly.1993"   \
                             , i + 2, (/NY, NX/), "float")
    end do

    data_obs(:, :, :      , 0:13   ) = SPV
    data_obs(:, :, :      , 181:194) = SPV
    data_obs(:, :, 0:13   , :      ) = SPV
    data_obs(:, :, 124:137, :      ) = SPV

    ; read-in model simulation data from binary files
    do i = 0, NMONTH - 1 
        data_sim(0, i, 0, :, :) = fbindirread(DATA_SIM_ROOT + "/HR/"  \
                                + "T2M_monthly.bin", i                \
                                , (/NY, NX/), "float")
    end do 

    do i = 0, NMONTH - 1 
        data_sim(0, i, 1, :, :) = fbindirread(DATA_SIM_ROOT + "/HR/"  \
                                + "PR_monthly.bin", i                 \
                                , (/NY, NX/), "float")
        data_sim(0, i, 1, :, :) = data_sim(0, i, 1, :, :) / DOFM(i)
    end do

    do i = 0, NMONTH - 1 
        data_sim(1, i, 0, :, :) = fbindirread(DATA_SIM_ROOT + "/noHR/"  \
                                + "T2M_monthly.bin", i                  \
                                , (/NY, NX/), "float")
    end do 

    do i = 0, NMONTH - 1 
        data_sim(1, i, 1, :, :) = fbindirread(DATA_SIM_ROOT + "/noHR/"  \
                                + "PR_monthly.bin", i                   \
                                , (/NY, NX/), "float")
        data_sim(1, i, 1, :, :) = data_sim(1, i, 1, :, :) / DOFM(i)
    end do

    data_sim(:, :, :, :      , 0:13   ) = SPV
    data_sim(:, :, :, :      , 181:194) = SPV
    data_sim(:, :, :, 0:13   , :      ) = SPV
    data_sim(:, :, :, 124:137, :      ) = SPV


    ; DRAWING

    wks_pdf = gsn_open_wks("ps", "HR_noHR_1993_3")  ; ncgm(1), ps(up to 15), pdf(1), x11
    gsn_define_colormap(wks_pdf, "gui_default")     ; default: "hlu_default", 32 colors; gui_default: 24 colors
                                                    ; predefined color map: 87 in all; use named colors (around 752) 
                                                    ; and RGB triplets to create your own color map/table

    res          = True
    res@gsnDraw  = False  ; the graphics in question will not be drawn when the gsn function is called
    res@gsnFrame = False  ; the frame will not be advanced when the gsn function is called
    res@txFont   = "Helvetica"  ; specifies the font used for the "TextItem" when txFontQuality is set 
                                ; to "High", 31 fonts which are categorized into 2 types: stroked using 
                                ; lines or filled as areas
    res@tfDoNDCOverlay = True   ; DataTransform = False; NDCViewport = True; NDCDataExtent
        
    res@mpLimitMode    = "Corners"  ; This resource of type NhlTMapLimitMode specifies how MapTransformation 
                                    ; determines the extent of the projected globe that is mapped into the 
                                    ; viewport area. 8 possible settings. 
    ; res@mpLeftCornerLatF  = 15.22807  ; with "Corners" option above, MapTransformation maps into the viewport 
    ;                                   ; a rectangular area with one corner at the point mpLeftCornerLatF and 
    ;                                   ; mpLeftCornerLonF, and the opposite corner at the point mpRightCornerLatF 
    ;                                   ; and mpRightCornerLonF.
    ; res@mpLeftCornerLonF  = -120.7703 
    ; res@mpRightCornerLatF = 49.03231   ; latitude
    ; res@mpRightCornerLonF = -52.39819  ; longitude
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

    res@cnLineLabelsOn    = False  ; if contour line labels will or will not appear in the contour plot
    res@cnFillOn          = True   ; whether the areas between contour levels are filled with a solid color
                                   ; if it's on, you can choose between three fill methods by setting the resource cnFillMode 
    res@cnLinesOn         = False  ; no contour lines will appear in the contour plot, regardless of the values contained in 
                                   ; the cnLevelFlags array resource 
    res@gsnSpreadColors   = True   ; If set to True when calling any gsn function that produces vectors and/or contours, 
                                   ; then the colors used will be spread across the whole color map. the color range is
                                   ; determined by gsnSpreadColorStart and gsnSpreadColorEnd
    res@lbLabelAutoStride = True   ; If true, LabelBar labels are checked for overlap before being drawn. If overlap would  
                                   ; otherwise occur, a stride is set through the labels such that overlap will be avoided.

    res@lbOrientation            = "Vertical"  ; whether the labelbar boxes are arranged horizontally in a row or vertically in a column.
    res@pmLabelBarOrthogonalPosF = -0.01  ; move label bar closer. pmLabelBarOrthogonalPosF sets the coordinate of the 
                                          ; base location of the LabelBar object annotation orthogonal to the current pmLabelBarSide.
    res@lbLabelStride            = 2      ; Determines which labels actually are rendered the LabelBar is drawn. For example, 
                                          ; if the stride is set to 2, only every other label will be drawn, starting with the first label.

    res@gsnAddCyclic = False  ; For geo-referenced data, a longitude cyclic point is added as a default to ensure a gap 
                              ; is not plotted at the Greenwich Meridian. This resource only applies to gsn_csm plotting 
                              ; routines that overlay data on a map.
    ; res@tfDoNDCOverlay = True ; 
    
    plot_pdf = new (10, graphic)
    do i = 0, NMONTH-1
         res@cnLevelSelectionMode = "ManualLevels"  ; four methods for selecting the contour intervals displayed in a plot,
                                                    ; AutomaticLevels, ManualLevels, ExplicitLevels, EqualSpacedLevels
 
         ; AT2M
         varString = "T2M" 
 
         res@cnLevelSpacingF = 1.0  
         res@cnMinLevelValF  = 0.0  
         res@cnMaxLevelValF  = 35.0 
    
         ; observation 
         res@gsnLeftString = "OBS " + varString
         res@gsnRightString = MONTH(i) 
         plot_pdf(0) = gsn_csm_contour_map(wks_pdf, data_obs(i, 0, 14:123, 14:180), res)
 
         ; simulation
         res@gsnLeftString = "HR" + " " + varString
         plot_pdf(2) = gsn_csm_contour_map(wks_pdf, data_sim(0, i, 0, 14:123, 14:180) - 273.15, res)
 
         res@gsnLeftString = "noHR" + " " + varString
         plot_pdf(4) = gsn_csm_contour_map(wks_pdf, data_sim(1, i, 0, 14:123, 14:180) - 273.15, res)
 
         ; difference
         res@cnLevelSpacingF = 0.5  
         res@cnMinLevelValF  = -5.0  
         res@cnMaxLevelValF  = 5.0
 
         res@gsnLeftString = "noHR - OBS" + " " + varString
         ; do j = 0, NY - 1
         ;     do k = 0, NX - 1
         ;         if (abs(data_obs(i, 0, j, k)-SPV)/SPV .lt. 1.0e-10) then
         ;         ; if (data_obs(i, 0, j, k) .gt. SPV - 1000) then
         ;             data_tmp(j, k) = SPV
         ;         else
         ;             data_tmp(j, k) = data_sim(1, i, 0, j, k) - 273.15 - data_obs(i, 0, j, k)
         ;         end if
         ;     end do
         ; end do
         ; data_tmp(:      , 0:13   ) = SPV
         ; data_tmp(:      , 181:194) = SPV
         ; data_tmp(0:13   , :      ) = SPV
         ; data_tmp(124:137, :      ) = SPV

         tempv = data_sim(1, i, 0, 14:123, 14:180) - 273.15 - data_obs(i, 0, 14:123, 14:180)
         ; tempv = where(ismissing(data_obs(i, 0, 14:123, 14:180)), data_obs@_FillValue, tempv)
         tempv = where((data_obs(i, 0, 14:123, 14:180) .gt. 1000.), data_obs@_FillValue, tempv)
         copy_VarAtts(data_obs,tempv)

         ; plot_pdf(6) = gsn_csm_contour_map(wks_pdf, data_tmp(14:123, 14:180), res)
         ; plot_pdf(6) = gsn_csm_contour_map(wks_pdf, data_sim(1, i, 0, 14:123, 14:180) - 273.15 - data_obs(i, 0, 14:123, 14:180), res)
         plot_pdf(6) = gsn_csm_contour_map(wks_pdf, tempv, res)
 
         res@cnLevelSpacingF = 0.3  
         res@cnMinLevelValF  = -1.5  
         res@cnMaxLevelValF  = 1.5
 
         data_tmp = data_sim(0, i, 0, :, :) - data_sim(1, i, 0, :, :)
         data_tmp(:      , 0:13   ) = SPV
         data_tmp(:      , 181:194) = SPV
         data_tmp(0:13   , :      ) = SPV
         data_tmp(124:137, :      ) = SPV
 
         res@gsnLeftString = "HR - noHR" + " " + varString
         plot_pdf(8)       = gsn_csm_contour_map(wks_pdf, data_tmp(14:123, 14:180), res)
 
         ; RAIN
         varString = "PR" 
 
         res@cnLevelSpacingF = 1.0  
         res@cnMinLevelValF  = 0.0  
         res@cnMaxLevelValF  = 16.0 
    
         ; observation 
         res@gsnLeftString  = "OBS " + varString
         res@gsnRightString = MONTH(i) 
         plot_pdf(1)        = gsn_csm_contour_map(wks_pdf, data_obs(i, 1, 14:123, 14:180), res)
 
         ; simulation
         res@gsnLeftString = "HR" + " " + varString
         plot_pdf(3)       = gsn_csm_contour_map(wks_pdf, data_sim(0, i, 1, 14:123, 14:180), res)
 
         res@gsnLeftString = "noHR" + " " + varString
         plot_pdf(5)       = gsn_csm_contour_map(wks_pdf, data_sim(1, i, 1, 14:123, 14:180), res)
 
         ; difference
         res@cnLevelSpacingF = 1.0  
         res@cnMinLevelValF  = -8.0  
         res@cnMaxLevelValF  = 8.0
 
         data_tmp = data_sim(1, i, 1, :, :) - data_obs(i, 1, :, :)
         data_tmp(:      , 0:13   ) = SPV
         data_tmp(:      , 181:194) = SPV
         data_tmp(0:13   , :      ) = SPV
         data_tmp(124:137, :      ) = SPV
 
         res@gsnLeftString = "noHR - OBS" + " " + varString
         plot_pdf(7)       = gsn_csm_contour_map(wks_pdf, data_tmp(14:123, 14:180), res)
 
         res@cnLevelSpacingF = 0.4  
         res@cnMinLevelValF  = -5.0  
         res@cnMaxLevelValF  = 5.0
 
         data_tmp = data_sim(0, i, 1, :, :) - data_sim(1, i, 1, :, :)
         data_tmp(:      , 0:13   ) = SPV
         data_tmp(:      , 181:194) = SPV
         data_tmp(0:13   , :      ) = SPV
         data_tmp(124:137, :      ) = SPV
 
         res@gsnLeftString = "HR - noHR" + " " + varString
         plot_pdf(9)       = gsn_csm_contour_map(wks_pdf, data_tmp(14:123, 14:180), res)   
 
         gsn_panel(wks_pdf, plot_pdf, (/5, 2/), False)
     end do 

    do i = 0, NMONTH - 1
        res@cnLevelSelectionMode = "ManualLevels"

        varString         = "T2M"
        res@gsnLeftString = "noHR - OBS" + " " + varString

        ; difference
        res@cnLevelSpacingF = 0.5
        res@cnMinLevelValF  = -5.0
        res@cnMaxLevelValF  = 5.0

        res@gsnRightString  = MONTH(i)    

        ; do j = 0, NY - 1
        ;     do k = 0, NX - 1
        ;       if (abs(data_obs(i, 0, j, k)-SPV)/SPV .lt. 1.0e-10) then
        ;       ; if (data_obs(i, 0, j, k) .gt. SPV - 1000) then
        ;           data_tmp(j, k) = SPV
        ;       else
        ;           data_tmp(j, k) = data_sim(1, i, 0, j, k) - 273.15 - data_obs(i, 0, j, k)
        ;       end if
        ;     end do
        ; end do
        ; data_tmp(:      , 0:13   ) = SPV
        ; data_tmp(:      , 181:194) = SPV
        ; data_tmp(0:13   , :      ) = SPV
        ; data_tmp(124:137, :      ) = SPV   
        ; plot_pdf(i) = gsn_csm_contour_map(wks_pdf, data_tmp(14:123, 14:180), res)

        tempv = data_sim(1, i, 0, 14:123, 14:180) - 273.15 - data_obs(i, 0, 14:123, 14:180)
        ; tempv = where(ismissing(data_obs(i, 0, 14:123, 14:180)), data_obs@_FillValue, tempv)
        tempv = where((data_obs(i, 0, 14:123, 14:180) .gt. 1000.), data_obs@_FillValue, tempv)
        copy_VarAtts(data_obs,tempv)
        
        ; plot_pdf(i) = gsn_csm_contour_map(wks_pdf, data_sim(1, i, 0, 14:123, 14:180) - 273.15 - data_obs(i, 0, 14:123, 14:180), res) 
        plot_pdf(i) = gsn_csm_contour_map(wks_pdf, tempv, res) 
    end do
    gsn_panel(wks_pdf, plot_pdf(0:NMONTH-1), (/4, 2/), False) 

    do i = 0, NMONTH - 1
        res@cnLevelSelectionMode = "ManualLevels"
        varString = "T2M"
        res@gsnLeftString = "HR - OBS" + " " + varString

        ; difference
        res@cnLevelSpacingF = 0.5
        res@cnMinLevelValF  = -5.0
        res@cnMaxLevelValF  = 5.0

        res@gsnRightString = MONTH(i)    

        ; do j = 0, NY - 1
        ;     do k = 0, NX - 1
        ;         if (abs(data_obs(i, 0, j, k)-SPV)/SPV .lt. 1.0e-10) then
        ;         ; if (data_obs(i, 0, j, k) .gt. SPV - 1000) then
        ;             data_tmp(j, k) = SPV
        ;         else
        ;             data_tmp(j, k) = data_sim(1, i, 0, j, k) - 273.15 - data_obs(i, 0, j, k)
        ;         end if
        ;     end do
        ; end do
        ; data_tmp(:      , 0:13   ) = SPV
        ; data_tmp(:      , 181:194) = SPV
        ; data_tmp(0:13   , :      ) = SPV
        ; data_tmp(124:137, :      ) = SPV
        ; plot_pdf(i) = gsn_csm_contour_map(wks_pdf, data_tmp(14:123, 14:180), res)

        tempv = data_sim(0, i, 0, 14:123, 14:180) - 273.15 - data_obs(i, 0, 14:123, 14:180)
        ; tempv = where(ismissing(data_obs(i, 0, 14:123, 14:180)), data_obs@_FillValue, tempv)
        tempv = where((data_obs(i, 0, 14:123, 14:180) .gt. 1000.), data_obs@_FillValue, tempv)
        copy_VarAtts(data_obs,tempv)

        ; plot_pdf(i) = gsn_csm_contour_map(wks_pdf, tempv(1, i, 0, 14:123, 14:180) - 273.15 - data_obs(i, 0, 14:123, 14:180), res) 
        plot_pdf(i) = gsn_csm_contour_map(wks_pdf, tempv, res) 
    end do
    gsn_panel(wks_pdf, plot_pdf(0:NMONTH-1), (/4, 2/), False)

    ; exit

    do i = 0, NMONTH - 1
        res@cnLevelSelectionMode = "ManualLevels"

        varString         = "T2M"
        res@gsnLeftString = "HR - noHR" + " " + varString

        ; difference
        res@cnLevelSpacingF = 0.3
        res@cnMinLevelValF  = -1.5
        res@cnMaxLevelValF  = 1.5

        data_tmp = data_sim(0, i, 0, :, :) - data_sim(1, i, 0, :, :)
        data_tmp(:      , 0:13   ) = SPV
        data_tmp(:      , 181:194) = SPV
        data_tmp(0:13   , :      ) = SPV
        data_tmp(124:137, :      ) = SPV

        res@gsnRightString = MONTH(i)    
        plot_pdf(i)        = gsn_csm_contour_map(wks_pdf, data_tmp(14:123, 14:180), res) 
    end do
    gsn_panel(wks_pdf, plot_pdf(0:NMONTH-1), (/4, 2/), False)

    do i = 0, NMONTH - 1
        res@cnLevelSelectionMode = "ManualLevels"

        varString = "PR"
        res@gsnLeftString = "noHR - OBS" + " " + varString

        ; difference
        res@cnLevelSpacingF = 1.0
        res@cnMinLevelValF  = -8.0
        res@cnMaxLevelValF  = 8.0

        data_tmp = data_sim(1, i, 1, :, :) - data_obs(i, 1, :, :)
        data_tmp(:      , 0:13   ) = SPV
        data_tmp(:      , 181:194) = SPV
        data_tmp(0:13   , :      ) = SPV
        data_tmp(124:137, :      ) = SPV

        res@gsnRightString = MONTH(i)    
        plot_pdf(i)        = gsn_csm_contour_map(wks_pdf, data_tmp(14:123, 14:180), res) 
    end do
    gsn_panel(wks_pdf, plot_pdf(0:NMONTH-1), (/4, 2/), False)

    do i = 0, NMONTH - 1
        res@cnLevelSelectionMode = "ManualLevels"

        varString = "PR"
        res@gsnLeftString = "HR - OBS" + " " + varString

        ; difference
        res@cnLevelSpacingF = 1.0
        res@cnMinLevelValF  = -8.0
        res@cnMaxLevelValF  = 8.0

        data_tmp = data_sim(0, i, 1, :, :) - data_obs(i, 1, :, :)
        data_tmp(:      , 0:13   ) = SPV
        data_tmp(:      , 181:194) = SPV
        data_tmp(0:13   , :      ) = SPV
        data_tmp(124:137, :      ) = SPV

        res@gsnRightString = MONTH(i)    
        plot_pdf(i) = gsn_csm_contour_map(wks_pdf, data_tmp(14:123, 14:180), res) 
    end do
    gsn_panel(wks_pdf, plot_pdf(0:NMONTH-1), (/4, 2/), False)

    do i = 0, NMONTH - 1
        res@cnLevelSelectionMode = "ManualLevels"

        varString         = "PR"
        res@gsnLeftString = "HR - noHR" + " " + varString

        ; difference
        res@cnLevelSpacingF = 0.5
        res@cnMinLevelValF  = -5.0
        res@cnMaxLevelValF  = 5.0

        data_tmp = data_sim(0, i, 1, :, :) - data_sim(1, i, 1, :, :)
        data_tmp(:      , 0:13   ) = SPV
        data_tmp(:      , 181:194) = SPV
        data_tmp(0:13   , :      ) = SPV
        data_tmp(124:137, :      ) = SPV

        res@gsnRightString = MONTH(i)    
        plot_pdf(i)        = gsn_csm_contour_map(wks_pdf, data_tmp(14:123, 14:180), res) 
    end do
    gsn_panel(wks_pdf, plot_pdf(0:NMONTH-1), (/4, 2/), False)

end
