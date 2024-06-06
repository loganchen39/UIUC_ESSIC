load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

  yeara=(/"93"/)
  ;yeara=(/"93","98"/)
  varnamea=(/"T2M" ,"PR"  ,"HFX"  ,"SFCEVP"/)
  ifdraw  =(/True  ,True ,False  ,False   /)
  isaccuml=(/False ,True  ,False  ,True    /)
  maxvara =(/305.0 , 16.0 , 250.0 , 10.0 /)
  minvara =(/250.0 ,  0.0 , -60.0 ,  0.0 /)
  intvara =(/  2.5 ,  1.0 ,  10.0 ,  1.0 /)
  maxdifa =(/  3.0 ,  5.0 ,  60.0 ,  5.0 /)
  mindifa =(/ -3.0 , -5.0 , -60.0 , -5.0 /)
  intdifa =(/  0.5 ,  0.5 ,   5.0 ,  0.5 /)
  binobsdir="/mnt/lfs0/projects/ciaqex/tiejuntemp/cwrf31/works/post/obs/"
  binobsfile = (/"obs_ta.195x138.1993.monthly","US_MEX.pr_rate.195x138.monthly.19930112", \
  		"",""/)
  
 ; montha=(/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)
  dofm =new((/12/),"integer")

  do iy=0,dimsizes(yeara)-1
  do iv=0,dimsizes(varnamea)-2
  if (ifdraw(iv)) then
    varname=varnamea(iv)
    year=yeara(iy)
    setfileoption("bin","ReadByteOrder","BigEndian")
    print(binobsdir+binobsfile(iv))
    obs=fbindirread(binobsdir+binobsfile(iv),0,(/12,138,195/),"float")
    ctl=obs
    ctl(4:8,:,:)=fbindirread("./output/"+varname+"CTL"+year,0,(/5,138,195/),"float") ;;;;;;;;;;;
    hrn=obs
    hrn(4:8,:,:)=fbindirread("./output/"+varname+"SC93",0,(/5,138,195/),"float") ;;;;;;;;;;;

    obs@_FillValue=1.0e20
    obs@missing_value=1.0e20
    if (varname.eq."T2M") then
       obs=obs+273.15
    end if
    ctl@longname=varname+" CTL "
    hrn@longname=varname+" SC "
    obs@longname=varname+" OBS "
    hrnctl=hrn-ctl
    hrnctl@longname=varname + " SC - CTL"
    maxvar=maxvara(iv)
    minvar=minvara(iv)
    intvar=intvara(iv)
    maxdif=maxdifa(iv)
    mindif=mindifa(iv)
    intdif=intdifa(iv)

    print(varname)

    month=(/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)
    do i=0,11
      month(i)=year+" "+month(i)
    end do
    if (isaccuml(iv)) then
      do i=1,12
        j=i-1
        dofm(j)=days_in_month(stringtoint(yeara(iy))+1900,i)
	ctl(j,:,:)=ctl(j,:,:)/dofm(j)
	hrn(j,:,:)=hrn(j,:,:)/dofm(j)
	hrnctl(j,:,:)=hrnctl(j,:,:)/dofm(j)
      end do
    end if 
    

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
    plot = new(4,graphic)

    ;gsn_define_colormap(wks,"gui_default")    ; choose colormap
    gsn_merge_colormaps(wks,"gui_default","posneg_1")
    ;gsn_draw_colormap(wks)

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

    do i=4,8
    ;do i=0,11

    res@cnLevelSelectionMode = "ManualLevels"        ; manual contour levels
    res@cnLevelSpacingF      =  intvar                 ; contour interval
    res@cnMinLevelValF       =  minvar               ; min level
    res@cnMaxLevelValF       =  maxvar                 ; max level

    res@gsnSpreadColors     = True     ; use full color map
    res@gsnSpreadColorStart = 2        ; start at 4
    res@gsnSpreadColorEnd   = 23       ; end at 15



    res@gsnLeftString =ctl@longname + " " + month(i)
    plot(2) = gsn_csm_contour_map(wks,ctl(i,:,:),res)
    res@gsnLeftString =hrn@longname + " " + month(i)
    plot(1) = gsn_csm_contour_map(wks,hrn(i,:,:),res)
    res@gsnLeftString =obs@longname + " " + month(i)
    plot(0) = gsn_csm_contour_map(wks,obs(i,:,:),res)

    res@cnLevelSelectionMode = "ManualLevels"        ; manual contour levels
    res@cnLevelSpacingF      =  intdif                 ; contour interval
    res@cnMinLevelValF       =  mindif               ; min level
    res@cnMaxLevelValF       =  maxdif                 ; max level

    res@gsnSpreadColorStart = 27       ; start at 4
    res@gsnSpreadColorEnd   = 44       ; end at 15
    res@gsnLeftString =hrnctl@longname + " " + month(i)
    plot(3) = gsn_csm_contour_map(wks,hrnctl(i,:,:),res)


    pres                 = True
    pres@gsnPanelRowSpec = True                   ; tell panel what order to plt
    gsn_panel(wks,plot,(/2,2/),pres)
    

    end do

    
  end if
  end do
  end do
end
