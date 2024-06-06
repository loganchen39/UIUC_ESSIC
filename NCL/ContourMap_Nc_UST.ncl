load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
    f1                = addfile("CWRF-U.nc","r")
    cwrf              = f1->UST
    cwrf@missingvalue = -1.e20
    cwrf@_FillValue   = -1.e20

    f2                = addfile("WRF-U.nc","r")
    wrf               = f2->UST
    wrf@missingvalue  = -1.e20
    wrf@_FillValue    = -1.e20

    dif               = cwrf-wrf
    dif@missingvalue  = -1.e20
    dif@_FillValue    = -1.e20
    
    wks  = gsn_open_wks("ps","UST")
    gsn_define_colormap(wks,"gui_default")

    plot = new(9,graphic)
    
    res                = True
    res@gsnDraw        = False
    res@gsnFrame       = False
    res@txFont         = "Helvetica"
    res@tfDoNDCOverlay = True
      
    res@mpLimitMode       = "Corners"  ; choose range of map
    res@mpLeftCornerLatF  = 15.22807
    res@mpLeftCornerLonF  = -120.7703  ; lon2d@corners(0)
    res@mpRightCornerLatF = 49.03231   ; lat2d@corners(2)
    res@mpRightCornerLonF = -52.39819  ; lon2d@corners(2)

    res@pmTickMarkDisplayMode = "Always"
    res@mpFillOn              = False                     ; turn off map fill
    res@mpOutlineDrawOrder    = "PostDraw"                ; draw continental outline last
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

    res@lbOrientation            = "Vertical"  ; vertical label bar
    res@pmLabelBarOrthogonalPosF = -0.01       ; move label bar closer
    res@lbLabelStride            = 2

    month = (/"May 1993", "Jun 1993", "Jul 1993"/)

    res@gsnAddCyclic = False

    do i = 0, 2 
        res@gsnLeftString        = month(i)
        res@gsnRightString       = "m/s"
        res@tiMainString         = "WRF-NOAH-YSU UST"
        res@cnLevelSelectionMode = "ManualLevels"
        res@cnLevelSpacingF      = 0.05
        res@cnMinLevelValF       = 0.
        res@cnMaxLevelValF       = 0.8
        plot(i)                  = gsn_csm_contour_map(wks,wrf(i,:,:),res)

        res@gsnLeftString        = month(i)
        res@gsnRightString       = "m/s"
        res@tiMainString         = "CWRF-CLM-CAM UST"
        res@cnLevelSelectionMode = "ManualLevels"
        ; res@cnLevelSpacingF    = 1.0
        ; res@cnMinLevelValF     = 0.
        ; res@cnMaxLevelValF     = 35.0
        plot(i+3)                = gsn_csm_contour_map(wks,cwrf(i,:,:),res)

        res@gsnLeftString        = month(i)
        res@gsnRightString       = "m/s"
        res@tiMainString         = "CWRF minus WRF"
        res@cnLevelSelectionMode = "ManualLevels"
        res@cnLevelSpacingF      = 0.05
        res@cnMinLevelValF       = -0.3
        res@cnMaxLevelValF       = 0.3
        plot(i+6)                = gsn_csm_contour_map(wks,dif(i,:,:),res)
    end do
  
    gsn_panel(wks, plot, (/3, 3/), False)

end
