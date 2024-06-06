#!/bin/tcsh -x

set NUM_ALL        = 12
set DATA_DIR_INPUT = "\/scratch\/scratchdirs\/lgchen\/data\/sim_1993\/pr_daily\/cu"
set fn_mem         = ("CTL" bmj_cwp3 ctl_scuOff cu1 cu1_ishall0 run_cu2_bmj                          \
                      run_cu4_gd run_cu5_gdl run_cu7_zml run_cu8_randall run_cu9_gfdl run_cu10_mit)  \

cd /global/u1/l/lgchen/code/AR-OptEns-2010/ave

set i = 1
while ($i <= $NUM_ALL - 1)
    # set j = $i + 1
    @ j = $i + 1
    while ($j <= $NUM_ALL)
        sed '/1_PR_daily.bin/s/1_PR_daily.bin/'$fn_mem[$i]'_PR_daily.bin/;  \
             /2_PR_daily.bin/s/2_PR_daily.bin/'$fn_mem[$j]'_PR_daily.bin/;  \
             /opt_data_file/s/output_PR_daily.bin/ave_'$fn_mem[$i]'-'$fn_mem[$j]'_PR_daily.bin/'  \
             config.nml.template >&! config.nml

        ave.exe >&! log.txt

        @ j ++
    end

    @ i ++

    # exit
end
