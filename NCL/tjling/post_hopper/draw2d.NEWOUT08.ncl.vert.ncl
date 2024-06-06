load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

  yeara=(/"08"/)
  imnth=(/7,7/)
  ;yeara=(/"93","98"/)
  varnamea=(/"T" ,"QCLOUD","QICE"  ,"QRAIN" ,"QVAPOR","ALWUPS","SFCEVP"/)
  ifdraw  =(/False ,False ,False   ,False   ,True    ,False   ,False   /)
  isaccuml=(/False ,False ,False   ,False   ,False   ,False   ,True    /)
  maxvara =(/310.0 ,1.5e-4,4.4e-6  ,2.6e-5  ,0.02     , 540.0  , 10.0   /)
  minvara =(/200.0 ,1.0e-5,4.0e-7  ,2.0e-6  ,   0.0  , 300.0  ,  0.0   /)
  intvara =(/ 5.00 ,1.0e-5,1.0e-7  ,1.0e-6  ,   0.002 ,  10.0  ,  1.0   /)
  maxdifa =(/  3.0 ,  5.0 ,  60.0  ,  40.0  ,  20.0  ,  30.0  ,  5.0   /)
  mindifa =(/ -3.0 , -5.0 , -60.0  , -40.0  , -20.0  , -30.0  , -5.0   /)
  intdifa =(/  0.5 ,  0.5 ,  10.0  ,   5.0  ,   2.0  ,   5.0  ,  0.5   /)
  levels  =(/   1  ,     1,    1   ,   1    ,   1    ,   1    ,    1   /)
  

  binobsdir="/mnt/lfs0/projects/ciaqex/tiejuntemp/cwrf31/works/post/obs/"
  binobsfile = (/"t2m_monthly2mm5.200801_200812", \
                 "LAND_OCEAN.pr_rate_monthly.2008", \
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
    ;print(binobsdir+binobsfile(iv))
    ;if (binobsfile(iv).ne."") then
    ;obs=fbindirread(binobsdir+binobsfile(iv),0,(/12,138,195/),"float")
    ;else
    ;lvs=levels(iv)
    ;obs=new((/12,lvs,138,195/),"float")
    ;obs=0.0
    ;;end if
    ;case1=obs
    ;case2=obs
    ;case3=obs
    ;case4=obs
    ; E29NSC08 "_E36CTL08HR" "_BL8SC1" "_E36CTL08"
    caseh=(/11,13,13,13/)
    lvsr=(/2,12/)
    lvs=11
    lvs1=13 
    print("./vertout/"+varname+"_E29NSC08")
    print(sprintf("%5i",(/mnth(1)-mnth(0)+1,lvs,138,195/)))
    tmpv=fbindirread("./vertout/"+varname+"_E29NSC08",0,(/mnth(1)-mnth(0)+1,lvs,138,195/),"float") ;;;;;;;;;;;;;;;;;;;;;
    printVarSummary(tmpv)
    case1=tmpv
    delete(tmpv)
    tmpv=fbindirread("./vertout/"+varname+"_E36CTL08HR",0,(/mnth(1)-mnth(0)+1,lvs1,138,195/),"float")
    case2=tmpv(:,lvsr(0):lvsr(1),:,:)
    tmpv=fbindirread("./vertout/"+varname+"_BL8SC1",0,(/mnth(1)-mnth(0)+1,lvs1,138,195/),"float")
    case3=tmpv(:,lvsr(0):lvsr(1),:,:)
    tmpv=fbindirread("./vertout/"+varname+"_E36CTL08",0,(/mnth(1)-mnth(0)+1,lvs1,138,195/),"float") ;;;;;;;;;;;;;;;;;;;;;
    case4=tmpv(:,lvsr(0):lvsr(1),:,:)
    printMinMax(case1(0,:,55,:),True)
    print(avg(case1(0,:,55,:)))
    delete(tmpv)
    if (True ) then
    ;lvs=(/     5.0,   10.0,   20.0,   30.0,   50.0,   70.0  \
    ;           ,  100.0,  150.0,  200.0,  250.0,  300.0,  400.0  \
    ;           ,  500.0,  600.0,  700.0,  850.0,  925.0, 1000.0/)
    levs=(/   150.0,  200.0,  250.0,  300.0,  400.0  \
          ,  500.0,  600.0,  700.0,  850.0,  925.0, 1000.0/)
    levs@units="hPa"
    case1!0="time"
    case1!1="levels"
    case1&levels=levs
    case1!2="south_north"
    case1!3="west_east"
    copy_VarAtts(case1,case2)
    copy_VarAtts(case1,case3)
    copy_VarAtts(case1,case4)
    copy_VarCoords(case1,case2)
    copy_VarCoords(case1,case3)
    copy_VarCoords(case1,case4)
    casen=(/ " L29+SC0+BL8 ", " L36+SC0+BL8 "," L36+SC1+BL8 "," L36+SC1+BL9 "/)
    case1@longname=varname+casen(0)
    case2@longname=varname+casen(1)
    case3@longname=varname+casen(2)
    case4@longname=varname+casen(3)

    print(varname)

    month=(/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)
    do i=0,11
      month(i)=year+" "+month(i)
    end do
    ;if (isaccuml(iv)) then
    ;  do i=1,12
    ;    j=i-1
    ;    dofm(j)=days_in_month(stringtoint(yeara(iy))+1900,i)
    ;    case1(j,:,:)=case1(j,:,:)/dofm(j)
    ;    case2(j,:,:)=case2(j,:,:)/dofm(j)
    ;    case3(j,:,:)=case3(j,:,:)/dofm(j)
    ;    case4(j,:,:)=case4(j,:,:)/dofm(j)
    ;  end do
    ;end if 

    ;d1o=case1-obs
    ;d2o=case2-obs
    ;d3o=case3-obs
    ;d4o=case4-obs
    ;d1o@longname=varname+casen(1)+"-"+casen(0)
    ;d2o@longname=varname+casen(2)+"-"+casen(0)
    ;d3o@longname=varname+casen(3)+"-"+casen(0)
    ;d4o@longname=varname+casen(4)+"-"+casen(0)
    ;d21=case2-case1
    ;d43=case4-case3
    ;d31=case3-case1
    ;d21@longname=varname+casen(2)+"-"+casen(1)
    ;d43@longname=varname+casen(4)+"-"+casen(3)
    ;d31@longname=varname+casen(3)+"-"+casen(1)
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
    wks = gsn_open_wks("ps","NCASE2008UWPBL_"+year+varname)         ; open a workstation
    plot = new(4,graphic)

    ;gsn_define_colormap(wks,"gui_default")    ; choose colormap
    gsn_merge_colormaps(wks,"gui_default","posneg_1")
    ;gsn_draw_colormap(wks)

    res = True
    res@tiMainString = ""

    ;res@vpWidthF = 0.7
    ;res@vpHeightF =0.7

    res@gsnDraw = False
    res@gsnFrame = False

;    res@mpLimitMode       = "Corners"         ; choose range of map
;    res@mpLeftCornerLatF  =  15.22807
;    res@mpLeftCornerLonF  =  -120.7703 ;lon2d@corners(0)
;    res@mpRightCornerLatF = 49.03231 ;lat2d@corners(2)
;    res@mpRightCornerLonF = -52.39819 ;lon2d@corners(2)
    
;    res@pmTickMarkDisplayMode = "Always"
;    res@mpFillOn              = False           ; turn off map fill
;    res@mpOutlineDrawOrder    = "PostDraw"      ; draw continental outline last
;    res@mpOutlineBoundarySets = "GeophysicalAndUSStates" ; state boundaries

;
;    res@mpProjection        = "LambertConformal"
;    res@mpLambertParallel1F = 60.
;    res@mpLambertParallel2F = 30.
;    res@mpLambertMeridianF  = -95.5

    res@cnLineLabelsOn       = False                 ; turn on line labels
    res@cnFillOn             = True                  ; turn on color fill
    res@cnLinesOn            = False
    res@gsnSpreadColors      = True                  ; use full range of colors
    res@lbLabelAutoStride    = True                  ; optimal labels
  
    res@lbOrientation            = "Vertical"     ; vertical label bar
    res@pmLabelBarOrthogonalPosF = -0.01          ; move label bar closer
    res@lbLabelStride            = 2



    res@gsnAddCyclic = False
;    res@tfDoNDCOverlay = True  ;!!!!!
;    res@tmXBLabelsOn         = False              ; do not draw bottom labels
;    res@tmYRLabelsOn         = False              ; no right labels
;    res@tmYLLabelsOn         = False              ; no left labels
;    res@tmXBOn               = False              ; no bottom tickmarks
;    res@tmXTOn               = False              
;    res@tmYLOn               = False             
;    res@tmYROn               = False            
;   
    res@gsnStringFontHeightF = 0.03

    do i=mnth(0),mnth(1)
    ;do i=0,11

    res@cnLevelSelectionMode = "ManualLevels"        ; manual contour levels
    ;res@cnLevelSelectionMode = "AutomaticLevels"        ; manual contour levels
    res@cnLevelSpacingF      =  intvar                 ; contour interval
    res@cnMinLevelValF       =  minvar               ; min level
    res@cnMaxLevelValF       =  maxvar                 ; max level

    res@gsnSpreadColors     = True     ; use full color map
    res@gsnSpreadColorStart = 2        ; start at 4
    res@gsnSpreadColorEnd   = 23       ; end at 15

    res@cnInfoLabelOn       = False           ; turn off cn info label
  res@lbLabelBarOn        = False           ; turn off individual cb's
    ;Variables
    ii=0
    res@gsnLeftString =case1@longname +  month(i)
    plot(ii) = gsn_csm_pres_hgt(wks,case1(0,:,54,:),res)
    ii=ii+1
    res@gsnLeftString =case2@longname +  month(i)
    plot(ii) = gsn_csm_pres_hgt(wks,case2(0,:,54,:),res)
    ii=ii+1
    res@gsnLeftString =case3@longname +  month(i)
    plot(ii) = gsn_csm_pres_hgt(wks,case3(0,:,54,:),res)
    ii=ii+1
    res@gsnLeftString =case4@longname +  month(i)
    plot(ii) = gsn_csm_pres_hgt(wks,case4(0,:,54,:),res)
    ii=ii+1

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
  pres@gsnPanelLabelBar    = True                ; add common colorbar
  pres@lbOrientation            = "Vertical"     ; vertical label bar
  ;pres@lbLabelFontHeightF  = 0.007               ; make labels smaller
  gsn_panel(wks,plot,(/2,2/),pres)
    

    end do
    end if ;draw or not
    
  end if
  end do
  end do
end
