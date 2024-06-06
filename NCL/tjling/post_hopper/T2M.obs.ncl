load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

  yeara=(/"93","98"/)
  do iy=0,dimsizes(yeara)-2

    varname="T2M"
    year=yeara(iy)
    setfileoption("bin","ReadByteOrder","BigEndian")
    ctl=fbindirread("./output/"+varname+""+year+".ctl",0,(/12,138,195/),"float")
    hrn=fbindirread("./output/"+varname+""+year+".hr",0,(/12,138,195/),"float")
    ctl@longname=varname+" CTL "
    hrn@longname=varname+" HR "
    hrnctl=hrn-ctl
    hrnctl@longname=varname + "HR - CTL"
    maxvar=305.0
    minvar=250.0
    intvar=2.5
    maxdif=5.0
    mindif=-5.0
    intdif=1.0


    month=(/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)
    do i=0,11
      month(i)=year+" "+month(i)
    end do

    ; t and r are wanted
    
    ;printVarSummary(t)
    ;printVarSummary(r)
;    t1=t
;    t=t1-273.15
;    copy_VarAtts(t1,t)
;    copy_VarCoords(t1,t)
;    t@units = "Degree"

    ;printVarSummary(r)
    im=138
    jm=195
    wks = gsn_open_wks("ps",year+varname)         ; open a workstation
    plot = new(3,graphic)

    gsn_define_colormap(wks,"gui_default")    ; choose colormap

    res = True
    res@tiMainString = ""

    res@vpWidthF = 0.7
    res@vpHeightF =0.7

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

    do i=0,11

    res@cnLevelSelectionMode = "ManualLevels"        ; manual contour levels
    res@cnLevelSpacingF      =  intvar                 ; contour interval
    res@cnMinLevelValF       =  minvar               ; min level
    res@cnMaxLevelValF       =  maxvar                 ; max level

    res@gsnLeftString =ctl@longname + " " + month(i)
    plot(0) = gsn_csm_contour_map(wks,ctl(i,:,:),res)
    res@gsnLeftString =hrn@longname + " " + month(i)
    plot(1) = gsn_csm_contour_map(wks,hrn(i,:,:),res)

    res@cnLevelSelectionMode = "ManualLevels"        ; manual contour levels
    res@cnLevelSpacingF      =  intdif                 ; contour interval
    res@cnMinLevelValF       =  mindif               ; min level
    res@cnMaxLevelValF       =  maxdif                 ; max level

    res@gsnLeftString =hrnctl@longname + " " + month(i)
    plot(2) = gsn_csm_contour_map(wks,hrnctl(i,:,:),res)


    pres                 = True
    pres@gsnPanelRowSpec = True                   ; tell panel what order to plt
    gsn_panel(wks,plot,(/1,1,1/),pres)

    end do

  end do
end
