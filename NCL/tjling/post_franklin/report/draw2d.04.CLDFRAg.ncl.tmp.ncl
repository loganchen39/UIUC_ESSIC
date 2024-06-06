load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

  yeara=(/"04"/)
  imnth=(/4,10/)
  varnamea=(/"CLDFRAg" /)
  ifdraw  =(/True  /)
  isaccuml=(/False /)
  maxvara =(/  1.0 , 16.0 , 400.0  , 460.0  ,  90.0  , 540.0  , 10.0   /)
  minvara =(/  0.0 ,  0.0 , 150.0  , 200.0  ,  10.0  , 300.0  ,  0.0   /)
  intvara =(/ 0.05 ,  1.0 ,  10.0  ,  10.0  ,   5.0  ,  10.0  ,  1.0   /)
  maxdifa =(/  0.5 ,  5.0 ,  60.0  ,  40.0  ,  20.0  ,  30.0  ,  5.0   /)
  mindifa =(/ -0.5 , -5.0 , -60.0  , -40.0  , -20.0  , -30.0  , -5.0   /)
  intdifa =(/  0.1 ,  0.5 ,  10.0  ,   5.0  ,   2.0  ,   5.0  ,  0.5   /)
  levels  =(/   4  ,     1,    1   ,   1    ,   1    ,   1    ,    1   /)
  binobsdir="/mnt/lfs0/projects/ciaqex/tiejuntemp/cwrf31/works/post/obs/zf/cloud_ISCCP_2004"
  
 ; montha=(/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)
  dofm =new((/12/),"integer")
  mnth=imnth-1
  do iy=0,dimsizes(yeara)-1
  do iv=0,dimsizes(varnamea)-1
  if (ifdraw(iv)) then
    varname=varnamea(iv)
    year=yeara(iy)
    setfileoption("bin","ReadByteOrder","BigEndian")
    ;print(binobsdir+binobsfile(iv))
    ;if (binobsfile(iv).ne."") then
	;vars 6
	;cloud 1 99 total cloud cover
	;cl 1 99 low cloud cover
	;cm 1 99 middle cloud cover
	;ch 1 99 high cloud cover
	;cnv 1 99 deep convective cloud cover
	;cwpc 1 99 cloud water path [g/m2]
	;endvars
    ovars=6
    obs=new((/12,ovars,138,195/),"float") 
    do i=1,12 
       obs(i-1,:,:,:)=fbindirread(binobsdir+"/cld20"+year+sprinti("%2.2i",i)+".grd",0,(/ovars,138,195/),"float")
    end do
    obs=obs/100.
    ;else
    lvs=levels(iv)

    case1=new((/12,lvs,138,195/),"float")
    ;end if
    case2=case1
    case3=case1
    case4=case1

    case1(mnth(0):mnth(1),:,:,:)=fbindirread("E29NSC04/wind_2004040100_2004103100/"+varname+"_E29NSC04",0,(/mnth(1)-mnth(0)+1,lvs,138,195/),"float") 
    case2(mnth(0):mnth(1),:,:,:)=fbindirread("E29USC04/wind_2004040100_2004103100/"+varname+"_E29USC04",0,(/mnth(1)-mnth(0)+1,lvs,138,195/),"float") 
    case3(mnth(0):mnth(1),:,:,:)=fbindirread("E36NSC04/wind_2004040100_2004103100/"+varname+"_E36NSC04",0,(/mnth(1)-mnth(0)+1,lvs,138,195/),"float") 
    case4(mnth(0):mnth(1),:,:,:)=fbindirread("E36USC04/wind_2004040100_2004103100/"+varname+"_E36USC04",0,(/mnth(1)-mnth(0)+1,lvs,138,195/),"float") 
    obs@_FillValue=1.0e20
    obs@missing_value=1.0e20
    obs@longname="L29SC0"
    casen=(/"L29SC0 ", "DL29+SC0 ", "DL29+SC1 ","DL36+SC0 ","DL36+SC1 "/)
    levsn=(/" "," Tl  ", " Hi ", " Mi ", " Lo "/)
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
    maxvar=maxvara(iv)
    minvar=minvara(iv)
    intvar=intvara(iv)
    maxdif=maxdifa(iv)
    mindif=mindifa(iv)
    intdif=intdifa(iv)
    


    ;printVarSummary(r)
    im=138
    jm=195
    wks = gsn_open_wks("ps","2004_V143ften_"+year+varname)         ; open a workstation
    plot = new(20,graphic)

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
    res@tmXBLabelsOn         = False              ; do not draw bottom labels
    res@tmYRLabelsOn         = False              ; no right labels
    res@tmYLLabelsOn         = False              ; no left labels
    res@tmXBOn               = False              ; no bottom tickmarks
    res@tmXTOn               = False              
    res@tmYLOn               = False             
    res@tmYROn               = False            
   
    res@gsnStringFontHeightF = 0.03

    do i=6,6 ;mnth(0),mnth(1)
    ;do i=0,11



    ;Variables
    ii=0
    do j=1,4
    if (j .eq. 1) then
      jj=0
    end if
    if (j .eq. 2) then
      jj=3
    end if
    if (j .eq. 3) then
      jj=2
    end if
    if (j .eq. 4) then 
      jj=1
    end if
    res@cnLevelSelectionMode = "ManualLevels"        ; manual contour levels
    res@cnLevelSpacingF      =  intvar                 ; contour interval
    res@cnMinLevelValF       =  minvar               ; min level
    res@cnMaxLevelValF       =  maxvar                 ; max level

    res@gsnSpreadColors     = True     ; use full color map
    res@gsnSpreadColorStart = 2        ; start at 4
    res@gsnSpreadColorEnd   = 23       ; end at 15
    res@gsnLeftString =case1@longname + levsn(j) + month(i)
    plot(ii) = gsn_csm_contour_map(wks,case1(i,jj,:,:),res)
    ii=ii+1
    res@gsnLeftString =case4@longname + levsn(j) + month(i)
    plot(ii) = gsn_csm_contour_map(wks,case4(i,jj,:,:),res)
    ii=ii+1
    res@cnLevelSelectionMode = "ManualLevels"        ; manual contour levels
    res@cnLevelSpacingF      =  intdif                    ; contour interval
    res@cnMinLevelValF       =  mindif                 ; min level
    res@cnMaxLevelValF       =  maxdif                    ; max level
    res@gsnSpreadColorStart = 27       ; start at 4
    res@gsnSpreadColorEnd   = 44       ; end at 15
    res@gsnLeftString =case2@longname + levsn(j) + month(i)
    plot(ii) = gsn_csm_contour_map(wks,case2(i,jj,:,:)-case1(i,jj,:,:),res)
    ii=ii+1
    res@gsnLeftString =case3@longname + levsn(j) + month(i)
    plot(ii) = gsn_csm_contour_map(wks,case3(i,jj,:,:)-case1(i,jj,:,:),res)
    ii=ii+1
    res@gsnLeftString =case4@longname + levsn(j) + month(i)
    plot(ii) = gsn_csm_contour_map(wks,case4(i,jj,:,:)-case1(i,jj,:,:),res)
    ii=ii+1
    end do

