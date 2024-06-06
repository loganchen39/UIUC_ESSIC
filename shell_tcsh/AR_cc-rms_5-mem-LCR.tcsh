#!/bin/tcsh -x

set NUM_MEM        = 5
# set DATA_DIR_INPUT = "\/scratch\/scratchdirs\/lgchen\/projects\/PrAt2mOpt_AGU\/opt_forcast\/result_data"
set DATA_DIR_INPUT = "\/scratch\/scratchdirs\/lgchen\/projects\/PrAt2mOpt_AGU\/opt_forcast_daily\/result_data"
set fn_mem         = ("0.0" 0.25 "0.5" 0.75 "1.0")

cd /scratch/scratchdirs/lgchen/projects/PrAt2mOpt_AGU/cc_rms

set i = 1
while ($i <= $NUM_MEM)
    sed '/test_name_2/s/""/"'$fn_mem[$i]'"/;  \
         /data_file_2/s/""/"'${DATA_DIR_INPUT}'\/rain_opt-forcast_alpha-'$fn_mem[$i]'_19930601-19930730.bin"/'  \
         config.nml.template >&! config.nml  
    
    ./cc_rms.exe >&! log_opt_July_${i}.txt

    @ i ++

    # exit
end
