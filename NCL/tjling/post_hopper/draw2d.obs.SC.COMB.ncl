load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

  yeara=(/"93"/)
  imnth=(/5,8/)
  ;yeara=(/"93","98"/)
  varnamea=(/"T2M" ,"PR"  ,"ASWDNS","ALWDNS","ASWUPS","ALWUPS","SFCEVP"/)
  ifdraw  =(/True  ,True  ,False   ,False   ,False   ,False   ,False   /)
  isaccuml=(/False ,True  ,False   ,False   ,False   ,False   ,True    /)
  maxvara =(/305.0 , 16.0 , 400.0  , 460.0  ,  90.0  , 540.0  , 10.0   /)
  minvara =(/250.0 ,  0.0 , 150.0  , 200.0  ,  10.0  , 300.0  ,  0.0   /)
  intvara =(/  2.5 ,  1.0 ,  10.0  ,  10.0  ,   5.0  ,  10.0  ,  1.0   /)
  maxdifa =(/  3.0 ,  5.0 ,  60.0  ,  40.0  ,  20.0  ,  30.0  ,  5.0   /)
  mindifa =(/ -3.0 , -5.0 , -60.0  , -40.0  , -20.0  , -30.0  , -5.0   /)
  intdifa =(/  0.5 ,  0.5 ,  10.0  ,   5.0  ,   2.0  ,   5.0  ,  0.5   /)
  binobsdir="/mnt/lfs0/projects/ciaqex/tiejuntemp/cwrf31/works/post/obs/"
  binobsfile = (/"obs_ta.195x138.1993.monthly", \
                 "LAND_OCEAN.pr_rate_monthly.1993", \
  		"ASWDNS.MJJ93","ALWDNS.MJJ93","ASWUPS.MJJ93","ALWUPS.MJJ93","",""/)
  
 ; montha=(/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)
  dofm =new((/12/),"integer")
  mnth=imnth-1
  do iy=0,dimsizes(yeara)-1
  do iv=0,dimsizes(varnamea)-2
  if (ifdraw(iv)) then
    varname=varnamea(iv)
    year=yeara(iy)
    setfileoption("bin","ReadByteOrder","BigEndian")
    print(binobsdir+binobsfile(iv))
    if (binobsfile(iv).ne."") then
    obs=fbindirread(binobsdir+binobsfile(iv),0,(/12,138,195/),"float")
    else
    obs=new((/12,138,195/),"float")
    obs=0.0
    end if
    case1=obs
    case2=obs
    case3=obs
    case4=obs

    case1(mnth(0):mnth(1),:,:)=fbindirread("./output/"+varname+"_CASE8",0,(/mnth(1)-mnth(0)+1,138,195/),"float") ;;;;;;;;;;;;;;;;;;;;;
    case2(mnth(0):mnth(1),:,:)=fbindirread("./output/"+varname+"_CASE10",0,(/mnth(1)-mnth(0)+1,138,195/),"float") ;;;;;;;;;;;;;;;;;;;;;
    case3(mnth(0):mnth(1),:,:)=fbindirread("./output/"+varname+"_CASE7",0,(/mnth(1)-mnth(0)+1,138,195/),"float") ;;;;;;;;;;;;;;;;;;;;;
    case4(mnth(0):mnth(1),:,:)=fbindirread("./output/"+varname+"_CASE9",0,(/mnth(1)-mnth(0)+1,138,195/),"float") ;;;;;;;;;;;;;;;;;;;;;

    obs@_FillValue=1.0e20
    obs@missing_value=1.0e20
    if (varname.eq."T2M") then
       obs=obs+273.15
    end if
    casen=(/" OBS "," CASE8"," CASE10 "," CASE7 "," CTLV110 "/)
    case1@longname=varname+casen(1)
    case2@longname=varname+casen(2)
    case3@longname=varname+casen(3)
    case4@longname=varname+casen(4)
    obs@longname=varname+casen(0)

    print(varname)

    month=(/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)
    do i=0,11
      month(i)=year+" "+month(i)
    end do
    if (isaccuml(iv)) then
      do i=1,12
        j=i-1
        dofm(j)=days_in_month(stringtoint(yeara(iy))+1900,i)
	case1(j,:,:)=case1(j,:,:)/dofm(j)
	case2(j,:,:)=case2(j,:,:)/dofm(j)
	case3(j,:,:)=case3(j,:,:)/dofm(j)
	case4(j,:,:)=case4(j,:,:)/dofm(j)
      end do
    end if 

    d1o=case1-obs
    d2o=case2-obs
    d3o=case3-obs
    d4o=case4-obs
    d1o@longname=varname+casen(1)+"-"+casen(0)
    d2o@longname=varname+casen(2)+"-"+casen(0)
    d3o@longname=varname+casen(3)+"-"+casen(0)
    d4o@longname=varname+casen(4)+"-"+casen(0)
    d21=case2-case1
    d43=case4-case3
    d31=case3-case1
    d21@longname=varname+casen(2)+"-"+casen(1)
    d43@longname=varname+casen(4)+"-"+casen(3)
    d31@longname=varname+casen(3)+"-"+casen(1)
    maxvar=maxvara(iv)
    minvar=minvara(iv)
    intvar=intvara(iv)
    maxdif=maxdifa(iv)
    mindif=mindifa(iv)
    intdif=intdifa(iv)
    

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
    wks = gsn_open_wks("ps","CASE_10_1"+year+varname)         ; open a workstation
    plot = new(12,graphic)

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

    do i=mnth(0),mnth(1)
    ;do i=0,11

    res@cnLevelSelectionMode = "ManualLevels"        ; manual contour levels
    res@cnLevelSpacingF      =  intvar                 ; contour interval
    res@cnMinLevelValF       =  minvar               ; min level
    res@cnMaxLevelValF       =  maxvar                 ; max level

    res@gsnSpreadColors     = True     ; use full color map
    res@gsnSpreadColorStart = 2        ; start at 4
    res@gsnSpreadColorEnd   = 23       ; end at 15


    ;Variables
    res@gsnLeftString =obs@longname + " " + month(i)
    plot(0) = gsn_csm_contour_map(wks,obs(i,:,:),res)
    res@gsnLeftString =case1@longname + " " + month(i)
    plot(1) = gsn_csm_contour_map(wks,case1(i,:,:),res)
    res@gsnLeftString =case2@longname + " " + month(i)
    plot(4) = gsn_csm_contour_map(wks,case2(i,:,:),res)
    res@gsnLeftString =case3@longname + " " + month(i)
    plot(7) = gsn_csm_contour_map(wks,case3(i,:,:),res)
    res@gsnLeftString =case4@longname + " " + month(i)
    plot(10) = gsn_csm_contour_map(wks,case4(i,:,:),res)

    res@cnLevelSelectionMode = "ManualLevels"        ; manual contour levels
    res@cnLevelSpacingF      =  intdif                 ; contour interval
    res@cnMinLevelValF       =  mindif               ; min level
    res@cnMaxLevelValF       =  maxdif                 ; max level

    res@gsnSpreadColorStart = 27       ; start at 4
    res@gsnSpreadColorEnd   = 44       ; end at 15


    ;Diff
    res@gsnLeftString =d21@longname + " " + month(i)
    plot(3) = gsn_csm_contour_map(wks,d21(i,:,:),res)
    res@gsnLeftString =d43@longname + " " + month(i)
    plot(6) = gsn_csm_contour_map(wks,d43(i,:,:),res)
    res@gsnLeftString =d31@longname + " " + month(i)
    plot(9) = gsn_csm_contour_map(wks,d31(i,:,:),res)


    res@gsnLeftString =d1o@longname + " " + month(i)
    plot(2) = gsn_csm_contour_map(wks,d1o(i,:,:),res)
    res@gsnLeftString =d2o@longname + " " + month(i)
    plot(5) = gsn_csm_contour_map(wks,d2o(i,:,:),res)
    res@gsnLeftString =d3o@longname + " " + month(i)
    plot(8 ) = gsn_csm_contour_map(wks,d3o(i,:,:),res)
    res@gsnLeftString =d4o@longname + " " + month(i)
    plot(11) = gsn_csm_contour_map(wks,d4o(i,:,:),res)

    pres                 = True
;    pres@gsnPanelRowSpec = True                   ; tell panel what order to plt
    gsn_panel(wks,plot,(/4,3/),pres)
    

    end do

    
  end if
  end do
  end do
end
