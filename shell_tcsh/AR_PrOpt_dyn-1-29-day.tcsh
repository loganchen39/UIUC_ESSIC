#!/bin/tcsh -x

set NUM_EXPE       = 29
# set DATA_DIR_INPUT = "\/scratch\/scratchdirs\/lgchen\/projects\/PrAt2mOpt_AGU\/data\/AnnualReport"
# set fn_mem         = ("cu0-nocu" cu1-kf cu2-bmj cu4-gd cu5-gdl cu8-randall cu9-gfdl cu99-pkf  \
#                       lsm-noah mp02-lin mp08-thompson_v3.1 pbl-myj pbl-uw rad-cam rad-fuliou  \
#                       rad-rrtmlw+gsfcsw)

cd /scratch/scratchdirs/lgchen/projects/PrAt2mOpt_AGU/PrOpt_v0.1_201004091158

set i = 2
while ($i <= $NUM_EXPE)
    mkdir ./result_data/AnnualReport/weight_${i}-day
    # sed -i.bak -e '/output_data_path/s/dummy_dir/weight_'${i}'-day/'  config.nml.template

    set sample_sm = 5
    @   sample_sd = 31 - ($i - 1)
    set sample_em = 5
    set sample_ed = 31

    set j         = 1

    while ($sample_em <= 7)
        sed '/sample_start_month/s/05/'${sample_sm}'/;          \
             /sample_start_day/s/02/'${sample_sd}'/;            \
             /sample_end_month/s/05/'${sample_em}'/;            \
             /sample_end_day/s/31/'${sample_ed}'/;              \
             /output_data_path/s/dummy_dir/weight_'${i}'-day/'  \
             config.nml.template >&! config.nml

        ./PrOpt.exe >&! log_${i}-day.txt

        if ($j <= 9) then
            set j_char = 0$j
        else
            set j_char = $j
        endif

        mv ./result_data/AnnualReport/weight_${i}-day/weight.bin ./result_data/AnnualReport/weight_${i}-day/weight.bin$j_char
        mv ./result_data/AnnualReport/weight_${i}-day/weight.txt ./result_data/AnnualReport/weight_${i}-day/weight.txt$j_char
        @ j ++

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
 
        # exit
    end

    @ i ++

    # exit
end
