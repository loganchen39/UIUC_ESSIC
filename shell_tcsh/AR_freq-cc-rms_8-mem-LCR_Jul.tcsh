#!/bin/tcsh -x

set NUM_MEM  = 8
set DATA_DIR = "\/scratch\/scratchdirs\/lgchen\/projects\/PrAt2mOpt_AGU\/cc_rms\/result_data\/AnnualReport\/plot_July_dynamic_1_mon"
set RES_DIR  = ".\/result_data\/AnnualReport\/dynamic_1_mon\/Jul"
set fn_mem   = (mp08-thompson_v3.1 ave org-opt 0.0 0.25 0.5 0.75 1.0)

cd /scratch/scratchdirs/lgchen/projects/PrAt2mOpt_AGU/freq_cc_rms_region

set i = 1
while ($i <= $NUM_MEM)
    sed '/cc_file/s/""/"'${DATA_DIR}'\/cc_obs_'$fn_mem[$i]'_RAIN_19930701-19930730.bin"/;    \
         /rms_file/s/""/"'${DATA_DIR}'\/rms_obs_'$fn_mem[$i]'_RAIN_19930701-19930730.bin"/;  \
         /freq_file/s/""/"'${RES_DIR}'\/freq_cc_rms_Jul_'$fn_mem[$i]'.nc"/'                 \
         config.nml.template >&! config.nml

    ./freq_cc_rms_region.exe >&! log_Jul_${i}.txt
        
    @ i ++

    # exit
end

