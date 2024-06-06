load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

nx=195
ny=138
nt=12

c=new((/3,nt,ny,nx/),"float")
pr=new((/4,3,ny,nx/),"float")
c=0.
setfileoption("bin","ReadByteOrder","BigEndian")
c(0,:,:,:)=fbindirread("/scratch/scratchdirs/xingyuan/CWRF/ASWDNS9097_0004_meanISCCP.bin",0,(/nt,ny,nx/),"float")
c(1,:,:,:)=fbindirread("/scratch/scratchdirs/xingyuan/CWRF/ASWDNS9097_0004_meanNOAH.bin",0,(/nt,ny,nx/),"float")
c(2,:,:,:)=fbindirread("/scratch/scratchdirs/xingyuan/CWRF/ASWDNS9097_0004_meanCSSP.bin",0,(/nt,ny,nx/),"float")
pr@missingvalue=1.e20
pr@_FillValue=1.e20
copy_VarAtts(pr,c)
do i=0,2
      pr(0,i,:,:)=(c(i,0,:,:)*31+c(i,1,:,:)*28+c(i,11,:,:)*31)/90.
      pr(1,i,:,:)=(c(i,2,:,:)*31+c(i,3,:,:)*30+c(i,4,:,:)*31)/92.
      pr(2,i,:,:)=(c(i,5,:,:)*30+c(i,6,:,:)*31+c(i,7,:,:)*31)/92.
      pr(3,i,:,:)=(c(i,8,:,:)*30+c(i,9,:,:)*31+c(i,10,:,:)*30)/91.
end do
print(c(:,1,80,100))

wks = gsn_open_wks("ps","ASWDNS9097_0004")
;gsn_define_colormap(wks,"gui_default")
gsn_define_colormap(wks,"BlWhRe")
plot = new(8,graphic)

res = True
res@gsnDraw = False
res@gsnFrame = False
;res@txFont = "Helvetica"
res@tfDoNDCOverlay = True
      
  res@mpLimitMode       = "Corners"         ; choose range of map
; res@mpLeftCornerLatF  =  15.22807
; res@mpLeftCornerLonF  =  -120.7703 ;lon2d@corners(0)
; res@mpRightCornerLatF = 49.03231 ;lat2d@corners(2)
; res@mpRightCornerLonF = -52.39819 ;lon2d@corners(2)
  res@mpLeftCornerLatF  = 19.768133
  res@mpLeftCornerLonF  = -118.259
  res@mpRightCornerLatF = 47.4818
  res@mpRightCornerLonF = -60.0576

;  res@pmTickMarkDisplayMode = "Always"        ;Axis
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
;  res@pmLabelBarOrthogonalPosF = -0.01          ; move label bar closer
  res@lbLabelStride            = 2

  res@gsnAddCyclic = False
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnLevelSpacingF = 10.
  res@cnMinLevelValF  = -60.
  res@cnMaxLevelValF  = 60.
  res@tiMainString = ""
  res@lbLabelBarOn    = False          ; Turn off individual labelbars.
  res@lbAutoManage         = False
  res@lbLabelFontHeightF   = 0.02
  res@tiMainFontHeightF  = 0.02
  res@gsnLeftStringFontHeightF = 0.02
  res@gsnRightStringFontHeightF = 0.02
ta=(/"CWRF/NOAH","CWRF/CSSP"/)
tb=(/" (DJF)"," (MAM)"," (JJA)"," (SON)"/)
do i=0,1
   do j=0,3
      res@gsnLeftString = ta(i)+tb(j)
      res@gsnRightString = "1990-2004"
      plot(j+i*4) = gsn_csm_contour_map(wks,pr(j,i+1,14:ny-15,14:nx-15)-pr(j,0,14:ny-15,14:nx-15),res)
   end do
end do
   pres                  = True         ; Set panel resources.
   pres@gsnPanelLabelBar = True         ; Turn on panel labelbar.
   pres@lbLabelStride    = 1
   pres@pmLabelBarWidthF= 0.6          ; Change labelbar width.
   pres@lbLabelAutoStride    = True
   pres@gsnSpreadColors      = True
   gsn_panel(wks,plot,(/2,4/),pres)

  end
