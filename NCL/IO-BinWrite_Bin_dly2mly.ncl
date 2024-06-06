load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
    DATA_SIM_DIR = "/scratch2/scratchdirs/lgchen/projects/CWRFV3/cwrf_run/ccsm_test_v0.5_h2p-ncl_ctl-mp8/ctl_test1"

    NVAR   = 4
    VAR_NM = (/"T2M", "PR", "U", "V"/) 

    NDAY   = 28
    NX = 195
    NY = 138
    
    data_mly = new ((/NVAR+2, NY, NX /), "float")  ; T2M, PR, U200, U850, V200, V850
    data_mly = 0.

    data_tmp = new ((/NDAY, NY, NX/), "float")
    data_tmp = 0.

    SPV = 1.0e20

    data_mly@missingvalue = SPV
    data_mly@_FillValue   = SPV
    data_tmp@missingvalue = SPV
    data_tmp@_FillValue   = SPV


    setfileoption("bin","ReadByteOrder","BigEndian")  ; built-in function

    ; read
    do i_var = 0, 1
        data_tmp = fbindirread(DATA_SIM_DIR + "/ccsm_h2p-ncl_mp8_" + VAR_NM(i_var)  \
            + "_daily.bin", 0, (/NDAY, NY, NX/), "float")
        data_mly(i_var, :, :) = dim_avg_n(data_tmp, 0)
    end do

    i_tmp = 2
    do i_var = 2, 3
        do i_day = 0, NDAY - 1
            data_tmp(i_day, :, :) = fbindirread(DATA_SIM_DIR + "/ccsm_h2p-ncl_mp8_" + VAR_NM(i_var)  \
                + "_daily.bin", 2*i_day, (/NY, NX/), "float")
        end do
        data_mly(i_tmp, :, :) = dim_avg_n(data_tmp, 0)
        i_tmp = i_tmp + 1

        do i_day = 0, NDAY - 1
            data_tmp(i_day, :, :) = fbindirread(DATA_SIM_DIR + "/ccsm_h2p-ncl_mp8_" + VAR_NM(i_var)  \
                + "_daily.bin", 2*i_day+1, (/NY, NX/), "float")
        end do
        data_mly(i_tmp, :, :) = dim_avg_n(data_tmp, 0)
        i_tmp = i_tmp + 1       
    end do

    ; write
    do i_var = 0, 1
        fbindirwrite(DATA_SIM_DIR + "/ccsm_h2p-ncl_mp8_" + VAR_NM(i_var)  \
            + "_monthly_new.bin", data_mly(i_var, :, :))
    end do

    fbindirwrite(DATA_SIM_DIR + "/ccsm_h2p-ncl_mp8_U_monthly_new.bin", data_mly(2:3, :, :))
    fbindirwrite(DATA_SIM_DIR + "/ccsm_h2p-ncl_mp8_V_monthly_new.bin", data_mly(4:5, :, :))
end
