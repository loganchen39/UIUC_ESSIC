load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

  yeara=(/"04"/)
  imonth=(/4,5,6,7,8,9,10/) 
  nomnth=dimsizes(imonth)
    im=138
    jm=195

  intvar=10.
  maxvar=60.
  minvar=-100.

  intdif=10.
  maxdif= 80.
  mindif=-80.
  ;calculation CLDFRC_Surface of MDL
  labels=(/"a. ","b. ","c. ","d. ","e. ","f. " ,"g. ","h. ","i. ","j. ","k. "/)
  
  dataroot="/mnt/lfs0/projects/ciaqex/tiejuntemp/cwrf31/works/post/COMPARE/old_err/"
  dataroot="../old_err/"
  casename=(/"E29NSC04","E36NSC04"/)
  titles  =(/"L29","L36"/)
  subdir="rad_2004040100_2004103100"
  
  
  static="/mnt/lfs0/projects/ciaqex/tiejuntemp/cwrf31/works/post/COMPARE/wrfinput_d01.nc"
  static="../wrfinput_d01.nc"
  fstatic=addfile(static,"r")
  lat2d=fstatic->XLAT(0,:,:)
  lon2d=fstatic->XLONG(0,:,:)
  buff=7
  ib=buff-1
  ie=im-buff-1
  jb=buff-1
  je=jm-buff-1
  msk=fstatic->LANDMASK(0,ib:ie,jb:je)

  setfileoption("bin","ReadByteOrder","BigEndian")
  mlwdnsc=new((/dimsizes(casename),nomnth,im,jm/),"float")
  mlwdns =new((/dimsizes(casename),nomnth,im,jm/),"float")
  mlwupsc=new((/dimsizes(casename),nomnth,im,jm/),"float")
  mlwups =new((/dimsizes(casename),nomnth,im,jm/),"float")
  mswdnsc=new((/dimsizes(casename),nomnth,im,jm/),"float")
  mswdns =new((/dimsizes(casename),nomnth,im,jm/),"float")
  mswupsc=new((/dimsizes(casename),nomnth,im,jm/),"float")
  mswups =new((/dimsizes(casename),nomnth,im,jm/),"float")
  do i=0,dimsizes(casename)-1
    mlwdnsc(i,:,:,:)=fbindirread(dataroot+casename(i)+"/"+subdir+"/"+"ALWDNSC"+"_"+casename(i),0,(/nomnth,im,jm/),"float") 
    mlwdns(i,:,:,:)=fbindirread(dataroot+casename(i)+"/"+subdir+"/"+"ALWDNS" +"_"+casename(i),0,(/nomnth,im,jm/),"float")
    mlwupsc(i,:,:,:)=fbindirread(dataroot+casename(i)+"/"+subdir+"/"+"ALWUPSC"+"_"+casename(i),0,(/nomnth,im,jm/),"float")
    mlwups(i,:,:,:)=fbindirread(dataroot+casename(i)+"/"+subdir+"/"+"ALWUPS" +"_"+casename(i),0,(/nomnth,im,jm/),"float")
    mswdnsc(i,:,:,:)=fbindirread(dataroot+casename(i)+"/"+subdir+"/"+"ASWDNSC"+"_"+casename(i),0,(/nomnth,im,jm/),"float")
    mswdns(i,:,:,:)=fbindirread(dataroot+casename(i)+"/"+subdir+"/"+"ASWDNS" +"_"+casename(i),0,(/nomnth,im,jm/),"float")
    mswupsc(i,:,:,:)=fbindirread(dataroot+casename(i)+"/"+subdir+"/"+"ASWUPSC"+"_"+casename(i),0,(/nomnth,im,jm/),"float")
    mswups(i,:,:,:)=fbindirread(dataroot+casename(i)+"/"+subdir+"/"+"ASWUPS" +"_"+casename(i),0,(/nomnth,im,jm/),"float")
  end do

  olwdnsc  =mlwdnsc(0,:,:,:)
  olwdns   =mlwdns(0,:,:,:)
  olwupsc  =mlwupsc(0,:,:,:)
  olwups   =mlwups(0,:,:,:)
  oswdnsc  =mswdnsc(0,:,:,:)
  oswdns   =mswdns(0,:,:,:)
  oswupsc  =mswupsc(0,:,:,:)
  oswups   =mswups(0,:,:,:)

  

  ; read CLDFRA_Surface of OBS
  dataroot="../../obs/zf/radiation_CERES_Terra_FM2_2004/"
  do i=imonth(0),imonth(nomnth-1)
    j=i-imonth(0)
    olwdnsc(j,:,:)=fbindirread(dataroot+"rad2004"+sprinti("%2.2i",i)+".grd",14,(/im,jm/),"float") 
     olwdns(j,:,:)=fbindirread(dataroot+"rad2004"+sprinti("%2.2i",i)+".grd", 4,(/im,jm/),"float")
    olwupsc(j,:,:)=fbindirread(dataroot+"rad2004"+sprinti("%2.2i",i)+".grd",15,(/im,jm/),"float")
     olwups(j,:,:)=fbindirread(dataroot+"rad2004"+sprinti("%2.2i",i)+".grd", 5,(/im,jm/),"float")
    oswdnsc(j,:,:)=fbindirread(dataroot+"rad2004"+sprinti("%2.2i",i)+".grd",16,(/im,jm/),"float")
     oswdns(j,:,:)=fbindirread(dataroot+"rad2004"+sprinti("%2.2i",i)+".grd", 6,(/im,jm/),"float")
    oswupsc(j,:,:)=fbindirread(dataroot+"rad2004"+sprinti("%2.2i",i)+".grd",17,(/im,jm/),"float")
     oswups(j,:,:)=fbindirread(dataroot+"rad2004"+sprinti("%2.2i",i)+".grd", 7,(/im,jm/),"float")
  end do
  ;yeara=(/"93","98"/)
  month=(/"","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)     

  dofm =new((/12/),"integer")
  do iy=0,dimsizes(yeara)-1
    year=yeara(iy)
    ;end if

    wks = gsn_open_wks("ps","report_RAD_"+year)         ; open a workstation
    plot = new(3,graphic)

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
    res@mpLeftCornerLatF  = lat2d(ib,jb) ; 15.22807
    res@mpLeftCornerLonF  = lon2d(ib,jb) ; -120.7703 ;lon2d@corners(0)
    res@mpRightCornerLatF = lat2d(ie,je) ;49.03231 ;lat2d@corners(2)
    res@mpRightCornerLonF = lon2d(ie,je) ;-52.39819 ;lon2d@corners(2)
    
    
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

    do i=4,4 ;3,3 ;3,3 ;0,nomnth-1
    ;do i=0,11
    
    varname="ASWDNS" ;=============================================================
    obs=oswdns(i,ib:ie,jb:je)
    mdl=mswdns(:,i,ib:ie,jb:je)
    
    do jj=0,dimsizes(casename)-1
      tmp=mdl(jj,:,:)
      mdl(jj,:,:)=where(msk.eq.1,tmp,-999.)
      delete(tmp)
    end do
    print((/ib,ie,jb,je/))
    printMinMax(mdl,True)
    res@cnLevelSelectionMode = "ManualLevels"        ; manual contour levels
    res@cnLevelSpacingF      =  10.                 ; contour interval
    res@cnMinLevelValF       =  150.               ; min level
    res@cnMaxLevelValF       =  400.                 ; max level
    res@gsnSpreadColors     = True     ; use full color map
    res@gsnSpreadColorStart = 2        ; start at 4
    res@gsnSpreadColorEnd   = 23       ; end at 15
    ;Variables
    ii=0
    do jj=0,dimsizes(casename)-1
    res@gsnLeftString =labels(ii)+ varname+" " + titles(jj) ;month(imonth(i))
    res@gsnRightString = "W m-2"
    plot(ii) = gsn_csm_contour_map(wks,mdl(jj,:,:),res)
    ii=ii+1
    end do
    res@cnLevelSpacingF      =   2.5               ; contour interval
    res@cnMinLevelValF       =  -20.               ; min level
    res@cnMaxLevelValF       =  20.                 ; max level
    res@gsnSpreadColorStart = 27       ; start at 4
    res@gsnSpreadColorEnd   = 44       ; end at 15
    do jj=1,dimsizes(casename)-1
       res@gsnLeftString=labels(ii)+varname+" "+titles(jj)+"-"+titles(0)  
       plot(ii) = gsn_csm_contour_map(wks,mdl(jj,:,:)-mdl(0,:,:),res)
       ii=ii+1
    end do
    pres                 = True
    pres@gsnPanelRowSpec = True                   ; tell panel what order to plt
    gsn_panel(wks,plot,(/3/),pres)
    exit
    
    varname="ASWUPS" ;=============================================================
    obs=oswups(i,ib:ie,jb:je)
    mdl=mswups(:,i,ib:ie,jb:je)
    res@cnLevelSelectionMode = "ManualLevels"        ; manual contour levels
    res@cnLevelSpacingF      =   5.                 ; contour interval
    res@cnMinLevelValF       =   10.               ; min level
    res@cnMaxLevelValF       =   90.                 ; max level
    res@gsnSpreadColors     = True     ; use full color map
    res@gsnSpreadColorStart = 2        ; start at 4
    res@gsnSpreadColorEnd   = 23       ; end at 15
    ;Variables
    ii=0
    res@gsnLeftString =labels(ii)+varname+" OBS " + month(imonth(i))
    plot(ii) = gsn_csm_contour_map(wks,obs,res)
    ii=ii+1
    do jj=0,dimsizes(casename)-1
    res@gsnLeftString = casename(jj)+varname+" " + month(imonth(i))
    plot(ii) = gsn_csm_contour_map(wks,mdl(jj,:,:),res)
    ii=ii+1
    end do
    res@cnLevelSpacingF      =   2.                ; contour interval
    res@cnMinLevelValF       =  -20.               ; min level
    res@cnMaxLevelValF       =  20.                 ; max level
    res@gsnSpreadColorStart = 27       ; start at 4
    res@gsnSpreadColorEnd   = 44       ; end at 15
    do jj=0,dimsizes(casename)-1
       res@gsnLeftString=labels(ii)+casename(jj)+"-OBS " + month(imonth(i)) 
       plot(ii) = gsn_csm_contour_map(wks,mdl(jj,:,:)-obs(:,:),res)
       ii=ii+1
    end do
    do jj=0,dimsizes(casename)-1
       res@gsnLeftString=labels(ii)+casename(jj)+"-CTL " + month(imonth(i)) 
       plot(ii) = gsn_csm_contour_map(wks,mdl(jj,:,:)-mdl(0,:,:),res)
       ii=ii+1
    end do
    pres                 = True
    pres@gsnPanelRowSpec = True                   ; tell panel what order to plt
    gsn_panel(wks,plot,(/1,4,4,4/),pres)
    
    varname="ALWDNS" ;=============================================================
    obs=olwdns(i,:,:)
    mdl=mlwdns(:,i,:,:)
    res@cnLevelSelectionMode = "ManualLevels"        ; manual contour levels
    res@cnLevelSpacingF      =   10.                 ; contour interval
    res@cnMinLevelValF       =  200.               ; min level
    res@cnMaxLevelValF       =  460.                ; max level
    res@gsnSpreadColors     = True     ; use full color map
    res@gsnSpreadColorStart = 2        ; start at 4
    res@gsnSpreadColorEnd   = 23       ; end at 15
    ;Variables
    ii=0
    res@gsnLeftString =varname+" OBS " + month(imonth(i))
    plot(ii) = gsn_csm_contour_map(wks,obs,res)
    ii=ii+1
    do jj=0,dimsizes(casename)-1
    res@gsnLeftString = casename(jj)+varname+" " + month(imonth(i))
    plot(ii) = gsn_csm_contour_map(wks,mdl(jj,:,:),res)
    ii=ii+1
    end do
    res@cnLevelSpacingF      =   5.                ; contour interval
    res@cnMinLevelValF       =  -40.               ; min level
    res@cnMaxLevelValF       =  40.                 ; max level
    res@gsnSpreadColorStart = 27       ; start at 4
    res@gsnSpreadColorEnd   = 44       ; end at 15
    do jj=0,dimsizes(casename)-1
       res@gsnLeftString=casename(jj)+"-OBS " + month(imonth(i)) 
       plot(ii) = gsn_csm_contour_map(wks,mdl(jj,:,:)-obs(:,:),res)
       ii=ii+1
    end do
    do jj=0,dimsizes(casename)-1
       res@gsnLeftString=casename(jj)+"-CTL " + month(imonth(i)) 
       plot(ii) = gsn_csm_contour_map(wks,mdl(jj,:,:)-mdl(0,:,:),res)
       ii=ii+1
    end do
    pres                 = True
    pres@gsnPanelRowSpec = True                   ; tell panel what order to plt
    gsn_panel(wks,plot,(/1,4,4,4/),pres)
    varname="ALWUPS" ;=============================================================
    obs=olwups(i,:,:)
    mdl=mlwups(:,i,:,:)
    res@cnLevelSelectionMode = "ManualLevels"        ; manual contour levels
    res@cnLevelSpacingF      =   10.                 ; contour interval
    res@cnMinLevelValF       =  300.               ; min level
    res@cnMaxLevelValF       =  540.                ; max level
    res@gsnSpreadColors     = True     ; use full color map
    res@gsnSpreadColorStart = 2        ; start at 4
    res@gsnSpreadColorEnd   = 23       ; end at 15
    ;Variables
    ii=0
    res@gsnLeftString =vlabels(ii)+arname+" OBS " + month(imonth(i))
    plot(ii) = gsn_csm_contour_map(wks,obs,res)
    ii=ii+1
    do jj=0,dimsizes(casename)-1
    res@gsnLeftString = clabels(ii)+asename(jj)+varname+" " + month(imonth(i))
    plot(ii) = gsn_csm_contour_map(wks,mdl(jj,:,:),res)
    ii=ii+1
    end do
    res@cnLevelSpacingF      =  5.                 ; contour interval
    res@cnMinLevelValF       =  -30.               ; min level
    res@cnMaxLevelValF       =  30.                 ; max level
    res@gsnSpreadColorStart = 27       ; start at 4
    res@gsnSpreadColorEnd   = 44       ; end at 15
    do jj=0,dimsizes(casename)-1
       res@gsnLeftString=clabels(ii)+asename(jj)+"-OBS " + month(imonth(i)) 
       plot(ii) = gsn_csm_contour_map(wks,mdl(jj,:,:)-obs(:,:),res)
       ii=ii+1
    end do
    do jj=0,dimsizes(casename)-1
       res@gsnLeftString=clabels(ii)+asename(jj)+"-CTL " + month(imonth(i)) 
       plot(ii) = gsn_csm_contour_map(wks,mdl(jj,:,:)-mdl(0,:,:),res)
       ii=ii+1
    end do
    pres                 = True
    pres@gsnPanelRowSpec = True                   ; tell panel what order to plt
    gsn_panel(wks,plot,(/1,4,4,4/),pres)
    
    

    end do

    
  end do
end