load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; function add_filled_box(wks, map, lftlat, lftlon, rgtlat, rgtlon)
;     local gnres, npts, i, lat_begend, lon_begend, dist
; 
; begin
;     gnres                   = True
;     gnres@gsFillColor       = -1       ; "Foreground"
;     gnres@gsEdgesOn         = True
;     gnres@gsEdgeColor       = "white"
;     gnres@gsEdgeThicknessF  = 2.0
;     gnres@gsEdgeDashPattern = 1
;     
;     npts = 5  
;         ; Number of points along each box edge. You could make this different for each
;         ; edge, if you want.  
; 
;     ; Define the coordinates for the start, end of the four sides of each box. Put them 
;     ; in a big array so it's easier to loop across the points later.
;     ; (bottom, right, top, left)
;     lat_begend = (/(/lftlat, lftlat/), (/lftlat, rgtlat/)   \
;                ,   (/rgtlat, rgtlat/), (/rgtlat, lftlat/)/)
;     lon_begend = (/(/lftlon, rgtlon/), (/rgtlon, rgtlon/)   \
;                ,   (/rgtlon, lftlon/), (/lftlon, lftlon/)/)
;     
;     ; Define array to hold box.
;     latbox = new(4 * npts, float)
;     lonbox = new(4 * npts, float)
;     
;     ; Loop across the four edges and calculate the points along each edge
;     do i_edge = 0, 3
;         ibeg = i_edge * npts
;         iend = ibeg + npts - 1
;         dist = gc_latlon(lat_begend(i_edge, 0), lon_begend(i_edge, 0)  \
;              ,           lat_begend(i_edge, 1), lon_begend(i_edge,1), npts, 2)
;         latbox(ibeg:iend) = dist@gclat
;         lonbox(ibeg:iend) = dist@gclon
;     end do
;     
;     ; Attach filled box to map and return
;     dum = gsn_add_polygon(wks, map, lonbox, latbox, gnres)
;     
;     return(dum)
; end


