#!/bin/tcsh -x

set NUM_ALL        = 12
set DATA_DIR_INPUT = "\/scratch\/scratchdirs\/lgchen\/data\/result_data\/cc_rms"
set fn_mem         = ("CTL" bmj_cwp3 ctl_scuOff cu1 cu1_ishall0 run_cu2_bmj                          \
                      run_cu4_gd run_cu5_gdl run_cu7_zml run_cu8_randall run_cu9_gfdl run_cu10_mit)
set dofm_1993      = (31 28 31 30 31 30 31 31 30 31 30 31)

cd /global/u1/l/lgchen/code/AR-OptEns-2010/freq_cc_rms_region

set i = 1
while ($i <= $NUM_ALL - 1)
    # set j = $i + 1
    @ j = $i + 1
    while ($j <= $NUM_ALL)
        # for 12 months
        set k = 1
        while ($k <= 12)
            if ($k <= 9) then
                sed '/cc_file/s/cc.bin/cc_obs_ave-'$fn_mem[$i]'-'$fn_mem[$j]'_PR_19930'$k'01-19930'$k''$dofm_1993[$k]'.bin/;  \
                     /rms_file/s/rms.bin/rms_obs_ave-'$fn_mem[$i]'-'$fn_mem[$j]'_PR_19930'$k'01-19930'$k''$dofm_1993[$k]'.bin/;  \
                     /freq_file/s/freq_cc_rms.nc/freq_cc_rms_'$fn_mem[$i]'-'$fn_mem[$j]'_PR_19930'$k'01-19930'$k''$dofm_1993[$k]'.nc/'  \
                     config.nml.template >&! config.nml
            else
                sed '/cc_file/s/cc.bin/cc_obs_ave-'$fn_mem[$i]'-'$fn_mem[$j]'_PR_1993'$k'01-1993'$k''$dofm_1993[$k]'.bin/;  \
                     /rms_file/s/rms.bin/rms_obs_ave-'$fn_mem[$i]'-'$fn_mem[$j]'_PR_1993'$k'01-1993'$k''$dofm_1993[$k]'.bin/;  \
                     /freq_file/s/freq_cc_rms.nc/freq_cc_rms_'$fn_mem[$i]'-'$fn_mem[$j]'_PR_1993'$k'01-1993'$k''$dofm_1993[$k]'.nc/'  \
                     config.nml.template >&! config.nml
            endif

            freq_cc_rms_region.exe >&! log_month.txt
            
            @ k ++

            # exit
        end

        # for 4 seasons, better to be as DJF
        set k = 1
        while ($k <= 4)
            @ sm = 3 * ($k - 1) + 1
            @ em = 3 * $k
            if ($k <= 3) then
                sed '/cc_file/s/cc.bin/cc_obs_ave-'$fn_mem[$i]'-'$fn_mem[$j]'_PR_19930'$sm'01-19930'$em''$dofm_1993[$em]'.bin/;  \
                     /rms_file/s/rms.bin/rms_obs_ave-'$fn_mem[$i]'-'$fn_mem[$j]'_PR_19930'$sm'01-19930'$em''$dofm_1993[$em]'.bin/;  \
                     /freq_file/s/freq_cc_rms.nc/freq_cc_rms_'$fn_mem[$i]'-'$fn_mem[$j]'_PR_19930'$sm'01-19930'$em''$dofm_1993[$em]'.nc/'  \
                     config.nml.template >&! config.nml
            else
                sed '/cc_file/s/cc.bin/cc_obs_ave-'$fn_mem[$i]'-'$fn_mem[$j]'_PR_1993'$sm'01-1993'$em''$dofm_1993[$em]'.bin/;  \
                     /rms_file/s/rms.bin/rms_obs_ave-'$fn_mem[$i]'-'$fn_mem[$j]'_PR_1993'$sm'01-1993'$em''$dofm_1993[$em]'.bin/;  \
                     /freq_file/s/freq_cc_rms.nc/freq_cc_rms_'$fn_mem[$i]'-'$fn_mem[$j]'_PR_1993'$sm'01-1993'$em''$dofm_1993[$em]'.nc/'  \
                     config.nml.template >&! config.nml
            endif

            freq_cc_rms_region.exe >&! log_season.txt           

            @ k ++
        end 

        # for 1 year
        sed '/cc_file/s/cc.bin/cc_obs_ave-'$fn_mem[$i]'-'$fn_mem[$j]'_PR_19930101-19931231.bin/;  \
             /rms_file/s/rms.bin/rms_obs_ave-'$fn_mem[$i]'-'$fn_mem[$j]'_PR_19930101-19931231.bin/;  \
             /freq_file/s/freq_cc_rms.nc/freq_cc_rms_'$fn_mem[$i]'-'$fn_mem[$j]'_PR_19930101-19931231.nc/'  \
             config.nml.template >&! config.nml

        freq_cc_rms_region.exe >&! log_year.txt       

        @ j ++
    end

    @ i ++
end
