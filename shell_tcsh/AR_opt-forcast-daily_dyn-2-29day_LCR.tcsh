#!/bin/tcsh -x

set NUM_ALPHA_MEM  = 5
set alpha_mem      = (0.0 0.25 0.5 0.75 1.0)
# set NUM_MEM        = 16
# set fn_mem         = ("cu0-nocu" cu1-kf cu2-bmj cu4-gd cu5-gdl cu8-randall cu9-gfdl cu99-pkf  \
#                       lsm-noah mp02-lin mp08-thompson_v3.1 pbl-myj pbl-uw rad-cam rad-fuliou  \
#                       rad-rrtmlw+gsfcsw)
set NUM_DAY_MAX    = 29

cd /scratch/scratchdirs/lgchen/projects/PrAt2mOpt_AGU/opt_forcast_daily

set day = 4
while ($day <= $NUM_DAY_MAX)
    mkdir ./result_data/AnnualReport/dyn_${day}-day_sa

    set i = 1
    while ($i <= $NUM_ALPHA_MEM)
        #  mkdir ./result_data/dyn_${day}-day/alpha-$alpha_mem[$i]

        # set sample_sm = 5
        # @ sample_sd = 31 - ($day - 1)
        # set sample_em = 5
        # set sample_ed = 31
   
        sed '/wgt_data_dir/s/2/'${day}'/;  \
             /wgt_data_dir/s/0.0/'$alpha_mem[$i]'/;  \
             /output_data_path/s/2/'$day'/'  \
           config.nml.template >&! config.nml
    
        ./opt_forcast.exe >&! log_tmp.txt

        mv ./result_data/AnnualReport/dyn_${day}-day_sa/rain_opt-forcast_19930601-19930730.bin  \
           ./result_data/AnnualReport/dyn_${day}-day_sa/rain_opt-forcast_alpha-$alpha_mem[$i]_19930601-19930730.bin
   
        @ i ++
    end

    @ day ++
end
