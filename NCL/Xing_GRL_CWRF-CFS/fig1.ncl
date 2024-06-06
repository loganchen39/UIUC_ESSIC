load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
begin
wks  = gsn_open_wks("ps","fig11")    ; open a ncgm file
data0=new((/2,40/),"float")
rmse=new((/5,8,50/),"float")
x=new((/40/),"integer")
rmse(0,:,:) = asciiread("land-rmse1.dat",(/8,50/),"float")
rmse(1,:,:) = asciiread("land-rmse2.dat",(/8,50/),"float")
rmse(2,:,:) = asciiread("land-rmse3.dat",(/8,50/),"float")
rmse(3,:,:) = asciiread("land-rmse4.dat",(/8,50/),"float")
rmse(4,:,:) = asciiread("land-rmse5.dat",(/8,50/),"float")
season=(/"DJF","JFM","FMA","DJFMA"/)
do j=0,39
   x(j)=j
end do
do i=0,3
  do j=0,4
     data0(0,:) = rmse(j,i,0:39)
     data0(1,:) = rmse(j,i+4,0:39)
  res0                     = True          ; plot mods desired
  res0@gsnFrame = False ; don¡¯t advance
  res0@vpXF = 0.05 ; x location
  res0@vpYF = 0.75-0.2*i ; y location
  res0@vpWidthF = 0.25 ; width
  res0@vpHeightF = 0.15 ; height
  res0@xyLineColors      = (/"blue","red"/)  ; line colors
  res0@xyLineThicknesses = (/1.,1./)        ; line thicknesses
  res0@xyDashPatterns    = (/0.,0./)        ; line patterns
  res0@tmXBMode          = "Explicit"
  res0@tmXBValues        = (/0, 9, 19, 29, 39/)
  res0@tmXBLabels        = (/"0","1","2","3","4"/)
  res0@tmXTOn            = False
  res0@tiMainFontHeightF  = 0.01
  if (i.eq.0 .and. j.eq.0) then
     res0@tiMainString   = "a) Frequency of RMSE"
  else
     res0@tiMainString   = ""
  end if
  if (i.lt.3 .or. j.lt.4) then
     res0@tmXBOn            = False
  else
     res0@tmXBOn            = True
     res0@tiXAxisString     = "mm/day"
  end if
  res0@tiXAxisFontHeightF= 0.01
  res0@tmXBLabelFontHeightF    = 0.008
  res0@tmYLMode          = "Explicit"
  res0@tmYLValues        = (/0.05, 0.1/)
  res0@tmYLLabels        = (/"5%", "10%"/)
  res0@tmYROn            = False
  if (j.eq.4) then
     res0@tmYLOn            = True
     res0@tiYAxisString     = season(i)
  else
     res0@tmYLOn            = False
     res0@tiYAxisString     = ""
  end if
  res0@tiYAxisFontHeightF= 0.01
  res0@tmYLLabelFontHeightF    = 0.008
  res0@trXMinF = 0
  res0@trXMaxF = 39
  res0@trYMinF = 0.
  res0@trYMaxF = 0.12

  if (i.eq.0 .and. j.eq.0) then
  res0@pmLegendDisplayMode    = "Always"            ; turn on legend
  res0@pmLegendSide           = "Right"               ; Change location of 
  res0@pmLegendParallelPosF   = 0.8                  ; move units right
  res0@pmLegendOrthogonalPosF = -0.45                ; move units down
  res0@pmLegendWidthF         = 0.1                ; Change width and
  ;res0@pmLegendHeightF        = 0.18                ; height of legend.
  res0@lgPerimOn              = False               ; turn off box around
  ;res0@lgLabelFontHeightF     = .03                 ; label font height
  res0@xyExplicitLegendLabels = (/"CFS","CWRF"/)    ; create explicit labels
  else
    res0@pmLegendDisplayMode    = "NoCreate"      
  end if
  plot = gsn_xy(wks,x,data0,res0)          
  end do

end do

gsn_define_colormap(wks,"BlWhRe")
cfs1 = asciiread("PR-etsCFS.dat",(/108,30/),"float")
cwrf1 = asciiread("PR-etsCWRF.dat",(/108,30/),"float")
data=new((/30,108/),"float")
do i=0,29
   do j=0,107
      data(i,j)=cwrf1(j,i)-cfs1(j,i)
   end do
end do

do i=0,3
  res                     = True          ; plot mods desired
  res@cnFillOn            = True          ; turn on color
  res@gsnSpreadColors     = True          ; use full range of colormap
  res@gsnFrame = False ; don¡¯t advance
  ;res@lbOrientation            = "Vertical"
  res@cnLevelSelectionMode = "ManualLevels"	
  res@cnLevelSpacingF = 0.05
  res@cnMinLevelValF  = -0.4
  res@cnMaxLevelValF  = 0.4
  res@lbLabelStride   = 2
  res@tiYAxisFontHeightF = 0.01
  res@lbLabelFontHeightF = 0.008
  res@tiMainFontHeightF  = 0.01
  res@vpXF = 0.35 ; x location
  res@vpYF = 0.75-0.15*i ; y location
  res@vpWidthF = 0.6 ; width
  res@vpHeightF = 0.2 ; height
  res@tiYAxisString     = "mm/day"
  if (i.eq.0) then
     res@tiMainString   = "b) Difference (CWRF minus CFS) of Equitable Threat Score (ETS)"
  else
     res@tiMainString   = ""
  end if
  res@tmXBMode          = "Explicit"
  res@tmXTOn            = False
  res@tmXBValues        = (/0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26/)
  res@tmXBLabels        = (/"82","83","84","85","86","87","88","89","90","91","92","93","94","95","96","97","98","99","00","01","02","03","04","05","06","07","08"/)
  if (i.lt.3) then
     res@tmXBOn            = False
  else
     res@tmXBOn            = True
  end if
  res@tmXBMajorOutwardLengthF = 0.0               ; draw tickmarks inward
  res@tmXBMinorOutwardLengthF = 0.0               ; draw minor ticsk inward
  res@tmXBLabelFontHeightF    = 0.008
  res@tmYLMode          = "Explicit"
  res@tmYLValues        = (/5,11,17/)
  res@tmYLLabels        = (/"3","6","9"/)
  res@tmYROn            = False
  res@tmYLMajorOutwardLengthF = 0.0               ; draw tickmarks inward
  res@tmYLMinorOutwardLengthF = 0.0               ; draw minor ticsk inward
  res@tmYLLabelFontHeightF    = 0.008
  plot = gsn_csm_contour(wks,data(0:19,0+i*27:26+i*27),res)       ; contour the variable
end do

  frame(wks)

  end
