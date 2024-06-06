; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
 
load "/global/u2/t/tjling/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "/global/u2/t/tjling/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "/global/u2/t/tjling/lib/ncarg/nclscripts/csm/contributed.ncl"

load "/global/u1/l/lgchen/lib/NCL/self_defined.ncl"


begin
    ; directories & files
    DIR_DATA_IN  = "/global/scratch/sd/lgchen/data/ECHAM2CWRF/AMIP10"
    DIR_DATA_OUT = "/global/scratch/sd/lgchen/data/ECHAM2CWRF/AMIP10/tmp_out"

    FN_LCC         = "/global/u1/l/lgchen/data/lcc_xing/lcc"
    FN_US_LANDMASK = "/global/u1/l/lgchen/data/USLandmask/US.landmask.zjh"

    PLOT = False


    ; data structure
    NX = 195
    NY = 138

    var = new ((/NY, NX/), "float", 1.0e20)

    lcc         = new ((/NY, NX/), "float")
    us_landmask = new ((/NY, NX/), "float")

    START_YEAR = 1979
    END_YEAR   = 2009

    VAR_NM = (/"PR", "T2MAX", "T2MIN"/)


    ; execution
    setfileoption("bin", "ReadByteOrder" , "BigEndian")
    setfileoption("bin", "WriteByteOrder", "BigEndian")

    lcc         = fbindirread(FN_LCC        , 0, (/NY, NX/), "float")
    us_landmask = fbindirread(FN_US_LANDMASK, 0, (/NY, NX/), "float")


    do i_var = 0, dimsizes(VAR_NM) - 1
        fn_in = "19790102_20091230_" + VAR_NM(i_var) + "_daily.bin"

        do i_yr = START_YEAR, END_YEAR
            fn_out = sprinti("%0.4i", i_yr) + "_JJA_" + VAR_NM(i_var) + "_daily.bin"
            if (isfilepresent(DIR_DATA_OUT + "/" + fn_out)) then
                system("rm -f " + DIR_DATA_OUT + "/" + fn_out)
                print("WARNING: file exist: " + fn_out) 
            end if

            start_rec = get_record_index(1979, 1, 2, i_yr, 6, 1 )
            end_rec   = get_record_index(1979, 1, 2, i_yr, 8, 31)
            do i_rec = start_rec, end_rec
                var = fbindirread(DIR_DATA_IN + "/" + fn_in, i_rec, (/NY, NX/), "float")
                fbindirwrite(DIR_DATA_OUT + "/" + fn_out, var)
            end do
        end do
    end do
end
