load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

  setfileoption("bin","ReadByteOrder","BigEndian")
  varname="ASWDNS"
  var=fbindirread("./output/"+varname+"SC93",0,(/5,138,195/),"float")

  montha=(/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)

  fctl=addfile(varname+".ctl.nc","r")
  varctl=fctl->$varname$

    wks = gsn_open_wks("ps","temp")         ; open a workstation
    plot = new(3,graphic)

    gsn_define_colormap(wks,"gui_default")    ; choose colormap
    ;gsn_merge_colormaps(wks,"gui_default","posneg_1")
    ;gsn_draw_colormap(wks)
    

    res = True
    res@tiMainString = ""

    res@vpWidthF = 0.7
    res@vpHeightF = 0.7

    res@gsnDraw = False
    res@gsnFrame = False

    res@mpLimitMode       = "Corners"         ; choose range of map
    res@mpLeftCornerLatF  =  15.22807
    res@mpLeftCornerLonF  =  -120.7703 ;lon2d@corners(0)
    res@mpRightCornerLatF = 49.03231 ;lat2d@corners(2)
    res@mpRightCornerLonF = -52.39819 ;lon2d@corners(2)
    
    res@pmTickMarkDisplayMode = "Always"
    res@mpFillOn              = False           ; turn off map fill
    res@mpOutlineDrawOrder    = "PostDraw"      ; draw continental outline last
    res@mpOutlineBoundarySets = "GeophysicalAndUSStates" ; state boundaries


    res@mpProjection        = "LambertConformal"
    res@mpLambertParallel1F = 60.
    res@mpLambertParallel2F = 30.
    res@mpLambertMeridianF  = -95.5

    res@cnLineLabelsOn       = False                 ; turn on line labels
    res@cnFillOn             = True                  ; turn on color fill
    res@cnLinesOn            = False
    res@gsnSpreadColors      = True                  ; use full range of colors
    res@lbLabelAutoStride    = True                  ; optimal labels
  
    res@lbOrientation            = "Vertical"     ; vertical label bar
    res@pmLabelBarOrthogonalPosF = -0.01          ; move label bar closer
    res@lbLabelStride            = 2



    res@gsnAddCyclic = False
    res@tfDoNDCOverlay = True  ;!!!!!

    do i=4,8

    res@cnLevelSelectionMode = "AutomaticLevels"        ; manual contour levels
    ;res@cnLevelSpacingF      =  intvar                 ; contour interval
    ;res@cnMinLevelValF       =  minvar               ; min level
    ;res@cnMaxLevelValF       =  maxvar                 ; max level

    res@gsnSpreadColors     = True     ; use full color map

    res@gsnLeftString = "SC "+ varname + " " + montha(i) 
    plot(0) = gsn_csm_contour_map(wks,var(i-4,:,:),res)
    res@gsnLeftString = "CTL "+ varname + " " + montha(i)
    plot(1) = gsn_csm_contour_map(wks,varctl(i,:,:),res)
    res@gsnLeftString = "SC-CTL "+ varname + " " + montha(i)
    plot(2) = gsn_csm_contour_map(wks,var(i-4,:,:)-varctl(i,:,:),res)

    
    pres                 = True
    pres@gsnPanelRowSpec = True                   ; tell panel what order to plt
    gsn_panel(wks,plot,(/1,1,1/),pres)

    end do

    
end
