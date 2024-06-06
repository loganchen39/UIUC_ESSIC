load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
    ; region window /  20,  36, 85, 121   ; Cascade
    ;               ,  42,  62, 89, 117   ; North Rockies
    ;               ,  74,  91, 55,  90   ; Central Great Plain
    ;               , 104, 133, 66,  93   ; Midwest
    ;               , 139, 166, 80, 116   ; Northeast
    ;               , 134, 155, 28,  69   ; Southeast
    ;               ,  94, 128, 39,  63   ; Coast States
    ;               ,  51,  70, 16,  70/  ; NAM 

    ROOT_DIR_OBS     = "/project/projectdirs/cwrf/cwrf/observation"
    DATA_DIR_OBS     = (/"pr", "t2m/monthly", "t2max/monthly", "t2min/monthly"/)
    FILE_OBS_MONTHLY = (/"LAND_OCEAN.pr_rate_monthly.1993"  \
                     ,   "t2m_30km_monthly.stn+cru.1993"    \
                     ,   "tmax_30km_monthly.stn+cru.1993"   \
                     ,   "tmin_30km_monthly.stn+cru.1993"/)
    ; FILE_OBS_DAILY   = (/"LAND_OCEAN.pr_rate_daily.1993"  \
    ;                  ,   "ta_30km_daily.stn.cwrf.1993"    \
    ;                  ,   "tmax_30km_daily.stn.cwrf.1993"  \
    ;                  ,   "tmin_30km_daily.stn.cwrf.1993"/)

    FILE_LANDMASK = "/scratch/scratchdirs/lgchen/data/lcc_xing/lcc"

    DIR_SIM       = "/scratch/scratchdirs/lgchen/projects/data/GPF"
    VAR_NUM       = 2
    VAR_LIST      = (/"PR", "T2M", "T2MAX", "T2MIN"/)
    VAR_DESC      = (/"(mm/day)", "(~S~o~N~C)", "Celsius", "Celsius"/)  ; for YAxisString

    CASE_NUM      = 1 + 7 + 4 + 7 + 6 + 6 + 1  
    ; CASE_LIST     = (/"CTL", "CWRF-CSSP", "ECMWF", "CWRF-NOAH", "CWRF-PX", "run_noBLORO",      \
    ;                   "acm", "gfs", "myj", "qnse", "uw", "ysu",                                \
    ;                   "run_cu2_bmj", "run_cu4_gd", "run_cu5_gdl", "run_cu7_zml",               \
    ;                   "run_cu8_randall", "run_cu9_gfdl", "run_cu10_mit",                       \
    ;                   "mp02", "mp04", "mp05", "mp06", "mp10", "mp15", "mp16", "mp86",  \  ; removed "mp07"
    ;                   "cam", "cccma", "csiro", "eta", "fuliou", "ragfdl", "rrtmlw_gsfcsw"/)  ; NEWgsfclxz not ready
    CASE_LIST     = (/"CWRF-CSSP",                                                              \ 
                      "gsfclxz", "rrtmlw_gsfcsw", "cam", "cccma", "csiro", "fuliou", "ragfdl",  \  ; NEWgsfclxz not ready
                      "CWRF-NOAH", "CWRF-PX", "CTL", "run_noBLORO",                             \
                      "acm", "boulac", "gfs", "myj", "qnse", "ysu", "uw",                       \
                      "run_cu2_bmj", "run_cu8_randall", "run_cu4_gd", "run_cu9_gfdl",           \
                      "run_cu10_mit", "run_cu7_zml",                                            \
                      "mp02", "mp10", "mp16", "mp06", "mp05", "mp04",  \  ; removed "mp07"
                      "ECMWF"/) 
    CASE_NAME      = (/"CTL"                                               \
                   ,   "Avg", "AER", "CAM", "CCC", "CSIRO", "FL", "GFDL"   \
                   ,   "NOAH", "PX", "CSSPn", "OroOFF"                     \
                   ,   "ACM", "BouLAC", "GFS", "MYJ", "QNSE", "YSU", "UW"  \
                   ,   "BMJ", "CSU", "GD", "GFDL", "MIT", "ZML"            \
                   ,   "Lin", "Morri", "WDM6", "WSM6", "WSM5", "Zhao"      \  ; removed mp07 = "GODDARD"
                   ,   "ECMWF"/)     

    REG_NUM       = 8 + 2
    REG_NAME      = (/"Cascade"  , "North Rockies", "Central Great Plain", "Midwest"  \
                  ,   "Northeast", "Southeast"    , "Coast States"       , "NAM"      \
                  ,   "Land", "Ocean"/)
    REG_WINDOW    = (/(/ 20,  85,  36, 121/)  \  ; (xb, yb, xe, ye) 
                  ,   (/ 42,  89,  62, 117/)  \
                  ,   (/ 74,  55,  91,  90/)  \
                  ,   (/104,  66, 133,  93/)  \
                  ,   (/139,  80, 166, 116/)  \
                  ,   (/134,  28, 155,  69/)  \
                  ,   (/ 94,  39, 128,  63/)  \
                  ,   (/ 51,  16,  70,  70/)/)
    REG_WINDOW    = REG_WINDOW - 1
  
    NX            = 195
    NY            = 138

    MOFY          = 12
    MONTH_NUM     = 12
    ; DOFM          = (/31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31/)
    DOFM          = (/0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365/)
    DOFY          = 365

    ; STATISTIC_NUM: seasonal mean, stddev_1(time average first) and stddev_2(region average first) 
    ; CTL scheme is the first one
    obs_mm = new ((/VAR_NUM,           REG_NUM, MONTH_NUM/), "float")  
    ens_mm = new ((/VAR_NUM,           REG_NUM, MONTH_NUM/), "float") 
    sim_mm = new ((/VAR_NUM, CASE_NUM, REG_NUM, MONTH_NUM/), "float") 
    obs_mm = 0.0
    ens_mm = 0.0
    sim_mm = 0.0

    landmask      = new ((/NY, NX/), "float")
    landmask      = 0

    var_monthly     = new ((/MONTH_NUM + 1, NY, NX/), "float")
    var_monthly_tmp = new ((/MOFY, NY, NX/), "float")
    y_tmp           = new ((/2, MONTH_NUM/), "float")
    ; var_2d        = new ((/NY, NX/), "float")
    ; reg_monthly   = new ((/MOFY, REG_NUM/), "float")
    var_monthly     = 0.0
    var_monthly_tmp = 0.0
    y_tmp           = 0.0

    SPV           = 1.0e20

    obs_mm@missingvalue = SPV
    obs_mm@_FillValue   = SPV
    ens_mm@missingvalue = SPV
    ens_mm@_FillValue   = SPV
    sim_mm@missingvalue = SPV
    sim_mm@_FillValue   = SPV
 
    var_monthly@missingvalue     = SPV
    var_monthly@_FillValue       = SPV   
    var_monthly_tmp@missingvalue = SPV
    var_monthly_tmp@_FillValue   = SPV

 
    setfileoption("bin","ReadByteOrder","BigEndian")

    landmask = fbindirread(FILE_LANDMASK, 0, (/NY, NX/), "float")
    
    ; read data and compute the monthly mean for obs
    do i_var = 0, VAR_NUM - 1
        var_monthly(0:MONTH_NUM-1, :, :) = fbindirread(ROOT_DIR_OBS + "/" + DATA_DIR_OBS(i_var) + "/"  \
            + FILE_OBS_MONTHLY(i_var), 0, (/MONTH_NUM, NY, NX/), "float")

        var_monthly = where(abs(var_monthly) .gt. 1.0e4, var_monthly@missingvalue, var_monthly)

        ; compute monthly mean for each region
        do i_reg = 0, 8 - 1
            obs_mm(i_var, i_reg, :) = dim_avg_n(var_monthly(0:MONTH_NUM-1, REG_WINDOW(i_reg, 1):REG_WINDOW(i_reg, 3),  \
                REG_WINDOW(i_reg, 0):REG_WINDOW(i_reg, 2)), (/1, 2/))
        end do

        ; for land region
        var_monthly_tmp = var_monthly(0:MONTH_NUM-1, :, :)
        do i_mon = 0, MONTH_NUM - 1
            var_monthly_tmp(i_mon, :, :) = where(landmask .ne. 16, var_monthly_tmp(i_mon, :, :), var_monthly_tmp@missingvalue)
        end do
        obs_mm(i_var, 8, :) = dim_avg_n(var_monthly_tmp(:, 14:123, 14:180), (/1, 2/))

        ; for ocean region
        var_monthly_tmp = var_monthly(0:MONTH_NUM-1, :, :)
        do i_mon = 0, MONTH_NUM - 1
            var_monthly_tmp(i_mon, :, :) = where(landmask .eq. 16, var_monthly_tmp(i_mon, :, :), var_monthly_tmp@missingvalue)
        end do
        obs_mm(i_var, 9, :) = dim_avg_n(var_monthly_tmp(:, 14:123, 14:180), (/1, 2/))
    end do

    ; temporarily let ens = obs
    ens_mm = obs_mm

    ; read data and compute the monthly mean for sim
    do i_var = 0, VAR_NUM - 1
        do i_case = 0, CASE_NUM - 1
            var_monthly = fbindirread(DIR_SIM + "/" + CASE_LIST(i_case) + "_"  \
                        + VAR_LIST(i_var) + "_monthly.bin", 0, (/13, NY, NX/), "float")           

            if (i_var .eq. 0) then  ; PR
                do i_mon = 1, MONTH_NUM
                    var_monthly(i_mon, :, :) = var_monthly(i_mon, :, :) / (DOFM(i_mon) - DOFM(i_mon-1))
                end do
            end if           
 
            if (i_var .ne. 0) then  ; temperature
                var_monthly = var_monthly - 273.15
            end if
 
            ; var_monthly(0   , :, :) = var_monthly(12     , :, :)

            ; compute monthly mean for each region
            do i_reg = 0, 8 - 1
                sim_mm(i_var, i_case, i_reg, :) = dim_avg_n(var_monthly(1:MONTH_NUM,  \
                    REG_WINDOW(i_reg, 1):REG_WINDOW(i_reg, 3), REG_WINDOW(i_reg, 0):REG_WINDOW(i_reg, 2)), (/1, 2/))
            end do

            ; for land region
            var_monthly_tmp = var_monthly(1:MONTH_NUM, :, :)
            do i_mon = 0, MONTH_NUM - 1
                var_monthly_tmp(i_mon, :, :) = where(landmask .ne. 16, var_monthly_tmp(i_mon, :, :), var_monthly_tmp@missingvalue)
            end do
            sim_mm(i_var, i_case, 8, :) = dim_avg_n(var_monthly_tmp(:, 14:123, 14:180), (/1, 2/))

            ; for ocean region
            var_monthly_tmp = var_monthly(1:MONTH_NUM, :, :)
            do i_mon = 0, MONTH_NUM - 1
                var_monthly_tmp(i_mon, :, :) = where(landmask .eq. 16, var_monthly_tmp(i_mon, :, :), var_monthly_tmp@missingvalue)
            end do
            sim_mm(i_var, i_case, 9, :) = dim_avg_n(var_monthly_tmp(:, 14:123, 14:180), (/1, 2/))
        end do
    end do


    ; DRAWING
 
    wks_pdf_mm    = gsn_open_wks("pdf", "./TimeSeries_MonthlyMean")
    ; gsn_define_colormap(wks_pdf, "gui_default")

    plot_pdf_mm   = new (8, graphic)
    
    res          = True
    res@gsnDraw  = False  ; don't draw
    res@gsnFrame = False  ; don't advance frame

    res@vpWidthF  = 0.3
    res@vpHeightF = 0.4
    ; res@vpXF = 0.1
    ; ; res@vpYF = 0.9

    res@trXMinF = 0
    res@trXMaxF = MONTH_NUM + 1

    res@tiYAxisString = " "

    res@tmYROn      = False  ; Turn off YR ticks
    res@tmXTOn      = False  ; Turn off XT ticks
    res@tmYLMinorOn = False  ; Turn off YL minor ticks
    res@tmXBMinorOn = False  ; Turn off XB minor ticks
    res@tmXBMajorLengthF = 0.008
    res@tmYLMajorLengthF = 0.008
    res@tmXBMajorOutwardLengthF = 0.008
    res@tmYLMajorOutwardLengthF = -0.002
    ; res@tmXBLabelDeltaF = -1.2
    ; res@tmYLLabelDeltaF = -1.2

    ; res@tmYLAutoPrecision = False
    ; res@tmYLPrecision     = 2
    ; res@tmYLLabelFontHeightF = 0.01

    res@tmXBMode = "Explicit"
    res@tmXBValues = ispan(1, MONTH_NUM, 1)
    ; res@tmXBLabelJust = "CenterLeft"  ; default: TopCenter
    ; res@tmXBLabelAngelF = 90.0
    ; res@tmXBLabelDirection = "Down"  ; default: Across
    ; res@tmXBLabelFontHeightF = 0.008
    ; res@tmXBLabelConstantSpacingF = 0.1  ; originally 0.3
    
    res@tmXBLabels = (/"J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D"/)
    
    res@xyDashPatterns    = (/0, 1/)
    res@xyLineThicknesses = (/2.0, 1.0/) 
    res@xyLineColors      = (/"black", "blue"/)    
 
    do i_var = 0, VAR_NUM - 1
        res@gsnLeftString  = VAR_LIST(i_var) + " " + VAR_DESC(i_var)
        ; res@tiYAxisString = VAR_DESC(i_var)

        do i_case = 0, CASE_NUM - 1
            res@gsnRightString = CASE_NAME(i_case)

            do i_reg = 0, 8 - 1  ; REG_NUM - 1
                res@gsnCenterString = REG_NAME(i_reg)

                y_tmp(0, :) = obs_mm(i_var, i_reg, :)
                y_tmp(1, :) = sim_mm(i_var, i_case, i_reg, :)
                plot_pdf_mm(i_reg) = gsn_csm_xy(wks_pdf_mm, ispan(1, MONTH_NUM, 1), y_tmp(0:1, :), res)
            end do
            gsn_panel(wks_pdf_mm, plot_pdf_mm, (/2, 4/), False)
        end do
    end do

end
