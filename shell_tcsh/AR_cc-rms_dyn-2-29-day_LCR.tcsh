#!/bin/tcsh -x

# set NUM_MEM        = 16
# set DATA_DIR_INPUT = "\/scratch\/scratchdirs\/lgchen\/projects\/PrAt2mOpt_AGU\/data\/AnnualReport"
set DATA_DIR_INPUT = "\/scratch\/scratchdirs\/lgchen\/projects\/PrAt2mOpt_AGU\/opt_forcast_daily\/result_data\/AnnualReport"
# set fn_mem         = ("cu0-nocu" cu1-kf cu2-bmj cu4-gd cu5-gdl cu8-randall cu9-gfdl cu99-pkf  \
#                       lsm-noah mp02-lin mp08-thompson_v3.1 pbl-myj pbl-uw rad-cam rad-fuliou  \
#                       rad-rrtmlw+gsfcsw)
set alpha_mem      = (0.0 0.25 0.5 0.75 1.0)
set ALPHA_NUM      = 5
set NUM_DAY_MAX    = 29

cd /scratch/scratchdirs/lgchen/projects/PrAt2mOpt_AGU/cc_rms

set day = 3
while ($day <= $NUM_DAY_MAX)
    mkdir ./result_data/AnnualReport/dyn_${day}-day_sa

    set i = 1
    while ($i <= $ALPHA_NUM)
        sed '/test_name_2/s/""/"alpha-'$alpha_mem[$i]'"/;  \
             /data_file_2/s/""/"'${DATA_DIR_INPUT}'\/dyn_'$day'-day_sa\/rain_opt-forcast_alpha-'$alpha_mem[$i]'_19930601-19930730.bin"/;  \
             /output_data_path/s/2/'${day}'/'           \
             config.nml.template >&! config.nml  
        
        ./cc_rms.exe >&! log_tmp.txt
 
        sed '/test_name_2/s/""/"alpha-'$alpha_mem[$i]'"/;  \
             /data_file_2/s/""/"'${DATA_DIR_INPUT}'\/dyn_'$day'-day_sa\/rain_opt-forcast_alpha-'$alpha_mem[$i]'_19930601-19930730.bin"/;  \
             /output_data_path/s/2/'${day}'/;           \
             /sample_start_month/s/06/07/;  \
             /sample_start_day/s/01/01/;    \
             /sample_end_month/s/06/07/;    \
             /sample_end_day/s/30/30/'      \
             config.nml.template >&! config.nml   

        ./cc_rms.exe >&! log_tmp.txt

        @ i ++
    end
    
    @ day ++

    # exit
end
