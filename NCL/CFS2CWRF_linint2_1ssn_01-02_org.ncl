; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

load "/global/u2/t/tjling/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "/global/u2/t/tjling/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "/global/u2/t/tjling/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
    START_YEAR  = 2001
    START_MONTH = 1
    END_YEAR    = 2002
    END_MONTH   = 12

    DIR_ROOT       = "/global/scratch/sd/lgchen/data/cfsr-rfl-ts45_prate/data"
    FN_CFS_LON_LAT = "/global/scratch/sd/lgchen/data/cfsr-rfl-ts45_prate/data/199901/prate_f.01.1999010100.1999050100.1999010100.nc"

    FN_LON_CWRF = "/global/u1/l/lgchen/data/lat_lon_195-138_xing/lon"
    FN_LAT_CWRF = "/global/u1/l/lgchen/data/lat_lon_195-138_xing/lat"

    NX  = 195
    NY  = 138
    NXY = NX * NY

    N_LON_CFS = 384
    N_LAT_CFS = 190

    lon_cwrf      = new ((/NY, NX/), "float", 1.0e20)
    lat_cwrf      = new ((/NY, NX/), "float", 1.0e20)
    lon_cwrf_1dim = new ((/NXY/), "float", 1.0e20)
    lat_cwrf_1dim = new ((/NXY/), "float", 1.0e20)

    lon_cfs = new((/N_LON_CFS/), "float", 1.0e20)
    lat_cfs = new((/N_LAT_CFS/), "float", 1.0e20)

    ; f_lon_tmp = new((/N_LON_CFS/), "float")

    setfileoption("bin", "ReadByteOrder" , "BigEndian")
    setfileoption("bin", "WriteByteOrder", "BigEndian")

    lon_cwrf = fbindirread(FN_LON_CWRF, 0, (/NY, NX/), "float")
    lon_cwrf = where(lon_cwrf .lt. 0.0, lon_cwrf + 360.0, lon_cwrf)
    lat_cwrf = fbindirread(FN_LAT_CWRF, 0, (/NY, NX/), "float")

    lon_cwrf_1dim = ndtooned(lon_cwrf)  ; NY * NX
    lat_cwrf_1dim = ndtooned(lat_cwrf)

    fl_cfs_lon_lat = addfile(FN_CFS_LON_LAT, "r")
    lon_cfs        = fl_cfs_lon_lat->lon_0  ; 384: 0        ~ 359.062
    lat_cfs        = fl_cfs_lon_lat->lat_0  ; 190: 89.27671 ~ -89.27671
    ; reverse lat_cfs to make it strictly monotonically increasing
    do i_lat_cfs = 0, 94  ; floattoint((dimsizes(lat_cfs) - 1)/2.0)
        f_tmp                    = lat_cfs(i_lat_cfs)
        lat_cfs(i_lat_cfs)       = lat_cfs(189 - i_lat_cfs)
        lat_cfs(189 - i_lat_cfs) = f_tmp
    end do
    ; print("reversed lat_cfs: " + lat_cfs)  ; correct
   
    nl = integertochar(10)  ; newline character
   
 
    ; main loop
    do i_yr = START_YEAR, END_YEAR
        if (i_yr .eq. START_YEAR) then
            start_month_curr = START_MONTH
        else
            start_month_curr = 1
        end if

        if (i_yr .eq. END_YEAR) then
            end_month_curr = END_MONTH
        else
            end_month_curr = 12
        end if

        do i_mon = start_month_curr, end_month_curr
            if (i_mon .eq. 5 .or. i_mon .eq. 6 .or. i_mon .eq. 7 .or. i_mon .eq. 11) then  ; missed
                continue
            end if

            dir_data = sprinti("%0.4i", i_yr) + sprinti("%0.2i", i_mon)
            str_cd_ls_cmd = "cd " + DIR_ROOT + "/" + dir_data + "; ls prate_f.01.*00.nc"
            fn_nc_all = systemfunc(str_cd_ls_cmd)
            print("netCDF file names: " + fn_nc_all)

            do i_fl = 0, dimsizes(fn_nc_all) - 1  ; 0
                fn_nc_cfs      = str_strip(fn_nc_all(i_fl))
                fn_nc_cfs2cwrf = str_strip(fn_nc_all(i_fl))
                fn_nc_cfs2cwrf = str_sub_str(fn_nc_cfs2cwrf, ".nc", ".cfs2cwrf.nc")
                
                fl_cfs = addfile(DIR_ROOT + "/" + dir_data + "/" + fn_nc_cfs, "r")
                ; get dimension value of forecast_time0, e.g. 480
                dimsize_fl_cfs = getfiledimsizes(fl_cfs)
                dimname_fl_cfs = getvardims     (fl_cfs)
                forecast_time0 = dimsize_fl_cfs(0)
                print("forecast_time0=" + forecast_time0 + ", i_yr=" + i_yr + ", i_fl=" + i_fl)
                if (dimname_fl_cfs(0) .ne. "forecast_time0") then
                    print("ERROR: dimname_fl_cfs(0) .ne. forecast_time0, i_yr=" + i_yr + "i_fl=" + i_fl)
                    exit
                end if

                prate_cfs = fl_cfs->PRATE_P0_L1_GGA0

                print("before do i_fcst = 0, forecast_time0 - 1: " + systemfunc("date"))
                ; reverse the prate_cfs to make lat_cfs strictly monotonically increasing
                ; the run time for this do loop increases unacceptably for every new file!!!
                do i_lat_cfs = 0, 94
                    f_lon_tmp                        = prate_cfs(:, i_lat_cfs      , :)
                    prate_cfs(:, i_lat_cfs      , :) = prate_cfs(:, 189 - i_lat_cfs, :)
                    prate_cfs(:, 189 - i_lat_cfs, :) = f_lon_tmp
                end do

                print("before linint2: " + systemfunc("date"))

                prate_cwrf = linint2_points(lon_cfs, lat_cfs, prate_cfs, False, lon_cwrf_1dim, lat_cwrf_1dim, 0)
                pr_cwrf    = onedtond(ndtooned(prate_cwrf), (/forecast_time0, NY, NX/))
                pr_cwrf    = pr_cwrf * 6 * 60 * 60  ; mm/6-hourly
               
            
                ; define and write the interpolated results to the new file 
                fl_cwrf   = addfile(DIR_ROOT + "/" + dir_data + "/" + fn_nc_cfs2cwrf, "c")

                ; define file (global) attributes
                global_att             = True
                global_att@description = "source: CFSv2 one season reforecast, " + nl +  \
                    "e.g. 1993050100, 1993050200, ..., 1993053100 -> 1993090100" + nl +  \
                    "prate units: kg m-2 s-1 ~ mm/s"                             + nl +  \
                    "target: CWRF 195*138 Lambert Conformal grid."               + nl +  \
                    "PR units: mm (mm/6-hourly)"

                fileattdef(fl_cwrf, global_att)

                ; define file dimensions
                dim_names = (/"forecast_time0", "south_north", "west_east"/)
                dim_sizes = (/forecast_time0  , NY           , NX         /)
                dim_unlim = (/True            , False        , False      /)
                filedimdef(fl_cwrf, dim_names, dim_sizes, dim_unlim)

                ; define file variables with their dimensions and attributes
                filevardef(fl_cwrf, "PR", "float", (/"forecast_time0", "south_north", "west_east"/))
                
                pr_att = True  ; 0
                pr_att@description   = "6-hourly accumulated total precipitation"
                pr_att@units         = "mm"
                ; pr_att@_FillValue    = 1.0e20
                ; pr_att@missing_value = 1.0e20

                filevarattdef(fl_cwrf, "PR", pr_att)

                fl_cwrf->PR = pr_cwrf

                print("after fl_cwrf->PR = pr_cwrf: " + systemfunc("date"))
                print("*****************************")
                
                delete(prate_cfs )
                delete(prate_cwrf)
                delete(pr_cwrf   )
                delete(f_lon_tmp )
            end do
           
            delete(fn_nc_all)
        end do  ; end of "do i_mon = start_month_curr, end_month_curr"
    end do  ; end of "do i_yr = START_YEAR, END_YEAR"

end
