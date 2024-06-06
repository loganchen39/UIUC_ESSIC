load "/global/u2/t/tjling/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "/global/u2/t/tjling/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "/global/u2/t/tjling/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
    setfileoption("bin", "ReadByteOrder" , "BigEndian")
    setfileoption("bin", "WriteByteOrder", "BigEndian")

    DIR_ROOT       = "/global/scratch/sd/lgchen/data/NR2_NEW/flx/tmp"
    FN_NR2_LON_LAT = DIR_ROOT + "/flx.ft06.2011040100.nc"

    FN_LON_CWRF = "/global/u1/l/lgchen/data/lat_lon_195-138_xing/lon"
    FN_LAT_CWRF = "/global/u1/l/lgchen/data/lat_lon_195-138_xing/lat"
    FN_LCC      = "/global/u1/l/lgchen/data/lcc_xing/lcc"

    NX  = 195
    NY  = 138
    NXY = NX * NY

    N_LON_NR2 = 192
    N_LAT_NR2 = 94

    lev = 2

    lon_cwrf      = new ((/NY, NX/), "float", 1.0e20)
    lat_cwrf      = new ((/NY, NX/), "float", 1.0e20)
    lon_cwrf_1dim = new ((/NXY/), "float", 1.0e20)
    lat_cwrf_1dim = new ((/NXY/), "float", 1.0e20)

    lon_NR2 = new((/N_LON_NR2/), "float", 1.0e20)
    lat_NR2 = new((/N_LAT_NR2/), "float", 1.0e20)

    lcc     = new ((/NY, NX/), "float", 1.0e20)

    ; f_lon_tmp = new((/N_LON_CFS/), "float")

    lon_cwrf = fbindirread(FN_LON_CWRF, 0, (/NY, NX/), "float")
    lon_cwrf = where(lon_cwrf .lt. 0.0, lon_cwrf + 360.0, lon_cwrf)
    lat_cwrf = fbindirread(FN_LAT_CWRF, 0, (/NY, NX/), "float")

    lon_cwrf_1dim = ndtooned(lon_cwrf)  ; NY * NX
    lat_cwrf_1dim = ndtooned(lat_cwrf)

    lcc = fbindirread(FN_LCC, 0, (/NY, NX/), "float")

    fl_nr2_lon_lat = addfile(FN_NR2_LON_LAT, "r")
    lon_nr2        = fl_nr2_lon_lat->lon_98  ; 192: 0        ~ 358.125
    lat_nr2        = fl_nr2_lon_lat->lat_98  ; 94 : 88.54195 ~ -88.54195
    ; reverse lat_nr2 to make it strictly monotonically increasing
    do i_lat_nr2 = 0, 46  ; floattoint((dimsizes(lat_nr2) - 1)/2.0)
        f_tmp                    = lat_nr2(i_lat_nr2)
        lat_nr2(i_lat_nr2)       = lat_nr2(93 - i_lat_nr2)
        lat_nr2(93 - i_lat_nr2) = f_tmp
    end do
    ; print("reversed lat_nr2: " + lat_nr2)  ; correct
   
    nl = integertochar(10)  ; newline character

 
    str_cmd = "cd " + DIR_ROOT + "; ls flx.ft06.*.nc"
    fn_nc_all = systemfunc(str_cmd)
    print("netCDF file names: " + fn_nc_all)

    do i_fl = 0, dimsizes(fn_nc_all) - 1  ; 0
        fn_nc_nr2      = str_strip(fn_nc_all(i_fl))
        fn_nc_nr22cwrf = str_strip(fn_nc_all(i_fl))
        fn_nc_nr22cwrf = str_sub_str(fn_nc_nr22cwrf, ".nc", ".nr22cwrf.nc")
        
        fl_nr2 = addfile(DIR_ROOT + "/" + fn_nc_nr2, "r")
        sm_nr2 = fl_nr2->SOILW_98_DBLY_10  ; (lv_DBLY2, lat_98, lon_98)

        print("before do i_fcst = 0, forecast_time0 - 1: " + systemfunc("date"))
        ; reverse the sm_nr2 to make lat_nr2 strictly monotonically increasing
        ; the run time for this do loop increases unacceptably for every new file!!!
        do i_lat_nr2 = 0, 46
            f_lon_tmp                     = sm_nr2(:, i_lat_nr2     , :)
            sm_nr2(:, i_lat_nr2      , :) = sm_nr2(:, 93 - i_lat_nr2, :)
            sm_nr2(:, 93 - i_lat_nr2, :)  = f_lon_tmp
        end do

        print("before linint2: " + systemfunc("date"))

        sm_cwrf_tmp = linint2_points(lon_nr2, lat_nr2, sm_nr2, False, lon_cwrf_1dim, lat_cwrf_1dim, 0)
        sm_cwrf     = onedtond(ndtooned(sm_cwrf_tmp), (/2, NY, NX/))
        printVarSummary(sm_cwrf_tmp)
        printVarSummary(sm_cwrf    )
        sm_cwrf(0, :, :) = sm_cwrf(0, :, :) * 100  ; fraction to kg/m^2
        sm_cwrf(1, :, :) = sm_cwrf(1, :, :) * 1900
        sm_cwrf(0, :, :) = where(lcc .eq. 16, 1e20, sm_cwrf(0, :, :))
        sm_cwrf(1, :, :) = where(lcc .eq. 16, 1e20, sm_cwrf(1, :, :))
       
    
        ; define and write the interpolated results to the new file 
        fl_cwrf   = addfile(DIR_ROOT + "/" + fn_nc_nr22cwrf, "c")

        ; define file (global) attributes
        global_att             = True
        global_att@description = "source: nr2 , " + nl             \
            + "SM/NR2 units: fraction"            + nl             \
            + "target: CWRF 195*138 Lambert Conformal grid." + nl  \
            + "SM/CWRF units: kg/m^2 ~ mm"

        fileattdef(fl_cwrf, global_att)

        ; define file dimensions
        dim_names = (/"lev", "south_north", "west_east"/)
        dim_sizes = (/lev  , NY           , NX         /)
        dim_unlim = (/False, False        , False      /)
        filedimdef(fl_cwrf, dim_names, dim_sizes, dim_unlim)

        ; define file variables with their dimensions and attributes
        filevardef(fl_cwrf, "SM", "float", (/"lev", "south_north", "west_east"/))
        
        sm_att = True  ; 0
        sm_att@description   = "NR22CWRF SM, 0~0.1m, 0.1~2m"
        sm_att@units         = "kg/m^2"
        ; sm_att@_FillValue    = 1e20
        ; sm_att@missing_value = 1e20

        filevarattdef(fl_cwrf, "SM", sm_att)

        fl_cwrf->SM = sm_cwrf

        print("after fl_cwrf->SM = sm_cwrf: " + systemfunc("date"))
        print("*****************************")
        
        delete(sm_nr2     )
        delete(sm_cwrf_tmp)
        delete(sm_cwrf    )
        delete(f_lon_tmp )
    end do  ; end of "do i_fl = 0, dimsizes(fn_nc_all) - 1"
    
    delete(fn_nc_all)
end
