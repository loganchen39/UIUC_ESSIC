load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

  yeara=(/"08"/)
  imnth=(/1,8/)
  ;yeara=(/"93","98"/)
  varnamea=(/"T2MAX","T2M  ","PR","ASWDNS","ALWDNS","ASWUPS","ALWUPS","SFCEVP","TCWPC","TCWPI","TCWPR"/)
  ifdraw  =(/False ,True  ,True  ,False   ,False   ,False   ,False   ,False   , False ,False  ,False  /)
  isaccuml=(/False ,False ,True  ,False   ,False   ,False   ,False   ,True    , False ,False  ,False  /)
  maxvara =(/305.0 ,305.0 , 16.0 , 400.0  , 460.0  ,  90.0  , 540.0  , 10.0   ,  1800.,   360.,    60./)
  minvara =(/250.0 ,250.0 ,  0.0 , 150.0  , 200.0  ,  10.0  , 300.0  ,  0.0   ,     0.,0.     ,0.     /)
  intvara =(/  2.5 ,  2.5 ,  1.0 ,  10.0  ,  10.0  ,   5.0  ,  10.0  ,  1.0   ,   100.,    20.,    2.5/)
  maxdifa =(/  3.0 ,  3.0 ,  5.0 ,  60.0  ,  40.0  ,  20.0  ,  30.0  ,  5.0   ,   100.,    20.,     3./)
  mindifa =(/ -3.0 , -3.0 , -5.0 , -60.0  , -40.0  , -20.0  , -30.0  , -5.0  ,   -100.,   -20.,  -3.  /)
  intdifa =(/  0.5 ,  0.5 ,  0.5 ,  10.0  ,   5.0  ,   2.0  ,   5.0  ,  0.5   ,    10.,    10.,    1. /)
  binobsdir="/mnt/lfs0/projects/ciaqex/tiejuntemp/cwrf31/works/post/obs/"
  binobsfile = (/"LAND_OCEAN.t2m_monthly.2008","t2m_monthly2mm5.200801_200812", \
                 "LAND_OCEAN.pr_rate_monthly.2008", \
  		"","","","","","","","",""/)
  
 ; montha=(/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)
  dofm =new((/12/),"integer")
  mnth=imnth-1
  do iy=0,dimsizes(yeara)-1
  do iv=0,dimsizes(varnamea)-1
  if (ifdraw(iv)) then
    varname=varnamea(iv)
    year=yeara(iy)
    setfileoption("bin","ReadByteOrder","BigEndian")

    case1=fbindirread("./newout/"+varname+"_E36CTL08",0,(/mnth(1)-mnth(0)+1,138,195/),"float") ;;;;;;;;;;;;;;;;;;;;;

    case1@longname=varname+" SC 08 "
    month=(/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)

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
    wks = gsn_open_wks("ps","CASE_20"+year+varname)         ; open a workstation
    plot = new(12,graphic)

    print("CASE_20"+year+varname)
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
    res@lbLabelBarOn        = False
    res@gsnLeftString =case1@longname + " " + month(i)
    plot(i) = gsn_csm_contour_map(wks,case1(i,:,:),res)
    print(case1@longname + " " + month(i))
    pres                 = True
;    pres@gsnPanelRowSpec = True                   ; tell panel what order to plt
    resP                  = True                   ; modify the panel plot
    resP@gsnFrame         = False                  ; don't advance panel plot
    resP@gsnPanelLabelBar = True                   ; add common colorbar
    resP@gsnPanelBottom   = 0.05

    end do
    gsn_panel(wks,plot,(/4,3/),resP)
    


    
  end if
  end do
  end do
end
