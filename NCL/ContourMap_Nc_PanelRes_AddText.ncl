load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

  DATA_DIR = "/scratch/scratchdirs/lgchen/projects/CWRFV3/shenjian/exe/run_cu0_nocu"
  NDAY     = 30  

  nc_name = "wrfout_d01_1993-05-02_00:00:00.nc"
  nc_file = addfile(DATA_DIR + "/" + nc_name, "r") 
  rainc   = nc_file->RAINC (0, :, :)
  rainnc  = nc_file->RAINNC(0, :, :)

  nc_name = "wrfout_d01_1993-06-01_00:00:00.netcdf"
  nc_file = addfile(DATA_DIR + "/" + nc_name, "r")
  rainc  = nc_file->RAINC (0, :, :) - rainc
  rainnc = nc_file->RAINNC(0, :, :) - rainnc

  rainc  = rainc  / NDAY
  rainnc = rainnc / NDAY
  
  wks_pdf = gsn_open_wks("pdf", "pr_mm_May_1993")
  gsn_define_colormap(wks_pdf, "gui_default")


  res                = True

  res@gsnDraw        = False 
  res@gsnFrame       = False 
  res@txFont         = "Helvetica"
  res@tfDoNDCOverlay = True
      
  res@mpLimitMode       = "Corners" ; choose range of map
  res@mpLeftCornerLatF  = 15.22807
  res@mpLeftCornerLonF  = -120.7703 ; lon2d@corners(0)
  res@mpRightCornerLatF = 49.03231  ; lat2d@corners(2)
  res@mpRightCornerLonF = -52.39819 ; lon2d@corners(2)

  ; res@pmTickMarkDisplayMode = "Always"
  res@mpFillOn              = False                    ; turn off map fill
  res@mpOutlineDrawOrder    = "PostDraw"               ; draw continental outline last
  res@mpOutlineBoundarySets = "GeophysicalAndUSStates" ; state boundaries

  res@mpProjection        = "LambertConformal"
  res@mpLambertParallel1F = 60.
  res@mpLambertParallel2F = 30.
  res@mpLambertMeridianF  = -95.5 

  res@cnLineLabelsOn    = False ; turn on line labels
  res@cnFillOn          = True  ; turn on color fill
  res@cnLinesOn         = False 
  res@gsnSpreadColors   = True  ; use full range of colors
  res@lbLabelAutoStride = True  ; optimal labels

  res@lbOrientation            = "Vertical" ; vertical label bar
  res@pmLabelBarOrthogonalPosF = -0.01      ; move label bar closer
  res@lbLabelStride            = 2

  res@gsnAddCyclic = False

  res@gsnLeftString        = "May 1993"
  res@gsnRightString       = "mm/day"
  ; res@tiMainString         = "CWRFV3 Daily Mean Precipitation"
  res@lbLabelBarOn         = False
  ; res@cnLevelSelectionMode = "ManualLevels"
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels             = fspan(1., 15., 15)

  ; res@cnLevelSpacingF = 0.05
  ; res@cnMinLevelValF  = 0.
  ; res@cnMaxLevelValF  = 0.8

  plot_pdf = new (2, graphic)

  plot_pdf(0) = gsn_csm_contour_map(wks_pdf, rainc + rainnc, res)
  plot_pdf(1) = gsn_csm_contour_map(wks_pdf, rainc + rainnc, res)

  ; add text to plot
  ; getvalues plot_pdf(1)                     
  ;   "tmXTValues"             : tmXTValues
  ;   "tmYLValues"             : tmYLValues
  ; end getvalues
  ; nTm  = dimsizes(tmXTValues)

  add_T = "text here"
  x     = 0.
  y     = 0.
  res_text = True
  res_text@txFontHeightF = 0.05
  res_text@txAngleF      = 30.
  res_text@txDirection   = "Down"
  res_text@txFontColor   = 1
  d = gsn_add_text(wks_pdf, plot_pdf(1), add_T, -100.,  \
      30., res_text)  

  res_panel = True

  res_panel@txString = "CWRFV3 Daily Mean Precipitation"

  res_panel@gsnPanelLabelBar = True  
  res_panel@lbLabelAutoStride = True  ; optimal labels
  res_panel@lbOrientation            = "Horizontal" ; vertical label bar
  res_panel@pmLabelBarOrthogonalPosF = -0.01      ; move label bar closer
  res_panel@lbLabelStride            = 2
  res_panel@cnLevelSelectionMode = "ExplicitLevels"
  res_panel@cnLevels             = fspan(1., 15., 15)

  gsn_panel(wks_pdf , plot_pdf, (/1, 2/), res_panel)

end
