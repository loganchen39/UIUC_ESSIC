#!/bin/tcsh

unalias cp
cd /scratch2/scratchdirs/lgchen/projects/CWRFV3/cwrf_run/cumulus_test/1993

set CU_NUM   = 5
set dir      = (run_cu6_sas run_cu8_randall run_cu9_gfdl run_cu10_mit run_cu99_pkf)
                 
set cu_index = (6 8 9 10 99)  # no cu0-nocu, cu3-g3d, cu7-zml

set yr      = 1992
set mon     = 12
set end_yr  = 1993
set end_mon = 1
set fn_nml  = namelist.input.1992120100

set i = 1
while ($i <= $CU_NUM)
    mkdir $dir[$i]
    cd $dir[$i]

    ln -sf ~/global_cwrf/exe/*          .
    rm ndown.exe.r* nup.exe.r* real.exe.r* tc.exe.r* 
    rm wrf.exe.r*
    # if (2 == $cu_index[$i]) then
    #     ln -sf ~/global_cwrf/exe/wrf.exe.r151.PGI    wrf.exe
    # else 
        ln -sf ~/global_cwrf/exe/wrf.exe.r151.GNU    wrf.exe
    # endif

    ln -sf /project/projectdirs/cwrf/cwrf/constant_files/* .
    ln -sf MISR_climatology.nc aerosol.nc

    cp ~/global_cwrf/ctrl_30yr/namelist.input  namelist.input 
    sed -i -e '/^ restart /s/.false./.true./; /cu_physics/s/= 3/= '$cu_index[$i]'/' namelist.input
    if (8 == $cu_index[$i]) then 
        sed -i -e '/cudt/s/= 0./= 10./' namelist.input
    endif

    @ yr  = 1992
    @ mon = 12
    while ($yr <= 1993)
        if (1992 != $yr) then
            @ mon = 1
        endif

        while ($mon <= 12)
            if ($mon <= 9) then
                set fn_nml = namelist.input.${yr}0${mon}0100
            else
                set fn_nml = namelist.input.${yr}${mon}0100
            endif
            cp namelist.input $fn_nml

            if (12 == $mon) then
                @ end_yr  = $yr + 1
                @ end_mon = 1
            else
                @ end_yr  = $yr
                @ end_mon = $mon + 1
            endif

            sed -i -e '/start_year/s/= 1992/= '${yr}'/; /start_month/s/= 01/= '${mon}'/;  \
                /end_year/s/= 1992/= '${end_yr}'/; /end_month/s/= 02/= '${end_mon}'/'  $fn_nml
 
            @ mon ++
        end        

        @ yr ++
    end 

    sed -i -e '/^ restart /s/.true./.false./' namelist.input.1992120100

    cd ..

    @ i++
end  
