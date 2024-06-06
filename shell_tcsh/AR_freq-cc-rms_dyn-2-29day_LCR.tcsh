#!/bin/tcsh -x

# set NUM_MEM        = 16
# set DATA_DIR_INPUT = "\/scratch\/scratchdirs\/lgchen\/projects\/PrAt2mOpt_AGU\/data\/AnnualReport"
set DATA_DIR_INPUT = "\/scratch\/scratchdirs\/lgchen\/projects\/PrAt2mOpt_AGU\/cc_rms\/result_data\/AnnualReport"
# set fn_mem         = ("cu0-nocu" cu1-kf cu2-bmj cu4-gd cu5-gdl cu8-randall cu9-gfdl cu99-pkf  \
#                       lsm-noah mp02-lin mp08-thompson_v3.1 pbl-myj pbl-uw rad-cam rad-fuliou  \
#                       rad-rrtmlw+gsfcsw)
set alpha_mem      = (0.0 0.25 0.5 0.75 1.0)
set ALPHA_NUM      = 5
set NUM_DAY_MAX    = 29

cd /scratch/scratchdirs/lgchen/projects/PrAt2mOpt_AGU/freq_cc_rms_region

set day = 3
while ($day <= $NUM_DAY_MAX)
    mkdir ./result_data/AnnualReport/dyn_${day}-day_sa

    set i = 1
    while ($i <= $ALPHA_NUM)
        sed '/cc_file/s/""/"'${DATA_DIR_INPUT}'\/dyn_'${day}'-day_sa\/cc_obs_alpha-'$alpha_mem[$i]'_RAIN_19930601-19930630.bin"/;  \
             /rms_file/s/""/"'${DATA_DIR_INPUT}'\/dyn_'$day'-day_sa\/rms_obs_alpha-'$alpha_mem[$i]'_RAIN_19930601-19930630.bin"/;  \
             /freq_file/s/""/".\/result_data\/AnnualReport\/dyn_'${day}'-day_sa\/freq_cc_rms_Jun_alpha-'$alpha_mem[$i]'.nc"/'      \
             config.nml.template >&! config.nml  
        
        ./freq_cc_rms_region.exe >&! log_tmp.txt
 
        sed '/cc_file/s/""/"'${DATA_DIR_INPUT}'\/dyn_'${day}'-day_sa\/cc_obs_alpha-'$alpha_mem[$i]'_RAIN_19930701-19930730.bin"/;  \
             /rms_file/s/""/"'${DATA_DIR_INPUT}'\/dyn_'$day'-day_sa\/rms_obs_alpha-'$alpha_mem[$i]'_RAIN_19930701-19930730.bin"/;  \
             /freq_file/s/""/".\/result_data\/AnnualReport\/dyn_'${day}'-day_sa\/freq_cc_rms_Jul_alpha-'$alpha_mem[$i]'.nc"/'      \
             config.nml.template >&! config.nml  
        
        ./freq_cc_rms_region.exe >&! log_tmp.txt

        @ i ++
    end
    
    @ day ++

    # exit
end