begin
    OBS_PR_DIR     = "/project/projectdirs/cwrf/observation/pr"
    OBS_PR_FN_1993 = "LAND_OCEAN.pr_rate_daily.1993" 

    SIM_DIR      = "/scratch/scratchdirs/lgchen/projects/PrMOS/Fortran/nc2bin_rain/result_data"
    SCHM_NUM     = 4 
    SCHM_FN_PREF = (/"ctl", "g3"   , "CWRF-ERI", "CWRF-NARR"/)
    SCHM_DESC    = (/"ctl", "cu:g3", "sf:eri"  , "sf:narr"  /)

    LAT_LON_DIR  = "/global/u1/l/lgchen/data/lat_lon_195-138_xing"
 
    VAR_NUM = 3 
    VAR     = (/"PR", "RAINC", "RAINNC" /) 
                     
    DAY_NUM = 3
    DAY_REC = (/273+8, 365-18, 365-15/)
 
    NX      = 195
    NY      = 138
 
    REG_NUM    = 8
    REG_NAME   = (/"Cascade"  , "North Rockies", "Central Great Plain", "Midwest"  \
               ,   "Northeast", "Southeast"    , "Coast States"       , "NAM"     /) 
    REG_WINDOW = (/(/ 20,  85,  36, 121/)  \  ; (xb, yb, xe, ye)
               ,   (/ 42,  89,  62, 117/)  \
               ,   (/ 74,  55,  91,  90/)  \
               ,   (/104,  66, 133,  93/)  \
               ,   (/139,  80, 166, 116/)  \
               ,   (/134,  28, 155,  69/)  \
               ,   (/ 94,  39, 128,  63/)  \
               ,   (/ 51,  16,  70,  70/)/)
    REG_WINDOW = REG_WINDOW - 1

    lat = new ((/NY, NX/), "float") 
    lon = new ((/NY, NX/), "float") 
 
    data_obs = new ((/1,                 DAY_NUM, NY, NX /), "float")  
    data_obs = 0.
    data_sim = new ((/VAR_NUM, SCHM_NUM, DAY_NUM, NY, NX /), "float")
    data_sim = 0.

    dum_pg   = new ((/5*2, 8/), graphic)


    setfileoption("bin", "ReadByteOrder", "BigEndian")  ; built-in function

    ; read in lat and lon of CWRF grid
    lat(:, :) = fbindirread(LAT_LON_DIR + "/lat", 0, (/NY, NX/), "float")
    lon(:, :) = fbindirread(LAT_LON_DIR + "/lon", 0, (/NY, NX/), "float")

    ; read in obs PR
    do i_day = 0, DAY_NUM - 1
        data_obs(0, i_day, :, :) = fbindirread(OBS_PR_DIR + "/" + OBS_PR_FN_1993  \
            , DAY_REC(i_day), (/ NY, NX /), "float")
    end do

    ; read in sim PR
    do i_var = 0, VAR_NUM - 1
        do i_schm = 0, SCHM_NUM - 1
            do i_day = 0, DAY_NUM - 1
                data_sim(i_var, i_schm, i_day, :, :) = fbindirread(SIM_DIR + "/" + SCHM_FN_PREF(i_schm)  \
                    + "_" + VAR(i_var) + "_daily.bin", DAY_REC(i_day), (/ NY, NX /), "float")
            end do
        end do
    end do

    ; do i_y = 0, NY - 1
    ;     do i_x = 0, NX - 1
    ;         if ((     i_y .ge. REG_WINDOW(0, 1) .and. i_y .le. REG_WINDOW(0, 3)   \
    ;             .and. i_x .ge. REG_WINDOW(0, 0) .and. i_x .le. REG_WINDOW(0, 2))  \
    ;             .or. (i_y .ge. REG_WINDOW(1, 1) .and. i_y .le. REG_WINDOW(1, 3)   \
    ;             .and. i_x .ge. REG_WINDOW(1, 0) .and. i_x .le. REG_WINDOW(1, 2))  \
    ;             .or. (i_y .ge. REG_WINDOW(2, 1) .and. i_y .le. REG_WINDOW(2, 3)   \
    ;             .and. i_x .ge. REG_WINDOW(2, 0) .and. i_x .le. REG_WINDOW(2, 2))  \
    ;             .or. (i_y .ge. REG_WINDOW(3, 1) .and. i_y .le. REG_WINDOW(3, 3)   \
    ;             .and. i_x .ge. REG_WINDOW(3, 0) .and. i_x .le. REG_WINDOW(3, 2))  \
    ;             .or. (i_y .ge. REG_WINDOW(4, 1) .and. i_y .le. REG_WINDOW(4, 3)   \
    ;             .and. i_x .ge. REG_WINDOW(4, 0) .and. i_x .le. REG_WINDOW(4, 2))  \
    ;             .or. (i_y .ge. REG_WINDOW(5, 1) .and. i_y .le. REG_WINDOW(5, 3)   \
    ;             .and. i_x .ge. REG_WINDOW(5, 0) .and. i_x .le. REG_WINDOW(5, 2))  \
    ;             .or. (i_y .ge. REG_WINDOW(6, 1) .and. i_y .le. REG_WINDOW(6, 3)   \
    ;             .and. i_x .ge. REG_WINDOW(6, 0) .and. i_x .le. REG_WINDOW(6, 2))  \
    ;             .or. (i_y .ge. REG_WINDOW(7, 1) .and. i_y .le. REG_WINDOW(7, 3)   \
    ;             .and. i_x .ge. REG_WINDOW(7, 0) .and. i_x .le. REG_WINDOW(7, 2))  \
    ;         ) then
    ;             ; do nothing
    ;         else
    ;             data_obs(0, :,    i_y, i_x) = 0.0
    ;             data_sim(:, :, :, i_y, i_x) = 0.0
    ;         end if
    ;     end do
    ; end do

    ; DRAWING

    wks_pdf = gsn_open_wks("pdf", "Test")  
        ; ncgm(1), ps(up to 15), pdf(1), x11
    gsn_define_colormap(wks_pdf, "gui_default")  
        ; default: "hlu_default", 32 colors gui_default: 24 colors predefined color 
        ; map: 87 in all; use named colors (around 752) and RGB triplets to create 
        ; your own color map/table

    res                = True
    res@gsnDraw        = False  
        ; the graphics in question will not be drawn when the gsn function is called
    res@gsnFrame       = False  
        ; the frame will not be advanced when the gsn function is called
    res@txFont         = "Helvetica"  
        ; specifies the font used for the "TextItem" when txFontQuality is set to "High",
        ; 31 fonts which are categorized into 2 types: stroked using lines or filled as areas
    res@tfDoNDCOverlay = True  
        ; DataTransform = False; NDCViewport = True; NDCDataExtent
        
    res@mpLimitMode       = "Corners" 
        ; This resource of type NhlTMapLimitMode specifies how MapTransformation 
        ; determines the extent of the projected globe that is mapped into the 
        ; viewport area. 8 possible settings. 
    res@mpLeftCornerLatF  = 15.22807  
        ; with "Corners" option above, MapTransformation maps into the viewport a 
        ; rectangular area with one corner at the point mpLeftCornerLatF and 
        ; mpLeftCornerLonF, and the opposite corner at the point mpRightCornerLatF 
        ; and mpRightCornerLonF.
    res@mpLeftCornerLonF  = -120.7703 
    res@mpRightCornerLatF = 49.03231  ; latitude
    res@mpRightCornerLonF = -52.39819 ; longitude

    res@pmTickMarkDisplayMode = "Always"  
        ; This resource of type NhlTAnnotationDisplayMode determines whether the plot 
        ; object displays a TickMark object 
    res@mpFillOn              = False     
        ; switch for drawing of MapPlot area fill
    res@mpOutlineDrawOrder    = "PostDraw"  
        ; This resource of type NhlTDrawOrder determines when MapPlot area outlines 
        ; are drawn relative to other elements of the plot
    res@mpOutlineBoundarySets = "GeophysicalAndUSStates"  
        ; MapPlot will draw area outlines for geophysical features: continents, oceans, 
        ; islands, and inland water areas; as well as the states of U.S.

    res@mpProjection        = "LambertConformal"  
        ; defines the projection used for the map transformation, 17 in all
    res@mpLambertParallel1F = 60.  ; for lambert conformal projection
    res@mpLambertParallel2F = 30.
    res@mpLambertMeridianF  = -95.5  
        ; central meridian (line of longitude in degrees) of lambert conformal projection

    res@cnLineLabelsOn    = False 
        ; if contour line labels will or will not appear in the contour plot
    res@cnFillOn          = True  
        ; whether the areas between contour levels are filled with a solid color if it's 
        ; on, you can choose between three fill methods by setting the resource cnFillMode 
    res@cnLinesOn         = False 
        ; no contour lines will appear in the contour plot, regardless of the values i
        ; contained in the cnLevelFlags array resource 
    res@gsnSpreadColors   = True  
        ; If set to True when calling any gsn function that produces vectors and/or 
        ; contours, then the colors used will be spread across the whole color map. 
        ; the color range is determined by gsnSpreadColorStart and gsnSpreadColorEnd
    res@lbLabelAutoStride = True  
        ; If true, LabelBar labels are checked for overlap before being drawn. If 
        ; overlap would otherwise occur, a stride is set through the labels such 
        ; that overlap will be avoided.

    res@lbOrientation            = "Vertical" 
        ; whether the labelbar boxes are arranged horizontally in a row or vertically 
        ; in a column.
    res@pmLabelBarOrthogonalPosF = -0.01 
        ; move label bar closer. pmLabelBarOrthogonalPosF sets the coordinate of the 
        ; base location of the LabelBar object annotation orthogonal to the current 
        ; pmLabelBarSide.
    res@lbLabelStride            = 2  
        ; Determines which labels actually are rendered the LabelBar is drawn. For 
        ; example, if the stride is set to 2, only every other label will be drawn, 
        ; starting with the first label.

    res@gsnAddCyclic = False  
        ; For geo-referenced data, a longitude cyclic point is added as a default 
        ; to ensure a gap is not plotted at the Greenwich Meridian. This resource 
        ; only applies to gsn_csm plotting routines that overlay data on a map.
    ; res@tfDoNDCOverlay = True ; 
    
    res@cnLevelSelectionMode = "ManualLevels"  
        ; four methods for selecting the contour intervals displayed in a plot, 
        ; AutomaticLevels, ManualLevels, ExplicitLevels, EqualSpacedLevels

    pg_res                   = True
    pg_res@gsFillColor       = -1
    pg_res@gsEdgesOn         = True
    pg_res@gsEdgeColor       = "black"
    pg_res@gsEdgeThicknessF  = 2.0
    pg_res@gsEdgeDashPattern = 0

    plot_pdf = new (10, graphic)

    do i_day = 0, DAY_NUM - 1 
        ; PR
        varString = "PR" 

        res@cnLevelSpacingF = 1.0  
        res@cnMinLevelValF  = 0.0  
        res@cnMaxLevelValF  = 16.0 
 
        ; obs
        res@gsnLeftString  = varString + ": OBS"
        res@gsnRightString = DAY_REC(i_day) 
        plot_pdf(0) = gsn_csm_contour_map(wks_pdf, data_obs(0, i_day, :, :), res)

        ; add box for 8 regions
        do i_reg = 0, 8 - 1
            xb = REG_WINDOW(i_reg, 0)
            yb = REG_WINDOW(i_reg, 1)
            xe = REG_WINDOW(i_reg, 2)
            ye = REG_WINDOW(i_reg, 3)
    
            ; lft_lat = lat(yb, xb)
            ; lft_lon = lon(yb, xb)
            ; rgt_lat = lat(ye, xe)
            ; rgt_lon = lon(ye, xe)
            ; dum_pg(i_reg) = add_filled_box(wks_pdf, plot_pdf(0), lft_lat, lft_lon, rgt_lat, rgt_lon)

            pgx = (/lon(yb, xb), lon(yb, xe), lon(ye, xe), lon(ye, xb), lon(yb, xb)/)
            pgy = (/lat(yb, xb), lat(yb, xe), lat(ye, xe), lat(ye, xb), lat(yb, xb)/)
            dum_pg(0, i_reg) = gsn_add_polygon(wks_pdf, plot_pdf(0), pgx, pgy, pg_res)
        end do

        ; sim
        do i_schm = 0, SCHM_NUM - 1
            res@gsnLeftString = varString + ": " + SCHM_DESC(i_schm)
            plot_pdf(2*(i_schm+1)) = gsn_csm_contour_map(wks_pdf  \
                , data_sim(0, i_schm, i_day, :, :), res)
        end do

        res@cnLevelSpacingF = 0.5  
        res@cnMinLevelValF  = -4.0  
        res@cnMaxLevelValF  = 4.0

        ; sim - obs
        do i_schm = 0, SCHM_NUM - 1
            res@gsnLeftString = varString + ": OBS - " + SCHM_DESC(i_schm)
            plot_pdf(2*(i_schm+1)+1) = gsn_csm_contour_map(wks_pdf  \
                , data_sim(0, i_schm, i_day, :, :) - data_obs(0, i_day, :, :), res)
        end do

        do i_schm = 0, SCHM_NUM - 1
            do i_reg = 0, 8 - 1
                xb = REG_WINDOW(i_reg, 0)
                yb = REG_WINDOW(i_reg, 1)
                xe = REG_WINDOW(i_reg, 2)
                ye = REG_WINDOW(i_reg, 3)
    
                pgx = (/lon(yb, xb), lon(yb, xe), lon(ye, xe), lon(ye, xb), lon(yb, xb)/)
                pgy = (/lat(yb, xb), lat(yb, xe), lat(ye, xe), lat(ye, xb), lat(yb, xb)/)

                dum_pg(2*(i_schm+1)    , i_reg) = gsn_add_polygon(wks_pdf  \
                    , plot_pdf(2*(i_schm+1))    , pgx, pgy, pg_res)               
                dum_pg(2*(i_schm+1) + 1, i_reg) = gsn_add_polygon(wks_pdf  \
                    , plot_pdf(2*(i_schm+1) + 1), pgx, pgy, pg_res)        
            end do
        end do

        gsn_panel(wks_pdf, plot_pdf, (/ 5, 2 /), False)

        ; RAINC & RAINNC

        res@cnLevelSpacingF = 1.0  
        res@cnMinLevelValF  = 0.0  
        res@cnMaxLevelValF  = 16.0

        do i_schm = 0, SCHM_NUM - 1
            res@gsnLeftString = "RAINC: " + SCHM_DESC(i_schm)
            plot_pdf(2*(i_schm+1)    ) = gsn_csm_contour_map(wks_pdf, data_sim(1, i_schm, i_day, :, :), res)
            res@gsnLeftString = "RAINNC: " + SCHM_DESC(i_schm)
            plot_pdf(2*(i_schm+1) + 1) = gsn_csm_contour_map(wks_pdf, data_sim(2, i_schm, i_day, :, :), res)
        end do

        do i_schm = 0, SCHM_NUM - 1
            do i_reg = 0, 8 - 1
                xb = REG_WINDOW(i_reg, 0)
                yb = REG_WINDOW(i_reg, 1)
                xe = REG_WINDOW(i_reg, 2)
                ye = REG_WINDOW(i_reg, 3)
    
                pgx = (/lon(yb, xb), lon(yb, xe), lon(ye, xe), lon(ye, xb), lon(yb, xb)/)
                pgy = (/lat(yb, xb), lat(yb, xe), lat(ye, xe), lat(ye, xb), lat(yb, xb)/)

                dum_pg(2*(i_schm+1)    , i_reg) = gsn_add_polygon(wks_pdf  \
                    , plot_pdf(2*(i_schm+1))    , pgx, pgy, pg_res)               
                dum_pg(2*(i_schm+1) + 1, i_reg) = gsn_add_polygon(wks_pdf  \
                    , plot_pdf(2*(i_schm+1) + 1), pgx, pgy, pg_res)        
            end do
        end do

        gsn_panel(wks_pdf, plot_pdf, (/5, 2/), False)
    end do  

end
