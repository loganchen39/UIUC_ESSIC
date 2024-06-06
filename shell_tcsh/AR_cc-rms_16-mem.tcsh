#!/bin/tcsh -x

set NUM_MEM        = 16
set DATA_DIR_INPUT = "\/scratch\/scratchdirs\/lgchen\/projects\/PrAt2mOpt_AGU\/data\/AnnualReport"
set fn_mem         = ("cu0-nocu" cu1-kf cu2-bmj cu4-gd cu5-gdl cu8-randall cu9-gfdl cu99-pkf  \
                      lsm-noah mp02-lin mp08-thompson_v3.1 pbl-myj pbl-uw rad-cam rad-fuliou  \
                      rad-rrtmlw+gsfcsw)

cd /scratch/scratchdirs/lgchen/projects/PrAt2mOpt_AGU/cc_rms

set i = 1
while ($i <= $NUM_MEM)
    sed '/test_name_2/s/""/"'$fn_mem[$i]'"/;  \
         /data_file_2/s/""/"'${DATA_DIR_INPUT}'\/rain_'$fn_mem[$i]'_19930502-19930730.bin"/'  \
         config.nml.template >&! config.nml  
    
    ./cc_rms.exe >&! log_member_Jul_${i}.txt

    @ i ++

    # exit
end
