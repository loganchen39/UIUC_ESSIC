#!/bin/tcsh -x

set NUM_ALPHA_DIR = 5
set alpha_dir     = (alpha-0.0 alpha-0.25 alpha-0.5 alpha-0.75 alpha-1.0)
set NUM_DAY_MAX   = 29

cd /scratch/scratchdirs/lgchen/projects/PrOpt_NOAA_AnnualReport/weight_cc_rms/result_data

set sample_sd_char = ""
set sample_ed_char = ""
set rec_cnt_char   = ""

#set rec_cnt = 1

set day = 2
while($day <= $NUM_DAY_MAX)
    cd dyn_${day}-day

    set i = 1
    while ($i <= $NUM_ALPHA_DIR)
        cd $alpha_dir[$i]
    
        set sample_sm = 5
        @ sample_sd = 31 - ($day - 1)
        set sample_em = 5
        set sample_ed = 31
    
        set rec_cnt = 1
    
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
    
            if ($rec_cnt <= 9) then
                set rec_cnt_char = 0$rec_cnt
            else
                set rec_cnt_char = $rec_cnt
            endif  
    
            mv wgt_$alpha_dir[$i]_19930${sample_sm}${sample_sd_char}-19930${sample_em}${sample_ed_char}.bin weight.bin${rec_cnt_char}
    
            @ rec_cnt ++
    
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

        cd ..
    end

    @ day ++

    cd ..
end
