#!/bin/tcsh -x

set NUM_ALL        = 12
set DATA_DIR_INPUT = "\/scratch\/scratchdirs\/lgchen\/data\/result_data\/ave"
set fn_mem         = ("CTL" bmj_cwp3 ctl_scuOff cu1 cu1_ishall0 run_cu2_bmj                          \
                      run_cu4_gd run_cu5_gdl run_cu7_zml run_cu8_randall run_cu9_gfdl run_cu10_mit)
set dofm_1993      = (31 28 31 30 31 30 31 31 30 31 30 31)

cd /global/u1/l/lgchen/code/AR-OptEns-2010/cc_rms

@ i = 1
while ($i <= $NUM_ALL - 1)
    @ j = $i + 1
    while ($j <= $NUM_ALL)
        # for 12 months
        set k = 1
        while ($k <= 12)
            sed '/test_name_2/s/""/"ave-'$fn_mem[$i]'-'$fn_mem[$j]'"/;  \
                 /data_file_2/s/ave_PR_daily.bin/ave_'$fn_mem[$i]'-'$fn_mem[$j]'_PR_daily.bin/;  \
                 /sample_start_month/s/01/'$k'/;  \
                 /sample_end_month/s/01/'$k'/;    \
                 /sample_end_day/s/31/'$dofm_1993[$k]'/'  \
                 config.nml.template >&! config.nml

            cc_rms.exe >&! log_month.txt
            
            @ k ++

            # exit
        end

        # for 4 seasons, better to be as DJF
        set k = 1
        while ($k <= 4)
            @ sm = 3 * ($k - 1) + 1
            @ em = 3 * $k
            sed '/test_name_2/s/""/"ave-'$fn_mem[$i]'-'$fn_mem[$j]'"/;  \
                 /data_file_2/s/ave_PR_daily.bin/ave_'$fn_mem[$i]'-'$fn_mem[$j]'_PR_daily.bin/;  \
                 /sample_start_month/s/01/'$sm'/;  \
                 /sample_end_month/s/01/'$em'/;    \
                 /sample_end_day/s/31/'$dofm_1993[$em]'/'  \
                 config.nml.template >&! config.nml

            cc_rms.exe >&! log_season.txt           

            @ k ++
        end 

        # for 1 year
        sed '/test_name_2/s/""/"ave-'$fn_mem[$i]'-'$fn_mem[$j]'"/;  \
             /data_file_2/s/ave_PR_daily.bin/ave_'$fn_mem[$i]'-'$fn_mem[$j]'_PR_daily.bin/;  \
             /sample_end_month/s/01/12/'               \
             config.nml.template >&! config.nml

        cc_rms.exe >&! log_year.txt       

        @ j ++
    end

    @ i ++
end
