load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

nx=195
ny=138


var=new((/26,ny,nx,3,3/),"float")
var1=new((/4,ny,nx,3,3/),"float")
enso=(/1,0,-1,0,1,0,-1,0,0,1,0,0,1,-1,0,1,-1,-1,-1,0,1,0,0,0,0,-1/)
f=addfile("PrChaOBS.nc","r")
var(:,:,:,0,0)=f->NumPR
var(:,:,:,0,1)=f->MDSL
var(:,:,:,0,2)=f->PerPR

f=addfile("PrChaCFSens.nc","r")
var(:,:,:,1,0)=f->NumPR
var(:,:,:,1,1)=f->MDSL
var(:,:,:,1,2)=f->PerPR

f=addfile("PrChaCWRFens.nc","r")
var(:,:,:,2,0)=f->NumPR
var(:,:,:,2,1)=f->MDSL
var(:,:,:,2,2)=f->PerPR

var1@_FillValue=1.0E20
var1@missingvalue=1.0E20

var1=0.
n1=0
n2=0
n3=0
do i=0,25
   var1(0,:,:,:,:)=var1(0,:,:,:,:)+var(i,:,:,:,:)
   if (enso(i) .gt. 0) then
      var1(1,:,:,:,:)=var1(1,:,:,:,:)+var(i,:,:,:,:)
      n1=n1+1
   end if
   if (enso(i) .lt. 0)then
      var1(2,:,:,:,:)=var1(2,:,:,:,:)+var(i,:,:,:,:)
      n2=n2+1
   end if
   if (enso(i) .eq. 0)then
      var1(3,:,:,:,:)=var1(3,:,:,:,:)+var(i,:,:,:,:)
      n3=n3+1
   end if
end do
var1(0,:,:,:,:)=var1(0,:,:,:,:)/26
var1(1,:,:,:,:)=var1(1,:,:,:,:)/n1
var1(2,:,:,:,:)=var1(2,:,:,:,:)/n2
var1(3,:,:,:,:)=var1(3,:,:,:,:)/n3
print(n1+n2+n3)

setfileoption("bin","ReadByteOrder","BigEndian")

wks = gsn_open_wks("ps","fig2")
gsn_merge_colormaps(wks,"gui_default","posneg_1")
plot = new(12,graphic)

res = True
res@gsnDraw = False
res@gsnFrame = False
res@txFont = "Helvetica"
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

; res@pmTickMarkDisplayMode = "Always"
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

;  res@lbOrientation            = "Vertical"     ; vertical label bar
  res@pmLabelBarOrthogonalPosF = -0.02          ; move label bar closer
cvar=(/"a) Number of Rainy Days","b) Maximum Dry Spell Length","c) Daily Rainfall 95th Percentile"/)
cmdl=(/"OBS","CFS","CWRF"/)
amx=(/50.,40.,40./)
amn=(/5.,5.,5./)
asp=(/5.,5.,5./)
ast=(/2,2,2/)

  res@gsnAddCyclic = False
  res@cnLevelSelectionMode = "ManualLevels"
  res@lbAutoManage         = False
  res@lbLabelFontHeightF   = 0.02
;  res@tiMainFontHeightF  = 0.025
;  res@gsnLeftStringFontHeightF = 0.03
;  res@gsnCenterStringFontHeightF = 0.025
  res@gsnStringFontHeightF = 0.025
  res@tiYAxisFontHeightF = 0.025
  res@tiMainString = ""
  res@gsnLeftString = ""
  
  res@gsnSpreadColorStart = 2        
  res@gsnSpreadColorEnd   = 23
do i=0,2 
  res@cnLevelSpacingF = asp(i)
  res@cnMinLevelValF  = amn(i)
  res@cnMaxLevelValF  = amx(i)
  res@lbLabelStride   = ast(i)
  do j=0,2
     if (j.eq.0) then
        res@gsnCenterString = cvar(i)
     else
        res@gsnCenterString = ""
     end if
     if (i.eq.0) then
        res@tiYAxisString = cmdl(j)
     else
        res@tiYAxisString = ""
     end if
     if (j.lt.2) then
        res@lbLabelBarOn    = False
     else
        res@lbLabelBarOn    = True
     end if
     plot(j*4+i) = gsn_csm_contour_map(wks,var1(0,14:ny-15,14:nx-15,j,i),res)
  end do
end do
  res@gsnSpreadColorStart = 27
  res@gsnSpreadColorEnd   = 44
  res@cnLevelSpacingF = 2
  res@cnMinLevelValF  = -6.
  res@cnMaxLevelValF  = 6.
  res@lbLabelStride   = 1
  do j=0,2
     if (j.eq.0) then
        res@gsnCenterString = "d) Number of Rainy Days (Warm - Cold)"
     else
        res@gsnCenterString = ""
     end if
     res@tiYAxisString = ""
     if (j.lt.2) then
        res@lbLabelBarOn    = False
     else
        res@lbLabelBarOn    = True
     end if
     plot(j*4+3) = gsn_csm_contour_map(wks,var1(1,14:ny-15,14:nx-15,j,0)-var1(2,14:ny-15,14:nx-15,j,0),res)
  end do
  pres = True
  pres@gsnPanelDebug     = True     ; To get information from panel
  pres@gsnPanelXF = (/0.021,0.247,0.473,0.699,0.021,0.247,0.473,0.699,0.021,0.247,0.473,0.699/)    ; Adjust rightmost plots
  pres@gsnPanelYF = (/-1,-1,-1,-1,0.593,0.593,0.593,0.593,0.444,0.444,0.444,0.444/)      ; Adjust bottommost plots.

  gsn_panel(wks,plot,(/3,4/),pres)

  end
