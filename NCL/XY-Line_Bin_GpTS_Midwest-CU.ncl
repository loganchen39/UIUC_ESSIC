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

    VAR_NUM  = 6
    VAR_LIST = (/"PR", "RAINC", "RAINNC", "T2M", "T2MAX", "T2MIN"/)
    VAR_DESC = (/"mm/day", "mm/day", "mm/day", "Celsius", "Celsius", "Celsius"/)  ; for YAxisString

    ROOT_DIR_OBS         = "/scratch/scratchdirs/lgchen/data/obs"
    VAR_DIR_OBS          = (/"pr", "t2m", "t2max", "t2min"/)
    FILE_OBS_PR_DLY_1992 = "LAND_OCEAN.pr_rate_daily.1992"
    FILE_OBS_DLY         = (/"LAND_OCEAN.pr_rate_daily.1993"    \
                         ,   "ta_30km_daily.stn.cwrf.1993"      \
                         ,   "tmax_30km_daily.stn.cwrf.1993"    \
                         ,   "tmin_30km_daily.stn.cwrf.1993"/)

    FILE_LANDMASK = "/global/u1/l/lgchen/data/lcc_xing/lcc"

    ROOT_DIR_SIM = "/project/projectdirs/cwrf/cwrf_post_results/general_paper_1992Dec1993"
    PHY_NUM      = 5
    PHY_DESC     = (/"bl", "cu", "mp", "ra", "sf"/)
    SCHM_NUM_ARR = (/0, 8, 18, 25, 33, 38/)
    SCHM_NUM_ALL = SCHM_NUM_ARR(PHY_NUM) + 1  ; 1 for ctl
    SCHM_DIR_SIM = (/"ctl", "bl_acm", "bl_boulac", "bl_gfs", "bl_myj", "bl_orooff"    \
                 ,   "bl_qnse", "bl_uw", "bl_ysu"                                     \
                 ,   "cu_bmj", "cu_bmjcwp3", "cu_csu", "cu_g3", "cu_gd", "cu_gfdl"    \ 
                 ,   "cu_mit", "cu_nkf", "cu_shallow_off", "cu_zml"                   \
                 ,   "mp_lin", "mp_morrison", "mp_thompson", "mp_wdm6", "mp_wsm5"     \
                 ,   "mp_wsm6", "mp_zhao"                                             \
                 ,   "ra_aerosoloff", "ra_cam", "ra_cawcr", "ra_cccma", "ra_doclavg"  \
                 ,   "ra_fuliou", "ra_gfdl", "ra_rrtmg"                               \
                 ,   "sf_eri", "sf_narr", "sf_noah", "sf_px", "sf_uomoff"/)
    SCHM_FN_PREF = (/"ctl", "acm", "boulac", "gfs", "myj", "oro_off"       \
                 ,   "qnse", "uw", "ysu"                                   \
                 ,   "bmj", "bmj_cwp3", "csu", "g3", "gd", "gfdl"          \
                 ,   "mit", "nkf", "shallow0", "zml_bluefire"              \
                 ,   "lin", "morrison", "thompson", "wdm6", "wsm5"         \
                 ,   "wsm6", "zhao"                                        \
                 ,   "aerosol_off", "cam", "cawcr", "cccma", "do_cl_avg1"  \
                 ,   "fuliou", "gfdl", "rrtmg"                             \
                 ,   "CWRF-ERI", "CWRF-NARR", "CWRF-NOAH", "CWRF-PX", "uom_off"/)
    SCHM_DESC    = (/"ctl", "bl:acm", "bl:boulac", "bl:gfs", "bl:myj", "bl:oro_off"    \
                 ,   "bl:qnse", "bl_uw", "bl_ysu"                                      \
                 ,   "cu:bmj", "cu:bmj_cwp3", "cu:csu", "cu:g3", "cu:gd", "cu:gfdl"    \
                 ,   "cu:mit", "cu:nkf", "cu:shallow_off", "cu:zml"                    \
                 ,   "mp:lin", "mp:morrison", "mp:thompson", "mp:wdm6", "mp:wsm5"      \
                 ,   "mp:wsm6", "mp:zhao"                                              \
                 ,   "ra:aerosol_off", "ra:acm", "ra:cawcr", "ra:cccma", "ra:doclavg"  \
                 ,   "ra:fuliou", "ra:gfdl", "ra:rrtmg"                                \
                 ,   "sf:eri", "sf:narr", "sf:noah", "sf:px", "sf:uom_off"/)

    PHY_IDX      = 1

    NX = 195
    NY = 138

    REG_NUM    = 8 + 2
    REG_NAME   = (/"Cascade"  , "North Rockies", "Central Great Plain", "Midwest"  \
               ,   "Northeast", "Southeast"    , "Coast States"       , "NAM"      \
               ,   "Land"     , "Ocean"/)
    REG_WINDOW = (/(/ 20,  85,  36, 121/)  \  ; (xb, yb, xe, ye) 
               ,   (/ 42,  89,  62, 117/)  \
               ,   (/ 74,  55,  91,  90/)  \
               ,   (/104,  66, 133,  93/)  \
               ,   (/139,  80, 166, 116/)  \
               ,   (/134,  28, 155,  69/)  \
               ,   (/ 94,  39, 128,  63/)  \
               ,   (/ 51,  16,  70,  70/)/)
    REG_WINDOW = REG_WINDOW - 1

    REG_IDX    = 3
  
    SSN_NUM    = 4
    ; SSN_NAME = (/"DJF", "MAM", "JJA", "SON"/)
    SSN_NAME   = (/"DJFM", "AMJ", "JAS", "OND"/)

    MOFY     = 12
    ; DOFM   = (/0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365/)
    ; DOFS   = (/0, 90, 182, 274, 365/)
    DOFS     = (/0, 121, 212, 304, 396/)  ; 13 months in all
    DOFS_LBL = (/921201, 930401, 930701, 931001, 931231/) 
    
    DOFY     = 365

    data_y   = new ((/2, 396/), "float")

    ;\ final data result
    ;\ for each region, we have selected 5*5=25 grid points, and 5 corresponding 3*3 small regions
    ;  for average, and the whole region for average.
    obs_ts = new ((/VAR_NUM,               REG_NUM, 25+5+1, DOFY+31/), "float")
    avg_ts = new ((/VAR_NUM, PHY_NUM + 1 , REG_NUM, 25+5+1, DOFY+31/), "float")  ; 5 physics types + all
    sim_ts = new ((/VAR_NUM, SCHM_NUM_ALL, REG_NUM, 25+5+1, DOFY+31/), "float")
    obs_ts = 0.0
    avg_ts = 0.0
    sim_ts = 0.0

    landmask = new ((/NY, NX/), "float")
    landmask = 0

    ; intermediate data result
    var_dly_396     = new ((/DOFY + 31, NY, NX/), "float")
    var_dly_396_tmp = new ((/DOFY + 31, NY, NX/), "float")
    var_dly_365     = new ((/DOFY     , NY, NX/), "float")
    var_dly_396     = 0.0
    var_dly_396_tmp = 0.0
    var_dly_365     = 0.0

    SPV = 1.0e20

    obs_ts@missingvalue = SPV
    obs_ts@_FillValue   = SPV
    avg_ts@missingvalue = SPV
    avg_ts@_FillValue   = SPV
    sim_ts@missingvalue = SPV
    sim_ts@_FillValue   = SPV
 
    var_dly_396@missingvalue     = SPV
    var_dly_396@_FillValue       = SPV
    var_dly_396_tmp@missingvalue = SPV
    var_dly_396_tmp@_FillValue   = SPV
    var_dly_365@missingvalue     = SPV
    var_dly_365@_FillValue       = SPV
   
 
    setfileoption("bin","ReadByteOrder","BigEndian")

    landmask = fbindirread(FILE_LANDMASK, 0, (/NY, NX/), "float")
    
    ; read time series data for obs
    do i_var = 0, 0  ; VAR_NUM - 1
        var_dly_396(31: , :, :) = fbindirread(ROOT_DIR_OBS + "/" + VAR_DIR_OBS(i_var) + "/"  \
            + FILE_OBS_DLY(i_var), 0, (/DOFY, NY, NX/), "float")

        if (i_var .eq. 0) then  ; read 199212 data for PR
            var_dly_396_tmp(0:365, :, :) = fbindirread(ROOT_DIR_OBS + "/" + VAR_DIR_OBS(i_var) + "/"  \
                + FILE_OBS_PR_DLY_1992, 0, (/366, NY, NX/), "float")
            var_dly_396(0:30, :, :) = var_dly_396_tmp(335:365, :, :)
        end if

        var_dly_396 = where(abs(var_dly_396) .gt. 1.0e5, var_dly_396@missingvalue, var_dly_396)

        ; compute daily time series data for each region
        do i_reg = REG_IDX, REG_IDX  ; 0, 0  ; 8 - 1
            xb = REG_WINDOW(i_reg, 0)
            yb = REG_WINDOW(i_reg, 1)
            xe = REG_WINDOW(i_reg, 2)
            ye = REG_WINDOW(i_reg, 3)

            obs_ts(i_var, i_reg,  0, :) = var_dly_396(:, ye - 1, xb + 1)  ; 5*5
            obs_ts(i_var, i_reg,  1, :) = var_dly_396(:, ye - 1, xb + 3)
            obs_ts(i_var, i_reg,  2, :) = var_dly_396(:, ye - 2, xb + 2)
            obs_ts(i_var, i_reg,  3, :) = var_dly_396(:, ye - 3, xb + 1)
            obs_ts(i_var, i_reg,  4, :) = var_dly_396(:, ye - 3, xb + 3)

            obs_ts(i_var, i_reg,  5, :) = var_dly_396(:, ye - 1, xe - 3)
            obs_ts(i_var, i_reg,  6, :) = var_dly_396(:, ye - 1, xe - 1)
            obs_ts(i_var, i_reg,  7, :) = var_dly_396(:, ye - 2, xe - 2)
            obs_ts(i_var, i_reg,  8, :) = var_dly_396(:, ye - 3, xe - 3)
            obs_ts(i_var, i_reg,  9, :) = var_dly_396(:, ye - 3, xe - 1)
            
            obs_ts(i_var, i_reg, 10, :) = var_dly_396(:, (yb+ye)/2 + 1, (xb+xe)/2 - 1)
            obs_ts(i_var, i_reg, 11, :) = var_dly_396(:, (yb+ye)/2 + 1, (xb+xe)/2 + 1)
            obs_ts(i_var, i_reg, 12, :) = var_dly_396(:, (yb+ye)/2    , (xb+xe)/2    )
            obs_ts(i_var, i_reg, 13, :) = var_dly_396(:, (yb+ye)/2 - 1, (xb+xe)/2 - 1)
            obs_ts(i_var, i_reg, 14, :) = var_dly_396(:, (yb+ye)/2 - 1, (xb+xe)/2 + 1)

            obs_ts(i_var, i_reg, 15, :) = var_dly_396(:, yb + 3, xb + 1)
            obs_ts(i_var, i_reg, 16, :) = var_dly_396(:, yb + 3, xb + 3)
            obs_ts(i_var, i_reg, 17, :) = var_dly_396(:, yb + 2, xb + 2)
            obs_ts(i_var, i_reg, 18, :) = var_dly_396(:, yb + 1, xb + 1)
            obs_ts(i_var, i_reg, 19, :) = var_dly_396(:, yb + 1, xb + 3)

            obs_ts(i_var, i_reg, 20, :) = var_dly_396(:, yb + 3, xe - 3)
            obs_ts(i_var, i_reg, 21, :) = var_dly_396(:, yb + 3, xe - 1)
            obs_ts(i_var, i_reg, 22, :) = var_dly_396(:, yb + 2, xe - 2)
            obs_ts(i_var, i_reg, 23, :) = var_dly_396(:, ye - 3, xe - 3)
            obs_ts(i_var, i_reg, 24, :) = var_dly_396(:, yb - 1, xe - 1)       

            obs_ts(i_var, i_reg, 25, :) = dim_avg_n(var_dly_396(:, ye-4:ye, xb:xb+4), (/1, 2/))  ; 5*5
            obs_ts(i_var, i_reg, 26, :) = dim_avg_n(var_dly_396(:, ye-4:ye, xe-4:xe), (/1, 2/))
            obs_ts(i_var, i_reg, 27, :) = dim_avg_n(var_dly_396(:, (yb+ye)/2-2:(yb+ye)/2+2       \
                                        , (xb+xe)/2-2:(xb+xe)/2+2), (/1, 2/))
            obs_ts(i_var, i_reg, 28, :) = dim_avg_n(var_dly_396(:, yb:yb+4, xb:xb+4), (/1, 2/))
            obs_ts(i_var, i_reg, 29, :) = dim_avg_n(var_dly_396(:, yb:yb+4, xe-4:xe), (/1, 2/))

            obs_ts(i_var, i_reg, 30, :) = dim_avg_n(var_dly_396(:, yb:ye, xb:xe), (/1, 2/))
        end do

        ; ; for land region
        ; var_dly_396_tmp = var_dly_396
        ; do i_day = 0, 396 - 1
        ;     var_dly_396_tmp(i_day, :, :) = where(landmask .ne. 16, var_dly_396_tmp(i_day, :, :)  \
        ;         , var_dly_396_tmp@missingvalue)
        ; end do
        ; obs_ts(i_var, 8, 0, :) = dim_avg_n(var_dly_396_tmp(:, 14:123, 14:180), (/1, 2/))

        ; ; for ocean region
        ; var_dly_396_tmp = var_dly_396
        ; do i_day = 0, 396 - 1
        ;     var_dly_396_tmp(i_day, :, :) = where(landmask .eq. 16, var_dly_396_tmp(i_day, :, :)  \
        ;         , var_dly_396_tmp@missingvalue)
        ; end do
        ; obs_ts(i_var, 9, 0, :) = dim_avg_n(var_dly_396_tmp(:, 14:123, 14:180), (/1, 2/))
    end do

    ; read time series data for sim: grid point time series & small region averaged time series
    do i_var = 0, 0  ; 2  ; VAR_NUM - 1 ; PR
        do i_schm = SCHM_NUM_ARR(PHY_IDX) + 1, SCHM_NUM_ARR(PHY_IDX+1) 

            if (i_var .eq. 1 .or. i_var .eq. 2) then  ; RAINC & RAINNC
                nc_file = addfile(ROOT_DIR_SIM + "/" + SCHM_DIR_SIM(i_schm) + "/"  \
                    + SCHM_FN_PREF(i_schm) + "_T2M_T2MIN_T2MAX_RAINC_RAINNC.nc", "r")
                do i_day = 0, 395
                    if (i_var .eq. 1) then
                        var_dly_396(i_day, :, :) = nc_file->RAINC (8*(i_day+1), :, :)   \
                            - nc_file->RAINC (8*i_day, :, :)
                    else
                        var_dly_396(i_day, :, :) = nc_file->RAINNC (8*(i_day+1), :, :)   \
                            - nc_file->RAINC (8*i_day, :, :)                       
                    end if
                end do
            else
                var_dly_396 = fbindirread(ROOT_DIR_SIM + "/" + SCHM_DIR_SIM(i_schm) + "/"   \
                    + SCHM_FN_PREF(i_schm) + "_" + VAR_LIST(i_var) + "_daily.bin", 0i       \
                    , (/DOFY+31, NY, NX/), "float")
            end if

            var_dly_396 = where(abs(var_dly_396) .gt. 1.0e5, var_dly_396@missingvalue, var_dly_396)

            ; compute daily time series data for each region
            do i_reg = REG_IDX, REG_IDX  ; 0, 0  ; 8 - 1
                xb = REG_WINDOW(i_reg, 0)
                yb = REG_WINDOW(i_reg, 1)
                xe = REG_WINDOW(i_reg, 2)
                ye = REG_WINDOW(i_reg, 3)

                sim_ts(i_var, i_schm, i_reg,  0, :) = var_dly_396(:, ye - 1, xb + 1)
                sim_ts(i_var, i_schm, i_reg,  1, :) = var_dly_396(:, ye - 1, xb + 3)
                sim_ts(i_var, i_schm, i_reg,  2, :) = var_dly_396(:, ye - 2, xb + 2)
                sim_ts(i_var, i_schm, i_reg,  3, :) = var_dly_396(:, ye - 3, xb + 1)
                sim_ts(i_var, i_schm, i_reg,  4, :) = var_dly_396(:, ye - 3, xb + 3)

                sim_ts(i_var, i_schm, i_reg,  5, :) = var_dly_396(:, ye - 1, xe - 3)
                sim_ts(i_var, i_schm, i_reg,  6, :) = var_dly_396(:, ye - 1, xe - 1)
                sim_ts(i_var, i_schm, i_reg,  7, :) = var_dly_396(:, ye - 2, xe - 2)
                sim_ts(i_var, i_schm, i_reg,  8, :) = var_dly_396(:, ye - 3, xe - 3)
                sim_ts(i_var, i_schm, i_reg,  9, :) = var_dly_396(:, ye - 3, xe - 1)
                
                sim_ts(i_var, i_schm, i_reg, 10, :) = var_dly_396(:, (yb+ye)/2 + 1, (xb+xe)/2 - 1)
                sim_ts(i_var, i_schm, i_reg, 11, :) = var_dly_396(:, (yb+ye)/2 + 1, (xb+xe)/2 + 1)
                sim_ts(i_var, i_schm, i_reg, 12, :) = var_dly_396(:, (yb+ye)/2    , (xb+xe)/2    )
                sim_ts(i_var, i_schm, i_reg, 13, :) = var_dly_396(:, (yb+ye)/2 - 1, (xb+xe)/2 - 1)
                sim_ts(i_var, i_schm, i_reg, 14, :) = var_dly_396(:, (yb+ye)/2 - 1, (xb+xe)/2 + 1)

                sim_ts(i_var, i_schm, i_reg, 15, :) = var_dly_396(:, yb + 3, xb + 1)
                sim_ts(i_var, i_schm, i_reg, 16, :) = var_dly_396(:, yb + 3, xb + 3)
                sim_ts(i_var, i_schm, i_reg, 17, :) = var_dly_396(:, yb + 2, xb + 2)
                sim_ts(i_var, i_schm, i_reg, 18, :) = var_dly_396(:, yb + 1, xb + 1)
                sim_ts(i_var, i_schm, i_reg, 19, :) = var_dly_396(:, yb + 1, xb + 3)

                sim_ts(i_var, i_schm, i_reg, 20, :) = var_dly_396(:, yb + 3, xe - 3)
                sim_ts(i_var, i_schm, i_reg, 21, :) = var_dly_396(:, yb + 3, xe - 1)
                sim_ts(i_var, i_schm, i_reg, 22, :) = var_dly_396(:, yb + 2, xe - 2)
                sim_ts(i_var, i_schm, i_reg, 23, :) = var_dly_396(:, ye - 3, xe - 3)
                sim_ts(i_var, i_schm, i_reg, 24, :) = var_dly_396(:, yb - 1, xe - 1)

                sim_ts(i_var, i_schm, i_reg, 25, :) = dim_avg_n(var_dly_396(:, ye-4:ye, xb:xb+4), (/1, 2/))  ; for 5*5
                sim_ts(i_var, i_schm, i_reg, 26, :) = dim_avg_n(var_dly_396(:, ye-4:ye, xe-4:xe), (/1, 2/))
                sim_ts(i_var, i_schm, i_reg, 27, :) = dim_avg_n(var_dly_396(:, (yb+ye)/2-2:(yb+ye)/2+2       \
                                                    , (xb+xe)/2-2:(xb+xe)/2+2), (/1, 2/))
                sim_ts(i_var, i_schm, i_reg, 28, :) = dim_avg_n(var_dly_396(:, yb:yb+4, xb:xb+4), (/1, 2/))
                sim_ts(i_var, i_schm, i_reg, 29, :) = dim_avg_n(var_dly_396(:, yb:yb+4, xe-4:xe), (/1, 2/))

                sim_ts(i_var, i_schm, i_reg, 30, :) = dim_avg_n(var_dly_396(:, yb:ye, xb:xe), (/1, 2/))
            end do

            ; ; for land region, only one time series line averaged on the whole land region.
            ; var_dly_396_tmp = var_dly_396
            ; do i_day = 0, DOFY + 31 - 1
            ;     var_dly_396_tmp(i_day, :, :) = where(landmask .ne. 16, var_dly_396_tmp(i_day, :, :),  \
            ;                                    var_dly_396_tmp@missingvalue)
            ; end do
            ; sim_ts(i_var, i_schm, 8, 0, :) = dim_avg_n(var_dly_396_tmp(:, 14:123, 14:180), (/1, 2/))

            ; ; for ocean region
            ; var_dly_396_tmp = var_dly_396
            ; do i_day = 0, DOFY + 31 - 1
            ;     var_dly_396_tmp(i_day, :, :) = where(landmask .eq. 16, var_dly_396_tmp(i_day, :, :),  \
            ;                                    var_dly_396_tmp@missingvalue)
            ; end do
            ; sim_ts(i_var, i_schm, 9, 0, :) = dim_avg_n(var_dly_396_tmp(:, 14:123, 14:180), (/1, 2/))

        end do
    end do

    ; average on physical schemes
    do i_var = 0, 0  ; 2  ; VAR_NUM - 1

        do i_phy = PHY_IDX, PHY_IDX  ; 1, 1  ; 0, PHY_NUM - 1
            do i_reg = REG_IDX, REG_IDX  ; 0, 0  ; 8 - 1
                ; avg_ts(i_var, i_phy, i_reg, 0:30, 0:395) = dim_avg_n(sim_ts(i_var:i_var  \  ! This is ok too
                ;     , SCHM_NUM_ARR(i_phy):SCHM_NUM_ARR(i_phy+1)-1, i_reg:i_reg, 0:30, 0:395), 1)
                avg_ts(i_var, i_phy, i_reg, 0:30, 0:395) = dim_avg_n(sim_ts(i_var   \
                    , SCHM_NUM_ARR(i_phy):SCHM_NUM_ARR(i_phy+1)-1, i_reg, 0:30, 0:395), (/0/))
            end do

            ; ; land region
            ; avg_ts(i_var, i_phy, 8, 0, :) = dim_avg_n(sim_ts(i_var, SCHM_NUM_ARR(i_phy):SCHM_NUM_ARR(i_phy+1)-1  \
            ;     , 8, 0, :), 0)

            ; ; ocean region
            ; avg_ts(i_var, i_phy, 9, 0, :) = dim_avg_n(sim_ts(i_var, SCHM_NUM_ARR(i_phy):SCHM_NUM_ARR(i_phy+1)-1  \
            ;     , 9, 0, :), 0)
        end do

        ; average of all physical schemes
        do i_reg = REG_IDX, REG_IDX  ; 0, 0  ; 8 - 1
            avg_ts(i_var, PHY_NUM, i_reg, :, :) = dim_avg_n(sim_ts(i_var, 0:SCHM_NUM_ALL-1  \
                , i_reg, :, :), 0)
        end do

        ; ; land region
        ; avg_ts(i_var, PHY_NUM, 8, 0, :) = dim_avg_n(sim_ts(i_var, 0:SCHM_NUM_ALL-1  \
        ;     , 8, 0, :), 0) 

        ; ; ocean region
        ; avg_ts(i_var, PHY_NUM, 9, 0, :) = dim_avg_n(sim_ts(i_var, 0:SCHM_NUM_ALL-1  \
        ;     , 9, 0, :), 0)
    end do


    ; DRAWING
 
    wks_pdf_ts    = gsn_open_wks("pdf", "./PR_TS_Midwest_CU")

    plot_pdf_ts   = new (4, graphic)
    
    res          = True
    res@gsnDraw  = False  ; don't draw
    res@gsnFrame = False  ; don't advance frame

    res@vpWidthF = 0.75
    res@vpHeightF = 0.12
    res@vpXF = 0.1
    ; res@vpYF = 0.9
    ; res@gsnPaperMargin = 0.2  ; default: 0.5 in inch

    ; res@trXMinF = 0
    ; res@trXMaxF = CASE_NUM + 2 + 1
    ; res@trYMinF = 0.0
    ; res@trYMaxF = 1.2

    res@tmYROn      = False 
    res@tmXTOn      = False 
    res@tmYLMinorOn = False
    res@tmXBMinorOn = False
    res@tmXBMajorLengthF = 0.005
    res@tmYLMajorLengthF = 0.005
    ; res@tmXBMajorOutwardLengthF = -0.002
    res@tmYLMajorOutwardLengthF = -0.002
    res@tmXBLabelDeltaF = -1.2
    res@tmYLLabelDeltaF = -1.2

    ; res@tmYLAutoPrecision    = False
    ; res@tmYLPrecision        = 2
    ; res@tmYLLabelFontHeightF = 0.01
 
    ; res@tmXTBorderOn = False
    ; res@tmYRBorderOn = False

    res@tmXBMode = "Manual"  ; "Explicit"

    res@xyDashPattern     = (/0, 1/)
    res@xyLineThicknesses = (/2.0, 2.0/)
    res@xyLineColors      = (/"black", "blue"/)
 
    do i_var = 0, 0  ; 2  ; VAR_NUM - 1

        if (i_var .eq. 0) then  ; PR
            ; for 8 regular regions: 25 grid points, 5 small region (5*5) average, 1 whole region average
            do i_reg = REG_IDX, REG_IDX  ; 0, 0  ; 8 - 1 
                do i_ts = 0, 25+5+1-1
                    res@gsnRightString = REG_NAME(i_reg) + ", GP: " + sprinti("%0.2i", i_ts+1)
                    data_y(0, :)       = obs_ts(i_var, i_reg, i_ts, :)

                    ; for each physical scheme
                    do i_schm = SCHM_NUM_ARR(PHY_IDX), SCHM_NUM_ARR(PHY_IDX+1) - 1
                        res@gsnLeftString = SCHM_DESC(i_schm)
                        data_y(1, :)      = sim_ts(i_var, i_schm, i_reg, i_ts, :)
                        
                        ; PR:OBS, for 4 seasons
                        do i_ssn = 0, SSN_NUM - 1
                            res@gsnCenterString  = SSN_NAME(i_ssn) + ": PR vs. OBS"

                            time_x               = ispan(DOFS(i_ssn)+1, DOFS(i_ssn+1), 1)
                            res@tmXBTickStartF   = DOFS(i_ssn)+1
                            res@tmXBTickEndF     = DOFS(i_ssn+1)
                            res@tmXBTickSpacingF = 1

                            res@tmXBLabelsOn     = False
                            ; res@tmXBValues     = (/DOFS(i_ssn)+1, DOFS(i_ssn+1)/)
                            ; res@tmXBLabels     = (/DOFS_LBL(i_ssn), DOFS_LBL(i_ssn+1)/)

                            plot_pdf_ts(i_ssn) = gsn_csm_xy(wks_pdf_ts, time_x  \ 
                                , data_y(:, DOFS(i_ssn):DOFS(i_ssn+1)-1), res)

                            delete(time_x)
                        end do

                        gsn_panel(wks_pdf_ts, plot_pdf_ts, (/4, 1/), False)

                        ; PR - OBS, for 4 seasons
                        do i_ssn = 0, SSN_NUM - 1
                            res@gsnCenterString  = SSN_NAME(i_ssn) + ": PR - OBS"

                            time_x               = ispan(DOFS(i_ssn)+1, DOFS(i_ssn+1), 1)
                            res@tmXBTickStartF   = DOFS(i_ssn)+1
                            res@tmXBTickEndF     = DOFS(i_ssn+1)
                            res@tmXBTickSpacingF = 1

                            res@tmXBLabelsOn     = False
                            ; res@tmXBValues     = (/DOFS(i_ssn)+1, DOFS(i_ssn+1)/)
                            ; res@tmXBLabels     = (/DOFS_LBL(i_ssn), DOFS_LBL(i_ssn+1)/)

                            res@gsnYRefLine      = 0.0

                            plot_pdf_ts(i_ssn) = gsn_csm_xy(wks_pdf_ts, time_x  \ 
                                , data_y(1, DOFS(i_ssn):DOFS(i_ssn+1)-1)        \
                                - data_y(0, DOFS(i_ssn):DOFS(i_ssn+1)-1), res)

                            delete(time_x)
                        end do

                        gsn_panel(wks_pdf_ts, plot_pdf_ts, (/4, 1/), False)

                        ; ; log(PR):log(OBS), for 4 seasons
                        ; do i_ssn = 0, SSN_NUM - 1
                        ;     res@gsnCenterString  = SSN_NAME(i_ssn) + ": log(PR) vs. log(OBS)"

                        ;     time_x               = ispan(DOFS(i_ssn)+1, DOFS(i_ssn+1), 1)
                        ;     res@tmXBTickStartF   = DOFS(i_ssn)+1
                        ;     res@tmXBTickEndF     = DOFS(i_ssn+1)
                        ;     res@tmXBTickSpacingF = 1

                        ;     res@tmXBLabelsOn     = False
                        ;     ; res@tmXBValues     = (/DOFS(i_ssn)+1, DOFS(i_ssn+1)/)
                        ;     ; res@tmXBLabels     = (/DOFS_LBL(i_ssn), DOFS_LBL(i_ssn+1)/)

                        ;     plot_pdf_ts(i_ssn) = gsn_csm_xy(wks_pdf_ts, time_x  \ 
                        ;         , log(data_y(:, DOFS(i_ssn):DOFS(i_ssn+1)-1)), res)

                        ;     delete(time_x)
                        ; end do

                        ; gsn_panel(wks_pdf_ts, plot_pdf_ts, (/4, 1/), False)                       
                    end do
                end do
            end do

            ; ; for land and ocean region, only 1 region averaged time series respectively
            ; do i_reg = 8, 9
            ;     res@gsnRightString = REG_NAME(i_reg)
            ;     data_y(0, :) = obs_ts(i_var, i_reg, 0, :)

            ;     ; for each physical scheme
            ;     do i_schm = 0, SCHM_NUM_ALL - 1
            ;         res@gsnLeftString = SCHM_DESC(i_schm)

            ;         data_y(1, :) = sim_ts(i_var, i_schm, i_reg, 0, :)
            ;         
            ;         ; for 4 seasons
            ;         do i_ssn = 0, SSN_NUM - 1
            ;             res@gsnCenterString = SSN_NAME(i_ssn)
            ;             time_x = ispan(DOFS(i_ssn)+1, DOFS(i_ssn+1), 1)
            ;             res@tmXBValues = (/DOFS(i_ssn)+1, DOFS(i_ssn+1)/)
            ;             res@tmXBLabels = (/DOFS_LBL(i_ssn), DOFS_LBL(i_ssn+1)/)

            ;             plot_pdf_ts(i_ssn) = gsn_csm_xy(wks_pdf_ts, time_x  \  ; (DOFS(i_ssn):DOFS(i_ssn+1)-1)
            ;                 , data_y(:, DOFS(i_ssn):DOFS(i_ssn+1)-1), res)

            ;             delete(time_x)
            ;         end do
            ;         gsn_panel(wks_pdf_ts, plot_pdf_ts, (/4, 1/), False)
            ;     end do
            ; end do

            ; for average on physical process schemes
            do i_reg = REG_IDX, REG_IDX  ; 0, 0  ; 8 - 1
                do i_ts = 0, 25+5+1-1
                    res@gsnRightString = REG_NAME(i_reg) + ", GP: " + sprinti("%0.2i", i_ts+1)
                    data_y(0, :)       = obs_ts(i_var, i_reg, i_ts, :)

                    ; for each type of physical process schemes
                    do i_phy = PHY_IDX, PHY_IDX  ; 1, 1  ; 0, PHY_NUM
                        res@gsnLeftString = PHY_DESC(i_phy)
                        data_y(1, :)      = avg_ts(i_var, i_phy, i_reg, i_ts, :)
                        
                        ; for 4 seasons
                        do i_ssn = 0, SSN_NUM - 1
                            res@gsnCenterString  = SSN_NAME(i_ssn)

                            time_x               = ispan(DOFS(i_ssn)+1, DOFS(i_ssn+1), 1)
                            res@tmXBTickStartF   = DOFS(i_ssn)+1
                            res@tmXBTickEndF     = DOFS(i_ssn+1)
                            res@tmXBTickSpacingF = 1

                            res@tmXBLabelsOn = False
                            ; res@tmXBValues = (/DOFS(i_ssn)+1, DOFS(i_ssn+1)/)
                            ; res@tmXBLabels = (/DOFS_LBL(i_ssn), DOFS_LBL(i_ssn+1)/)

                            plot_pdf_ts(i_ssn) = gsn_csm_xy(wks_pdf_ts, time_x  \ 
                                , data_y(:, DOFS(i_ssn):DOFS(i_ssn+1)-1), res)

                            delete(time_x)
                        end do

                        gsn_panel(wks_pdf_ts, plot_pdf_ts, (/4, 1/), False)

                        ; for 4 seasons, PR - OBS
                        do i_ssn = 0, SSN_NUM - 1
                            res@gsnCenterString  = SSN_NAME(i_ssn)

                            time_x               = ispan(DOFS(i_ssn)+1, DOFS(i_ssn+1), 1)
                            res@tmXBTickStartF   = DOFS(i_ssn)+1
                            res@tmXBTickEndF     = DOFS(i_ssn+1)
                            res@tmXBTickSpacingF = 1

                            res@tmXBLabelsOn = False
                            ; res@tmXBValues = (/DOFS(i_ssn)+1, DOFS(i_ssn+1)/)
                            ; res@tmXBLabels = (/DOFS_LBL(i_ssn), DOFS_LBL(i_ssn+1)/)

                            res@gsnYRefLine  = 0.0

                            plot_pdf_ts(i_ssn) = gsn_csm_xy(wks_pdf_ts, time_x  \ 
                                , data_y(1, DOFS(i_ssn):DOFS(i_ssn+1)-1)        \
                                - data_y(0, DOFS(i_ssn):DOFS(i_ssn+1)-1), res)

                            delete(time_x)
                        end do

                        gsn_panel(wks_pdf_ts, plot_pdf_ts, (/4, 1/), False)
                    end do
                end do
            end do

            ; for land and ocean region, only 1 region averaged time series
            ; do i_reg = 8, 9
            ;     res@gsnRightString = REG_NAME(i_reg)
            ;     data_y(0, :) = obs_ts(i_var, i_reg, 0, :)

            ;     ; for each type of physical process schemes
            ;     do i_phy = 0, PHY_NUM
            ;         res@gsnLeftString = PHY_DESC(i_phy)

            ;         data_y(1, :) = avg_ts(i_var, i_phy, i_reg, 0, :)
            ;         
            ;         ; for 4 seasons
            ;         do i_ssn = 0, SSN_NUM - 1
            ;             res@gsnCenterString = SSN_NAME(i_ssn)
            ;             time_x = ispan(DOFS(i_ssn)+1, DOFS(i_ssn+1), 1)
            ;             res@tmXBValues = (/DOFS(i_ssn)+1, DOFS(i_ssn+1)/)
            ;             res@tmXBLabels = (/DOFS_LBL(i_ssn), DOFS_LBL(i_ssn+1)/)

            ;             plot_pdf_ts(i_ssn) = gsn_csm_xy(wks_pdf_ts, time_x  \  ; (DOFS(i_ssn):DOFS(i_ssn+1)-1)  \
            ;                 , data_y(:, DOFS(i_ssn):DOFS(i_ssn+1)-1), res)

            ;             delete(time_x)
            ;         end do
            ;         gsn_panel(wks_pdf_ts, plot_pdf_ts, (/4, 1/), False)
            ;     end do
            ; end do
        else  ; RAINC & RAINNC
            ; for 8 regular regions: 25 grid points, 5 small region (5*5) average, 1 whole region average
            do i_reg = REG_IDX, REG_IDX  ; 0, 0  ; 8 - 1 
                do i_ts = 0, 25+5+1-1
                    res@gsnRightString = REG_NAME(i_reg) + ", GP: " + sprinti("%0.2i", i_ts+1)
                    data_y(0, :)       = obs_ts(i_var, i_reg, i_ts, :)

                    ; for each physical scheme
                    do i_schm = SCHM_NUM_ARR(PHY_IDX), SCHM_NUM_ARR(PHY_IDX+1) - 1
                        res@gsnLeftString = SCHM_DESC(i_schm)
                        data_y(1, :)      = sim_ts(i_var, i_schm, i_reg, i_ts, :)
                        
                        ; RAINC or RAINNC:OBS, for 4 seasons
                        do i_ssn = 0, SSN_NUM - 1
                            res@gsnCenterString  = SSN_NAME(i_ssn) + ": PR vs. OBS"

                            time_x               = ispan(DOFS(i_ssn)+1, DOFS(i_ssn+1), 1)
                            res@tmXBTickStartF   = DOFS(i_ssn)+1
                            res@tmXBTickEndF     = DOFS(i_ssn+1)
                            res@tmXBTickSpacingF = 1

                            res@tmXBLabelsOn     = False
                            ; res@tmXBValues     = (/DOFS(i_ssn)+1, DOFS(i_ssn+1)/)
                            ; res@tmXBLabels     = (/DOFS_LBL(i_ssn), DOFS_LBL(i_ssn+1)/)

                            plot_pdf_ts(i_ssn) = gsn_csm_xy(wks_pdf_ts, time_x  \ 
                                , data_y(:, DOFS(i_ssn):DOFS(i_ssn+1)-1), res)

                            delete(time_x)
                        end do

                        gsn_panel(wks_pdf_ts, plot_pdf_ts, (/4, 1/), False)

                        ; ; log(PR):log(OBS), for 4 seasons
                        ; do i_ssn = 0, SSN_NUM - 1
                        ;     res@gsnCenterString  = SSN_NAME(i_ssn) + ": log(PR) vs. log(OBS)"

                        ;     time_x               = ispan(DOFS(i_ssn)+1, DOFS(i_ssn+1), 1)
                        ;     res@tmXBTickStartF   = DOFS(i_ssn)+1
                        ;     res@tmXBTickEndF     = DOFS(i_ssn+1)
                        ;     res@tmXBTickSpacingF = 1

                        ;     res@tmXBLabelsOn     = False
                        ;     ; res@tmXBValues     = (/DOFS(i_ssn)+1, DOFS(i_ssn+1)/)
                        ;     ; res@tmXBLabels     = (/DOFS_LBL(i_ssn), DOFS_LBL(i_ssn+1)/)

                        ;     plot_pdf_ts(i_ssn) = gsn_csm_xy(wks_pdf_ts, time_x  \ 
                        ;         , log(data_y(:, DOFS(i_ssn):DOFS(i_ssn+1)-1)), res)

                        ;     delete(time_x)
                        ; end do

                        ; gsn_panel(wks_pdf_ts, plot_pdf_ts, (/4, 1/), False)                       
                    end do
                end do
            end do

            ; ; for land and ocean region, only 1 region averaged time series respectively
            ; do i_reg = 8, 9
            ;     res@gsnRightString = REG_NAME(i_reg)
            ;     data_y(0, :) = obs_ts(i_var, i_reg, 0, :)

            ;     ; for each physical scheme
            ;     do i_schm = 0, SCHM_NUM_ALL - 1
            ;         res@gsnLeftString = SCHM_DESC(i_schm)

            ;         data_y(1, :) = sim_ts(i_var, i_schm, i_reg, 0, :)
            ;         
            ;         ; for 4 seasons
            ;         do i_ssn = 0, SSN_NUM - 1
            ;             res@gsnCenterString = SSN_NAME(i_ssn)
            ;             time_x = ispan(DOFS(i_ssn)+1, DOFS(i_ssn+1), 1)
            ;             res@tmXBValues = (/DOFS(i_ssn)+1, DOFS(i_ssn+1)/)
            ;             res@tmXBLabels = (/DOFS_LBL(i_ssn), DOFS_LBL(i_ssn+1)/)

            ;             plot_pdf_ts(i_ssn) = gsn_csm_xy(wks_pdf_ts, time_x  \  ; (DOFS(i_ssn):DOFS(i_ssn+1)-1)
            ;                 , data_y(:, DOFS(i_ssn):DOFS(i_ssn+1)-1), res)

            ;             delete(time_x)
            ;         end do
            ;         gsn_panel(wks_pdf_ts, plot_pdf_ts, (/4, 1/), False)
            ;     end do
            ; end do

            ; for average on physical process schemes
            do i_reg = REG_IDX, REG_IDX  ; 0, 0  ; 8 - 1
                do i_ts = 0, 25+5+1-1
                    res@gsnRightString = REG_NAME(i_reg) + ", GP: " + sprinti("%0.2i", i_ts+1)
                    data_y(0, :)       = obs_ts(i_var, i_reg, i_ts, :)

                    ; for each type of physical process schemes
                    do i_phy = PHY_IDX, PHY_IDX  ; 1, 1  ; 0, PHY_NUM
                        res@gsnLeftString = PHY_DESC(i_phy)
                        data_y(1, :)      = avg_ts(i_var, i_phy, i_reg, i_ts, :)
                        
                        ; for 4 seasons
                        do i_ssn = 0, SSN_NUM - 1
                            res@gsnCenterString  = SSN_NAME(i_ssn)

                            time_x               = ispan(DOFS(i_ssn)+1, DOFS(i_ssn+1), 1)
                            res@tmXBTickStartF   = DOFS(i_ssn)+1
                            res@tmXBTickEndF     = DOFS(i_ssn+1)
                            res@tmXBTickSpacingF = 1

                            res@tmXBLabelsOn = False
                            ; res@tmXBValues = (/DOFS(i_ssn)+1, DOFS(i_ssn+1)/)
                            ; res@tmXBLabels = (/DOFS_LBL(i_ssn), DOFS_LBL(i_ssn+1)/)

                            plot_pdf_ts(i_ssn) = gsn_csm_xy(wks_pdf_ts, time_x  \ 
                                , data_y(:, DOFS(i_ssn):DOFS(i_ssn+1)-1), res)

                            delete(time_x)
                        end do

                        gsn_panel(wks_pdf_ts, plot_pdf_ts, (/4, 1/), False)

                    end do
                end do
            end do

            ; for land and ocean region, only 1 region averaged time series
            ; do i_reg = 8, 9
            ;     res@gsnRightString = REG_NAME(i_reg)
            ;     data_y(0, :) = obs_ts(i_var, i_reg, 0, :)

            ;     ; for each type of physical process schemes
            ;     do i_phy = 0, PHY_NUM
            ;         res@gsnLeftString = PHY_DESC(i_phy)

            ;         data_y(1, :) = avg_ts(i_var, i_phy, i_reg, 0, :)
            ;         
            ;         ; for 4 seasons
            ;         do i_ssn = 0, SSN_NUM - 1
            ;             res@gsnCenterString = SSN_NAME(i_ssn)
            ;             time_x = ispan(DOFS(i_ssn)+1, DOFS(i_ssn+1), 1)
            ;             res@tmXBValues = (/DOFS(i_ssn)+1, DOFS(i_ssn+1)/)
            ;             res@tmXBLabels = (/DOFS_LBL(i_ssn), DOFS_LBL(i_ssn+1)/)

            ;             plot_pdf_ts(i_ssn) = gsn_csm_xy(wks_pdf_ts, time_x  \  ; (DOFS(i_ssn):DOFS(i_ssn+1)-1)  \
            ;                 , data_y(:, DOFS(i_ssn):DOFS(i_ssn+1)-1), res)

            ;             delete(time_x)
            ;         end do
            ;         gsn_panel(wks_pdf_ts, plot_pdf_ts, (/4, 1/), False)
            ;     end do
            ; end do           
        end if  ; end of "if (i_var .eq. 0) then", PR
        
    end do
end
