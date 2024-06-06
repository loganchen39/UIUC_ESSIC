load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
    nx = 195
    ny = 138
    nt = 91
    
    c1 = new((/nt, ny, nx, 10/), "float")
    pr = new((/3 , ny, nx, 11/), "float")
    c1(0:89, :, :, 0) = fbindirread("data/cu_ligang/rain_cu3-g3d_19930502-19930730.bin", 0, (/nt-1, ny, nx/), "float")
    c1(:   , :, :, 1) = fbindirread("data/cu_ligang/rain_cu4-gd_19930501-19930730.bin" , 0, (/nt  , ny, nx/), "float")
    c1(:   , :, :, 2) = fbindirread("data/cu_ligang/rain_cu5-gdl_19930501-19930730.bin", 0, (/nt  , ny, nx/), "float")
    pro_tmp           = fbindirread("data/obs_qiao/LAND_OCEAN.pr_rate_monthly.1993"    , 0, (/12  , ny, nx/), "float")
    pr(:   , :, :, 0) = pro_tmp(4:6, :, :)

    do i = 1, 2
        do j = 0, nx - 1
            do k = 0, ny - 1
                pr(0, k, j, i+1) = sum(c1(0:30 , k, j, i)) / 31.
                pr(1, k, j, i+1) = sum(c1(31:60, k, j, i)) / 30.
                pr(2, k, j, i+1) = sum(c1(61:90, k, j, i)) / 30.
            end do
        end do
    end do

    do j = 0, nx - 1
        do k = 0, ny - 1
            pr(0, k, j, 1) = sum(c1(0:29 , k, j, 0)) / 30.
            pr(1, k, j, 1) = sum(c1(30:59, k, j, 0)) / 30.
            pr(2, k, j, 1) = sum(c1(60:80, k, j, 0)) / 30.
        end do
    end do

    pr@missingvalue = 1.e20
    pr@_FillValue   = 1.e20
    
    wks  = gsn_open_wks("ps", "cu")
    gsn_define_colormap(wks, "gui_default")
    plot = new(16, graphic)
    
    res          = True
    res@gsnDraw  = False
    res@gsnFrame = False
    ;res@txFont  = "Helvetica"

    res@tfDoNDCOverlay = True
          
    res@mpLimitMode       = "Corners"    ; choose range of map
    ; res@mpLeftCornerLatF  = 15.22807
    ; res@mpLeftCornerLonF  = -120.7703  ; lon2d@corners(0)
    ; res@mpRightCornerLatF = 49.03231   ; lat2d@corners(2)
    ; res@mpRightCornerLonF = -52.39819  ; lon2d@corners(2)
    res@mpLeftCornerLatF  = 19.768133
    res@mpLeftCornerLonF  = -118.259
    res@mpRightCornerLatF = 47.4818
    res@mpRightCornerLonF = -60.0576
    
    ; res@pmTickMarkDisplayMode = "Always"  ; Axis
    res@mpFillOn              = False       ; turn off map fill
    res@mpOutlineDrawOrder    = "PostDraw"  ; draw continental outline last
    res@mpOutlineBoundarySets = "GeophysicalAndUSStates"  ; state boundaries
    
    
    res@mpProjection        = "LambertConformal"
    res@mpLambertParallel1F = 60.
    res@mpLambertParallel2F = 30.
    res@mpLambertMeridianF  = -95.5
    
    res@cnLineLabelsOn    = False  ; turn on line labels
    res@cnFillOn          = True   ; turn on color fill
    res@cnLinesOn         = False
    res@gsnSpreadColors   = True   ; use full range of colors
    res@lbLabelAutoStride = True   ; optimal labels
    
    res@lbOrientation     = "Vertical"  ; vertical label bar
    ; res@pmLabelBarOrthogonalPosF = -0.01  ; move label bar closer
    res@lbLabelStride     = 2
    
    res@gsnAddCyclic         = False
    res@cnLevelSelectionMode = "ManualLevels"
    res@cnLevelSpacingF      = 1.
    res@cnMinLevelValF       = 0.
    res@cnMaxLevelValF       = 16.
    res@gsnRightString       = ""
    res@gsnLeftString        = ""
    res@lbLabelBarOn         = False  ; Turn off individual labelbars.

    do j=0,3
        plot(j     ) = gsn_csm_contour_map(wks, pr(0, :, :, j), res)
        plot(4  + j) = gsn_csm_contour_map(wks, pr(1, :, :, j), res)
        plot(8  + j) = gsn_csm_contour_map(wks, pr(2, :, :, j), res)
        plot(12 + j) = gsn_csm_contour_map(wks, (pr(0, :, :, j) + pr(1, :, :, j) + pr(2, :, :, j)) / 3., res)
    end do
    
    ; Create a panel of plots
    pres                   = True  ; Set panel resources.
    pres@gsnPanelLabelBar  = True  ; Turn on panel labelbar.
    pres@lbLabelStride     = 2
    pres@pmLabelBarWidthF  = 0.6   ; Change labelbar width.
    pres@lbLabelAutoStride = True
    pres@gsnSpreadColors   = True
    
    gsn_panel(wks, plot, (/4, 4/), pres)
end