;    res@cnLevelSelectionMode = "ManualLevels"        ; manual contour levels
;    res@cnLevelSpacingF      =  intdif                 ; contour interval
;    res@cnMinLevelValF       =  mindif               ; min level
;    res@cnMaxLevelValF       =  maxdif                 ; max level

    res@gsnSpreadColorStart = 27       ; start at 4
    res@gsnSpreadColorEnd   = 44       ; end at 15


    ;Diff
;    res@gsnLeftString =d21@longname + " " + month(i)
;    plot(3) = gsn_csm_contour_map(wks,d21(i,:,:),res)
;    res@gsnLeftString =d43@longname + " " + month(i)
;    plot(6) = gsn_csm_contour_map(wks,d43(i,:,:),res)
;    res@gsnLeftString =d31@longname + " " + month(i)
;    plot(9) = gsn_csm_contour_map(wks,d31(i,:,:),res)


;    res@gsnLeftString =d1o@longname + " " + month(i)
;    plot(5) = gsn_csm_contour_map(wks,d1o(i,:,:),res)
;    res@gsnLeftString =d2o@longname + " " + month(i)
;    plot(6) = gsn_csm_contour_map(wks,d2o(i,:,:),res)
;    res@gsnLeftString =d3o@longname + " " + month(i)
;    plot(7 ) = gsn_csm_contour_map(wks,d3o(i,:,:),res)
;    res@gsnLeftString =d4o@longname + " " + month(i)
;    plot(8) = gsn_csm_contour_map(wks,d4o(i,:,:),res)

    pres                 = True
    pres@gsnPanelRowSpec = True                   ; tell panel what order to plt
    gsn_panel(wks,plot,(/5,5,5,5/),pres)
    

    end do

    
  end if
  end do
  end do
end
