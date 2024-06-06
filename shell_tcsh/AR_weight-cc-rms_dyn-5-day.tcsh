#!/bin/tcsh -x

set NUM_ALPHA_MEM  = 5
set alpha_mem      = (0.0 0.25 0.5 0.75 1.0)
set NUM_MEM        = 16
set fn_mem         = ("cu0-nocu" cu1-kf cu2-bmj cu4-gd cu5-gdl cu8-randall cu9-gfdl cu99-pkf  \
                      lsm-noah mp02-lin mp08-thompson_v3.1 pbl-myj pbl-uw rad-cam rad-fuliou  \
                      rad-rrtmlw+gsfcsw)

cd /scratch/scratchdirs/lgchen/projects/PrOpt_NOAA_AnnualReport/weight_cc_rms

set sample_sd_char = ""
set sample_ed_char = ""

set i = 1
set j = 1

while ($i <= $NUM_ALPHA_MEM)
    set sample_sm = 5
    set sample_sd = 27
    set sample_em = 5
    set sample_ed = 31

    while (1)
        if ($sample_sd <= 9) then
            set sample_sd_char = 0${sample_sd}
        else
            set sample_sd_char = ${sample_sd}
        endif

        if ($sample_ed <= 9) then
            set sample_ed_char = 0${sample_ed}
        else
            set sample_ed_char = ${sample_ed}
        endif

        sed '/alpha/s/= 0.0/= '$alpha_mem[$i]'/;  \
             /wgt_file/s/wgt.bin/wgt_alpha-'$alpha_mem[$i]'_19930'$sample_sm''$sample_sd_char'-19930'$sample_em''$sample_ed_char'.bin/;  \
             /cc_obs/s/19930502-19930531/19930'$sample_sm''$sample_sd_char'-19930'$sample_em''$sample_ed_char'/;  \
             /rms_obs/s/19930502-19930531/19930'$sample_sm''$sample_sd_char'-19930'$sample_em''$sample_ed_char'/'  \
           config.nml.template >&! config.nml

        ./weight_cc_rms.exe >&! log_tmp.txt

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

    @ i ++
end
