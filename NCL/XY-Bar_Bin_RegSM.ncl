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
    DATA_DIR_OBS     = (/"pr", "t2m/daily", "t2max/daily", "t2min/daily"/)
    ; FILE_OBS_MONTHLY = (/"LAND_OCEAN.pr_rate_monthly.1993"  \
    ;                  ,   "t2m_monthly2mm5.199301_199312"    \
    ;                  ,   "tmax_monthly2mm5.199301_199312"   \
    ;                  ,   "tmin_monthly2mm5.199301_199312"/)
    FILE_OBS_DAILY   = (/"LAND_OCEAN.pr_rate_daily.1993"      \
                     ,   "ta_30km_daily.stn.cwrf.1993"        \
                     ,   "tmax_30km_daily.stn.cwrf.1993"      \
                     ,   "tmin_30km_daily.stn.cwrf.1993"/)

    FILE_LANDMASK = "/scratch/scratchdirs/lgchen/data/lcc_xing/lcc"

    DIR_SIM       = "/scratch/scratchdirs/lgchen/projects/data/GPF"
    VAR_NUM       = 2
    VAR_LIST      = (/"PR", "T2M", "T2MAX", "T2MIN"/)
    VAR_DESC      = (/"mm/day", "Celsius", "Celsius", "Celsius"/)  ; for YAxisString

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
  
    SEASON_NUM    = 4
    SEASON_NAME   = (/"DJF", "MAM", "JJA", "SON"/)
    STATISTIC_NUM = 3

    NX            = 195
    NY            = 138

    MOFY          = 12
    MOFS          = (/0, 3, 6, 9, 12/)
    ; DOFM          = (/31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31/)
    DOFM          = (/0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365/)
    DOFS          = (/0, 90, 182, 274, 365/)
    DOFY          = 365

    ; STATISTIC_NUM: seasonal mean, stddev_1(time average first) and stddev_2(region average first) 
    ; CTL scheme is the first one
    obs_sm_sd     = new ((/VAR_NUM,           REG_NUM, SEASON_NUM, STATISTIC_NUM/), "float")  
    ens_sm_sd     = new ((/VAR_NUM,           REG_NUM, SEASON_NUM, STATISTIC_NUM/), "float") 
    sim_sm_sd     = new ((/VAR_NUM, CASE_NUM, REG_NUM, SEASON_NUM, STATISTIC_NUM/), "float") 
    obs_sm_sd     = 0.0
    ens_sm_sd     = 0.0
    sim_sm_sd     = 0.0

    landmask      = new ((/NY, NX/), "float")
    landmask      = 0

    var_monthly   = new ((/MOFY + 1, NY, NX/), "float")
    var_monthly_tmp = new ((/MOFY, NY, NX/), "float")
    var_daily     = new ((/DOFY + 31, NY, NX/), "float")
    var_daily_tmp = new ((/DOFY, NY, NX/), "float")
    var_2d        = new ((/NY, NX/), "float")
    var_ssn       = new ((/SEASON_NUM, NY, NX/), "float")
    sd_1_ssn      = new ((/SEASON_NUM, NY, NX/), "float")
    reg_monthly   = new ((/MOFY, REG_NUM/), "float")
    reg_daily     = new ((/DOFY, REG_NUM/), "float")
    x_tmp         = new ((/CASE_NUM + 2, STATISTIC_NUM/), "float")
    var_monthly   = 0.0
    var_monthly_tmp = 0.0
    var_daily     = 0.0
    var_daily_tmp = 0.0
    var_2d        = 0.0
    var_ssn       = 0.0
    sd_1_ssn      = 0.0
    reg_monthly   = 0.0
    reg_daily     = 0.0
    x_tmp         = 0.0

    SPV           = 1.0e20

    obs_sm_sd@missingvalue     = SPV
    obs_sm_sd@_FillValue       = SPV
    ens_sm_sd@missingvalue     = SPV
    ens_sm_sd@_FillValue       = SPV
    sim_sm_sd@missingvalue     = SPV
    sim_sm_sd@_FillValue       = SPV
 
    var_monthly@missingvalue   = SPV
    var_monthly@_FillValue     = SPV   
    var_monthly_tmp@missingvalue = SPV
    var_monthly_tmp@_FillValue   = SPV
    var_daily@missingvalue     = SPV
    var_daily@_FillValue       = SPV
    var_daily_tmp@missingvalue = SPV
    var_daily_tmp@_FillValue   = SPV
    var_2d@missingvalue        = SPV
    var_2d@_FillValue          = SPV
    var_ssn@missingvalue       = SPV
    var_ssn@_FillValue         = SPV
    sd_1_ssn@missingvalue      = SPV
    sd_1_ssn@_FillValue        = SPV
    reg_monthly@missingvalue   = SPV
    reg_monthly@_FillValue     = SPV
    reg_daily@missingvalue     = SPV
    reg_daily@_FillValue       = SPV

 
    setfileoption("bin","ReadByteOrder","BigEndian")

    landmask = fbindirread(FILE_LANDMASK, 0, (/NY, NX/), "float")
    
    ; read data and compute the seasonal mean for obs
    do i_var = 0, VAR_NUM - 1
        var_daily(31: , :, :) = fbindirread(ROOT_DIR_OBS + "/" + DATA_DIR_OBS(i_var) + "/"  \
                              + FILE_OBS_DAILY(i_var), 0, (/DOFY, NY, NX/), "float")
        var_daily(0:30, :, :) = var_daily(365:395, :, :)

        ; var_daily = where(abs(var_daily) .gt. 1.0e5, var_daily@missingvalue, var_daily)

        ; compute daily time series data for each region
        do i_reg = 0, 8 - 1
            reg_daily(:, i_reg) = dim_avg_n(var_daily(0 : DOFY - 1, REG_WINDOW(i_reg, 1):REG_WINDOW(i_reg, 3),  \
                REG_WINDOW(i_reg, 0):REG_WINDOW(i_reg, 2)), (/1, 2/))
        end do

        ; for land region
        var_daily_tmp = var_daily(0 : DOFY - 1, :, :)
        do i_day = 0, DOFY - 1
            var_daily_tmp(i_day, :, :) = where(landmask .ne. 16, var_daily_tmp(i_day, :, :), var_daily_tmp@missingvalue)
        end do
        reg_daily(:, 8) = dim_avg_n(var_daily_tmp(:, 14:123, 14:180), (/1, 2/))

        ; for ocean region
        var_daily_tmp = var_daily(0 : DOFY - 1, :, :)
        do i_day = 0, DOFY - 1
            var_daily_tmp(i_day, :, :) = where(landmask .eq. 16, var_daily_tmp(i_day, :, :), var_daily_tmp@missingvalue)
        end do
        reg_daily(:, 9) = dim_avg_n(var_daily_tmp(:, 14:123, 14:180), (/1, 2/))           

        ; compute seasonal mean and 2 seasonal standard deviations
        do i_ssn = 0, SEASON_NUM - 1
            ; first compute the 2nd seasonal standard deviation
            do i_reg = 0, REG_NUM - 1
                obs_sm_sd(i_var, i_reg, i_ssn, 2) = dim_stddev_n(reg_daily(DOFS(i_ssn):DOFS(i_ssn+1)-1, i_reg), 0)
                ; obs_sm_sd(i_var, i_reg, i_ssn, 2) = dim_stddev(reg_daily(DOFS(i_ssn):DOFS(i_ssn+1)-1, i_reg))  ; is it ok?
            end do

            ; second compute the seasonal mean and the 1st standard deviation
            var_ssn (i_ssn, :, :) = dim_avg_n   (var_daily(DOFS(i_ssn):DOFS(i_ssn+1)-1, :, :), 0)
            sd_1_ssn(i_ssn, :, :) = dim_stddev_n(var_daily(DOFS(i_ssn):DOFS(i_ssn+1)-1, :, :), 0)
           
            ; for 8 normal regions 
            do i_reg = 0, 8 - 1
                obs_sm_sd(i_var, i_reg, i_ssn, 0) = avg(  \
                    var_ssn(i_ssn, REG_WINDOW(i_reg, 1):REG_WINDOW(i_reg, 3), REG_WINDOW(i_reg, 0):REG_WINDOW(i_reg, 2)))
                obs_sm_sd(i_var, i_reg, i_ssn, 1) = avg(  \
                    sd_1_ssn(i_ssn, REG_WINDOW(i_reg, 1):REG_WINDOW(i_reg, 3), REG_WINDOW(i_reg, 0):REG_WINDOW(i_reg, 2)))
            end do

            ; for land region
            var_2d = where(landmask .ne. 16, var_ssn(i_ssn, :, :), var_2d@missingvalue)
            N      = num(ismissing(var_2d(14:123, 14:180)))
            print("Num of missing value for seasonal mean on land area: " + N) 
            obs_sm_sd(i_var, 8, i_ssn, 0) = avg(var_2d(14:123, 14:180))

            var_2d = where(landmask .ne. 16, sd_1_ssn(i_ssn, :, :), var_2d@missingvalue)
            obs_sm_sd(i_var, 8, i_ssn, 1) = avg(var_2d(14:123, 14:180))

            ; for ocean region
            var_2d = where(landmask .eq. 16, var_ssn(i_ssn, :, :), var_2d@missingvalue)
            N      = num(ismissing(var_2d(14:123, 14:180)))
            print("Num of missing value for seasonal mean on ocean area: " + N)
            obs_sm_sd(i_var, 9, i_ssn, 0) = avg(var_2d(14:123, 14:180))

            var_2d = where(landmask .eq. 16, sd_1_ssn(i_ssn, :, :), var_2d@missingvalue)
            obs_sm_sd(i_var, 9, i_ssn, 1) = avg(var_2d(14:123, 14:180))
        end do

    end do

    ; temporarily let ens = obs
    ens_sm_sd = obs_sm_sd

    ; read data and compute the seasonal mean for sim
    do i_var = 0, VAR_NUM - 1
        do i_case = 0, CASE_NUM - 1
            var_daily   = fbindirread(DIR_SIM + "/" + CASE_LIST(i_case) + "_"  \
                        + VAR_LIST(i_var) + "_daily.bin", 0, (/DOFY+31, NY, NX/), "float")
            var_monthly = fbindirread(DIR_SIM + "/" + CASE_LIST(i_case) + "_"  \
                        + VAR_LIST(i_var) + "_monthly.bin", 0, (/13, NY, NX/), "float")           

            if (i_var .eq. 0) then
                do i_mon = 1, MOFY
                    var_monthly(i_mon, :, :) = var_monthly(i_mon, :, :) / (DOFM(i_mon) - DOFM(i_mon-1))
                end do
            end if           
 
            if (i_var .ne. 0) then
                var_daily   = var_daily - 273.15
                var_monthly = var_monthly - 273.15
            end if
 
            var_daily  (0:30, :, :) = var_daily  (365:395, :, :)
            var_monthly(0   , :, :) = var_monthly(12     , :, :)

            ; compute daily time series data for each region
            do i_reg = 0, 8 - 1
                reg_daily(:, i_reg) = dim_avg_n(var_daily(0 : DOFY - 1, REG_WINDOW(i_reg, 1):REG_WINDOW(i_reg, 3),  \
                    REG_WINDOW(i_reg, 0):REG_WINDOW(i_reg, 2)), (/1, 2/))
                reg_monthly(:, i_reg) = dim_avg_n(var_monthly(0 : MOFY - 1, REG_WINDOW(i_reg, 1):REG_WINDOW(i_reg, 3),  \
                    REG_WINDOW(i_reg, 0):REG_WINDOW(i_reg, 2)), (/1, 2/))
            end do

            ; for land region
            var_daily_tmp = var_daily(0 : DOFY - 1, :, :)
            do i_day = 0, DOFY - 1
                var_daily_tmp(i_day, :, :) = where(landmask .ne. 16, var_daily_tmp(i_day, :, :), var_daily_tmp@missingvalue)
            end do
            reg_daily(:, 8) = dim_avg_n(var_daily_tmp(:, 14:123, 14:180), (/1, 2/))

            var_monthly_tmp = var_monthly(0 : MOFY - 1, :, :)
            do i_mon = 0, MOFY - 1
                var_monthly_tmp(i_mon, :, :) = where(landmask .ne. 16, var_monthly_tmp(i_mon, :, :), var_monthly_tmp@missingvalue)
            end do
            reg_monthly(:, 8) = dim_avg_n(var_monthly_tmp(:, 14:123, 14:180), (/1, 2/)) 

            ; for ocean region
            var_daily_tmp = var_daily(0 : DOFY - 1, :, :)
            do i_day = 0, DOFY - 1
                var_daily_tmp(i_day, :, :) = where(landmask .eq. 16, var_daily_tmp(i_day, :, :), var_daily_tmp@missingvalue)
            end do
            reg_daily(:, 9) = dim_avg_n(var_daily_tmp(:, 14:123, 14:180), (/1, 2/))

            var_monthly_tmp = var_monthly(0 : MOFY - 1, :, :)
            do i_mon = 0, MOFY - 1
                var_monthly_tmp(i_mon, :, :) = where(landmask .eq. 16, var_monthly_tmp(i_mon, :, :), var_monthly_tmp@missingvalue)
            end do
            reg_monthly(:, 9) = dim_avg_n(var_monthly_tmp(:, 14:123, 14:180), (/1, 2/))

            ; compute seasonal mean and 2 seasonal standard deviations
            do i_ssn = 0, SEASON_NUM - 1
                ; first compute the 2nd seasonal standard deviation
                do i_reg = 0, REG_NUM - 1
                    sim_sm_sd(i_var, i_case, i_reg, i_ssn, 2) = dim_stddev_n(reg_daily(DOFS(i_ssn):DOFS(i_ssn+1)-1, i_reg), 0)
                end do

                ; second compute the seasonal mean and the 1st standard deviation
                var_ssn (i_ssn, :, :) = dim_avg_n   (var_daily(DOFS(i_ssn):DOFS(i_ssn+1)-1, :, :), 0)
                ; var_ssn (i_ssn, :, :) = dim_avg_n   (var_monthly(MOFS(i_ssn):MOFS(i_ssn+1)-1, :, :), 0)
                sd_1_ssn(i_ssn, :, :) = dim_stddev_n(var_daily(DOFS(i_ssn):DOFS(i_ssn+1)-1, :, :), 0)

                ; for 8 normal regions
                do i_reg = 0, 8 - 1
                    sim_sm_sd(i_var, i_case, i_reg, i_ssn, 0) = dim_avg_n(  \
                        var_ssn(i_ssn:i_ssn, REG_WINDOW(i_reg, 1):REG_WINDOW(i_reg, 3), REG_WINDOW(i_reg, 0):REG_WINDOW(i_reg, 2))  \
                        , (/1, 2/))  ; lgchen: should it be (/0, 1/)
                    sim_sm_sd(i_var, i_case, i_reg, i_ssn, 1) = dim_avg_n(  \
                        sd_1_ssn(i_ssn:i_ssn, REG_WINDOW(i_reg, 1):REG_WINDOW(i_reg, 3), REG_WINDOW(i_reg, 0):REG_WINDOW(i_reg, 2))  \
                        , (/1, 2/))  ; lgchen: should it be (/0, 1/)
                end do

                ; for land region
                ; can't be i_ssn:i_ssn, otherwise dimension mismatch error!
                var_2d = where(landmask .ne. 16, var_ssn(i_ssn, :, :), var_2d@missingvalue)  
                sim_sm_sd(i_var, i_case, 8, i_ssn, 0) = avg(var_2d(14:123, 14:180))
                var_2d = where(landmask .ne. 16, sd_1_ssn(i_ssn, :, :), var_2d@missingvalue)
                sim_sm_sd(i_var, i_case, 8, i_ssn, 1) = avg(var_2d(14:123, 14:180))

                ; for ocean region
                var_2d = where(landmask .eq. 16, var_ssn(i_ssn, :, :), var_2d@missingvalue)
                sim_sm_sd(i_var, i_case, 9, i_ssn, 0) = avg(var_2d(14:123, 14:180))
                var_2d = where(landmask .eq. 16, sd_1_ssn(i_ssn, :, :), var_2d@missingvalue)
                sim_sm_sd(i_var, i_case, 9, i_ssn, 1) = avg(var_2d(14:123, 14:180))
            end do

        end do
    end do


    ; DRAWING
 
    wks_pdf_sm    = gsn_open_wks("pdf", "./SeasonalMean")
    ; wks_pdf_sd_1  = gsn_open_wks("pdf", "./Stddev_TimeAvgFirst")
    ; wks_pdf_sd_2  = gsn_open_wks("pdf", "./Stddev_RegionAvgFirst")
    ; gsn_define_colormap(wks_pdf, "gui_default")
    ; newcolor = NhlNewColor(wks_pdf_sm, 0.42, 0.42, 0.42)

    plot_pdf_sm   = new (4, graphic)
    plot_pdf_sd_1 = new (4, graphic)
    plot_pdf_sd_2 = new (4, graphic)
    
    res          = True
    res@gsnDraw  = False  ; don't draw
    res@gsnFrame = False  ; don't advance frame
    ; res@gsnMaximize = True  ; Maximize plot in frame, would become landscape mode
    res@gsnXYBarChart = True
    res@gsnXYBarChartBarWidth = 0.5  ; originally 0.15, default bar width = dynamic
    ; res@gsnAboveYRefLineBarPatterns = (/17/)  ; all these commands are valid only when it has YRefLine 
    ; res@gsnBelowYRefLineBarPatterns = (/17/) 
    ; res@gsnXYBarChartPatterns = (/1, 3, 4/)
    ; res@gsnXYBarChartPatterns2 = (/1, 3, 4/)
    ; res@gsFillIndex = 17  ; not a valid resource here
    res@gsnXYBarChartPatterns2 = (/17/)

    ; res@gsnPaperMargin = 0.2  ; default: 0.5 in inch

    res@vpWidthF = 0.75
    res@vpHeightF = 0.12
    res@vpXF = 0.1
    ; res@vpYF = 0.9

    res@trXMinF = 0
    res@trXMaxF = CASE_NUM + 2 + 1
    ; res@trYMinF = 0.0
    ; res@trYMaxF = 1.2

    res@tmYROn      = False  ; Turn off YR ticks
    res@tmXTOn      = False  ; Turn off XT ticks
    ; res@tmXBOn      = False  ; Turn off XB ticks
    res@tmYLMinorOn = False  ; Turn off YL minor ticks
    res@tmXBMinorOn = False  ; Turn off XB minor ticks
    res@tmXBMajorLengthF = 0.005
    res@tmYLMajorLengthF = 0.005
    res@tmXBMajorOutwardLengthF = -0.002
    res@tmYLMajorOutwardLengthF = -0.002
    res@tmXBLabelDeltaF = -1.2
    res@tmYLLabelDeltaF = -1.2

    ; res@tmYLAutoPrecision = False
    ; res@tmYLPrecision     = 2
    res@tmYLLabelFontHeightF = 0.01
 
    ; res@tmXTBorderOn = False
    ; res@tmYRBorderOn = False

    res@tmXBMode = "Explicit"
    res@tmXBValues = ispan(1, CASE_NUM + 2, 1)
    ; res@tmXBLabelJust = "CenterLeft"  ; default: TopCenter
    ; res@tmXBLabelAngelF = 90.0
    res@tmXBLabelDirection = "Down"  ; default: Across
    res@tmXBLabelFontHeightF = 0.008
    res@tmXBLabelConstantSpacingF = 0.1  ; originally 0.3
    ; originally "MP-GODDARD GCE", "RA-RRTMLW_GSFCSW"
    ; res@tmXBLabels = (/"OBS", "ENS", "CTL", "SF|CSSP", "SF|ECMWF", "SF|NOAH", "SF|PX", "SF|NOBLORO"  \
    ;                ,   "BL|ACM", "BL|GFS", "BL|MYJ", "BL|QNSE", "BL|UW", "BL|YSU"                    \
    ;                ,   "CU|BMJ", "CU|GD", "CU|GDL", "CU|ZML", "CU|RANDALL", "CU|GFDL", "CU|MIT"      \
    ;                ,   "MP|LIN", "MP|FERRIER", "MP|WSM 5", "MP|WSM 6", "MP|GODDARD GCE"              \
    ;                ,   "MP|MORRISON", "MP|WDM 5", "MP|WDM 6", "MP|REISNER"                           \
    ;                ,   "RA|CAM", "RA|CCCMA", "RA|FULIOU", "RA|RRTMLW_GSFCSW"/)
    res@tmXBLabels = (/"OBS", "ENS", "CTL"                                 \
                   ,   "Avg", "AER", "CAM", "CCC", "CSIRO", "FL", "GFDL"  \
                   ,   "NOAH", "PX", "CSSPn", "OroOFF"                    \
                   ,   "ACM", "BouLAC", "GFS", "MYJ", "QNSE", "YSU", "UW"  \
                   ,   "BMJ", "CSU", "GD", "GFDL", "MIT", "ZML"            \
                   ,   "Lin", "Morri", "WDM6", "WSM6", "WSM5", "Zhao"      \  ; removed mp07 = "GODDARD"
                   ,   "ECMWF"/)
 
   do i_var = 0, VAR_NUM - 1
        res@gsnLeftString = VAR_LIST(i_var)
        ; res@tiXAxisString = "Physical Schemes"
        res@tiYAxisString = VAR_DESC(i_var)

        do i_reg = 0, REG_NUM - 1
            res@gsnCenterString = REG_NAME(i_reg)

            do i_ssn = 0, SEASON_NUM - 1
                res@gsnRightString = SEASON_NAME(i_ssn)

                x_tmp(0, :) = obs_sm_sd(i_var, i_reg, i_ssn, :)
                x_tmp(1, :) = ens_sm_sd(i_var, i_reg, i_ssn, :)
                do i_case = 0, CASE_NUM - 1
                    x_tmp(i_case+2, :) = sim_sm_sd(i_var, i_case, i_reg, i_ssn, :)
                end do

                if (i_var .gt. 0 .and. i_reg .eq. 9) then  ; no obs temperature on ocean
                    x_tmp(0:1, :) = x_tmp@missingvalue
                end if

                ; res@gsFillColor      = (/"red"/)
                ; res@gsEdgeColor      = (/"red"/)
                res@gsnYRefLine = max((/min(x_tmp(:, 0)) - 0.5, 0.0/))
                res@trYMinF     = max((/min(x_tmp(:, 0)) - 0.5, 0.0/))
                res@vpYF        = 0.98 - i_ssn*0.05  ; originally 0.1
                if (i_ssn .eq. SEASON_NUM - 1) then
                    ; res@tmXBMode = "Explicit"
                    res@tmXBOn   = True
                else
                    ; res@tmXBMode = "Automatic"
                    res@tmXBOn   = False
                end if
                plot_pdf_sm(i_ssn)   = gsn_csm_xy(wks_pdf_sm  , ispan(1, CASE_NUM + 2, 1), x_tmp(:, 0), res)
                ; draw(plot_pdf_sm(i_ssn))
                ; plot_pdf_sm(i_ssn)   = gsn_histogram(wks_pdf_sm  , x_tmp(:, 0), res)
                ; plot_pdf_sd_1(i_ssn) = gsn_histogram(wks_pdf_sd_1, x_tmp(:, 1), res)
                ; plot_pdf_sd_2(i_ssn) = gsn_histogram(wks_pdf_sd_2, x_tmp(:, 2), res)
            end do 
            ; frame(wks_pdf_sm)

            resP = True
            ; resP@gsnMaximize = True
            gsn_panel(wks_pdf_sm  , plot_pdf_sm  , (/4, 1/), False)
            ; gsn_panel(wks_pdf_sd_1, plot_pdf_sd_1, (/4, 1/), False)
            ; gsn_panel(wks_pdf_sd_2, plot_pdf_sd_2, (/4, 1/), False)
           
            ; quit

        end do
    end do

    ; maximize_output(wks_pdf, True)  ; calls draw and frame for you 

end
