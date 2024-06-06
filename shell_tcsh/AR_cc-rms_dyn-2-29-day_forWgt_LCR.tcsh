#!/bin/tcsh -x

set NUM_MEM        = 16
set DATA_DIR_INPUT = "\/scratch\/scratchdirs\/lgchen\/projects\/PrAt2mOpt_AGU\/data\/AnnualReport"
set fn_mem         = ("cu0-nocu" cu1-kf cu2-bmj cu4-gd cu5-gdl cu8-randall cu9-gfdl cu99-pkf  \
                      lsm-noah mp02-lin mp08-thompson_v3.1 pbl-myj pbl-uw rad-cam rad-fuliou  \
                      rad-rrtmlw+gsfcsw)
set NUM_DAY_MAX    = 29

cd /scratch/scratchdirs/lgchen/projects/PrAt2mOpt_AGU/cc_rms

set day = 4
while ($day <= $NUM_DAY_MAX)
    set sample_sm = 5
    @ sample_sd   = 31 - ($day - 1)
    set sample_em = 5
    set sample_ed = 31
    
    mkdir ./result_data/AnnualReport/dyn_${day}-day_forWgt_sa

    # while (${sample_em} <= 7 && ${sample_ed} <= 29)
    while (${sample_em} <= 7)
        set i = 1
        while ($i <= $NUM_MEM)
            sed '/test_name_2/s/""/"'$fn_mem[$i]'"/;  \
                 /data_file_2/s/""/"'${DATA_DIR_INPUT}'\/rain_'$fn_mem[$i]'_19930502-19930730.bin"/;  \
                 /output_data_path/s/5/'${day}'/;           \
                 /sample_start_month/s/05/'${sample_sm}'/;  \
                 /sample_start_day/s/02/'${sample_sd}'/;    \
                 /sample_end_month/s/05/'${sample_em}'/;    \
                 /sample_end_day/s/31/'${sample_ed}'/'      \
                 config.nml.template >&! config.nml  
            
            ./cc_rms.exe >&! log_tmp.txt
        
            @ i ++
        
            # exit
        end
    
        @ sample_sd ++
        if ($sample_sm == 5 && $sample_sd >= 32) then
            @ sample_sm ++
            @ sample_sd = 1
        else if ($sample_sm == 6  && $sample_sd >= 31) then
            @ sample_sm ++
            @ sample_sd = 1
        endif
    
        @ sample_ed ++
        if ($sample_em == 5 && $sample_ed >= 32) then
            @ sample_em ++
            @ sample_ed = 1
        else if ($sample_em == 6  && $sample_ed >= 31) then
            @ sample_em ++
            @ sample_ed = 1
        endif
    
        if (${sample_em} == 7 && ${sample_ed} > 29) then
            break
        endif
    end

    @ day ++

    # exit
end
