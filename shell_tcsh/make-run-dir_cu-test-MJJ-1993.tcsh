#!/bin/tcsh

unalias cp
cd /scratch/scratchdirs/lgchen/projects/CWRFV3/cwrf_run/cumulus_test/1993

set CU_NUM   = 11
set dir      = (run_cu0_nocu run_cu1_kf run_cu2_bmj run_cu3_g3d run_cu4_gd       \
                run_cu5_gdl run_cu6_sas run_cu7_zml run_cu8_radall run_cu9_gfdl  \
                run_cu99_pkf)
set cu_index = (0 1 2 3 4 5 6 7 8 9 99)

set i = 1
while ($i <= $CU_NUM)
    mkdir $dir[$i]
    cd $dir[$i]

    ln -sf ~/global_cwrf/exe/*          .
    ln -sf wrf.exe.r135.GNU wrf.exe
    ln -sf /project/projectdirs/cwrf/cwrf/constant_files/* .
    ln -sf /project/projectdirs/cwrf/cwrf/1993/combined/*_d01 .

    cp /project/projectdirs/cwrf/cwrf/namelist/namelist.input.1993050200 namelist.input 
    sed -i -e '/end_month/s/= 06/= 08/; /cu_physics/s/= 3/= '$cu_index[$i]'/' namelist.input 
    if (8 == $cu_index[$i]) then 
        sed -i -e '/cudt/s/= 0./= 10./' namelist.input
    endif  

    cd ..

    @ i++
end  
