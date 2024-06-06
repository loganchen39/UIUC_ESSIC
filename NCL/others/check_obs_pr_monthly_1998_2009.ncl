; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "/global/u2/t/tjling/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "/global/u2/t/tjling/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "/global/u2/t/tjling/lib/ncarg/nclscripts/csm/contributed.ncl"


begin

nt=12
nx=195
ny=138

DIR_ROOT_PR = "/project/projectdirs/cwrf/observation/Precipitation"

;original station data from cressman objective analysis
 setfileoption("bin","ReadByteOrder","BigEndian")

;original station from Liang
 pr_stn = fbindirread(DIR_ROOT_PR + "/STN/stm_pr_30km_monthly.2004m",0,(/nt,ny,nx/),"float")

;station data adjusted by PRISM monthly 
 pr_stn_prism = fbindirread(DIR_ROOT_PR + "/STN_PRISM/US_MEX.pr_rate_monthly.prism.2004",0,(/nt,ny,nx/),"float") 

;PRISM oregon
 pr_prism = fbindirread(DIR_ROOT_PR + "/PRISM/ppt_monthly2mm5.200401_200412",0,(/nt,ny,nx/),"float") 

;TRMM data
pr_trmm = fbindirread(DIR_ROOT_PR + "/TRMM/TRMM_monthly.195x138.new.2004.bin",0,(/nt,ny,nx/),"float")

;CMAP data
pr_cmap = fbindirread(DIR_ROOT_PR + "/CMAP/precip.monthly.mean.2004.195x138",0,(/nt,ny,nx/),"float")

;xie-arkin
pr_xie = fbindirread(DIR_ROOT_PR + "/XIE/XIE_GLB_monthly.2004.195x138",0,(/nt,ny,nx/),"float")

;combined
pr_com = fbindirread(DIR_ROOT_PR + "/COMBINED/LAND_OCEAN.pr_rate_monthly.2004",0,(/nt,ny,nx/),"float")

pr_stn@missingvalue=1.e20
pr_stn@_FillValue = 1.e20
pr_stn_prism@missingvalue=1.e20
pr_stn_prism@_FillValue = 1.e20
pr_prism@missingvalue=1.e20
pr_prism@_FillValue = 1.e20
pr_trmm@missingvalue=1.0e20
pr_trmm@_FillValue = 1.0e20
pr_cmap@missingvalue=1.e20
pr_cmap@_FillValue = 1.e20
pr_xie@missingvalue=1.e20
pr_xie@_FillValue = 1.e20
pr_com@missingvalue=1.e20
pr_com@_FillValue = 1.e20

wks = gsn_open_wks("ps","pr_2004_Jul.rcm")
gsn_define_colormap(wks,"gui_default")

plot = new(8,graphic)

    ;gsn_define_colormap(wks,"gui_default")    ; choose colormap
    ;gsn_merge_colormaps(wks,"gui_default","posneg_1")  ; from lingtiejun
    ;gsn_merge_colormaps(wks,"WhViBlGrYeOrRe","posneg_1")  ; from lingtiejun
     gsn_merge_colormaps(wks,"WhViBlGrYeOrRe","BlWhRe")  ; from lingtiejun
    ;gsn_define_colormap(wks,"WhViBlGrYeOrRe")   ; from Yuanxing
    ;gsn_draw_colormap(wks)

    res = True
    res@tiMainString = ""

;    res@vpWidthF = 0.7
;    res@vpHeightF =0.7

    res@gsnDraw = False
    res@gsnFrame = False

    res@mpLimitMode       = "Corners"         ; choose range of map
;    res@mpLeftCornerLatF  =  15.22807
;    res@mpLeftCornerLonF  =  -120.7703 ;lon2d@corners(0)
;    res@mpRightCornerLatF = 49.03231 ;lat2d@corners(2)
;    res@mpRightCornerLonF = -52.39819 ;lon2d@corners(2)

     res@mpLeftCornerLatF  = 19.768133
     res@mpLeftCornerLonF  = -118.259
     res@mpRightCornerLatF = 47.4818
     res@mpRightCornerLonF = -60.0576


;    res@pmTickMarkDisplayMode = "Always"
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
   ; res@lbLabelAutoStride    = True                  ; optimal labels
    res@lbLabelBarOn    = False                      ; Turn off individual labelbars.

   ; res@lbOrientation            = "Vertical"     ; vertical label bar
   ; res@pmLabelBarOrthogonalPosF = -0.01          ; move label bar closer
   ; res@lbLabelStride            = 2


   ; res@lbLabelFontHeightF   = 0.02
   ; res@tiMainFontHeightF  = 0.035


    res@gsnAddCyclic = False
    res@tfDoNDCOverlay = True  ;!!!!!

   res@cnLevelSelectionMode = "ManualLevels"        ; manual contour levels
    res@cnLevelSpacingF      =  1.0                 ; contour interval
    res@cnMinLevelValF       =  1.0               ; min level
    res@cnMaxLevelValF       =  10.0                 ; max level

    res@gsnSpreadColors     = True     ; use full color map
    res@gsnSpreadColorStart = 2        ; start at 4
    res@gsnSpreadColorEnd   = 102       ; end at 15

    res@gsnStringFontHeightF = 0.03

 ;  res@gsnPaperOrientation      = "landscape"
 ;  res@gsnMaximize            = True


  res@gsnLeftString   = "Station 2004 Jul PR" 
  plot(0) = gsn_csm_contour_map(wks,pr_stn(6,14:ny-15,14:nx-15),res)
  res@gsnLeftString   = "Station Prism "
  plot(1) = gsn_csm_contour_map(wks,pr_stn_prism(6,14:ny-15,14:nx-15),res)
  res@gsnLeftString   = "Prism "
  plot(2) = gsn_csm_contour_map(wks,pr_prism(6,14:ny-15,14:nx-15),res)
  res@gsnLeftString   = "TRMM"
  plot(3) = gsn_csm_contour_map(wks,pr_trmm(6,14:ny-15,14:nx-15),res)
  res@gsnLeftString   = "CMAP"
  plot(4) = gsn_csm_contour_map(wks,pr_cmap(6,14:ny-15,14:nx-15),res)
  res@gsnLeftString   = "XIE"
  plot(5) = gsn_csm_contour_map(wks,pr_xie(6,14:ny-15,14:nx-15),res)
  res@gsnLeftString   = "COMBINED"
  plot(6) = gsn_csm_contour_map(wks,pr_com(6,14:ny-15,14:nx-15),res)
  
  ; gsn_panel(wks,plot,(/3,3/),False)
  gsn_panel(wks,plot,(/4,2/),False)

  end
