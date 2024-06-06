#!/bin/tcsh -x

cd /scratch/scratchdirs/lgchen/data/CWRF_raw_data/NCEPRII_daily/2007 

set dofm  = (31 29 31 30 31 30 31 31 30 31 30 31)
set mon   = 6
set day   = 1
set mon_c = ""
set md_c  = ""
while ($mon <= 12)
    if ($mon <= 9) then
        set mon_c = 0$mon
    else
        set mon_c = $mon
    endif

    @ day = 1
    while ($day <= $dofm[$mon])
        if ($day <= 9) then
            set mdh = ${mon_c}0$day
        else
            set mdh = $mon_c$day
        endif  

        foreach hr (00 06 12 18)
            cp -f pgb.2007${mdh}${hr}.grb  pgb.anl.2007${mdh}${hr}.grb 
        end 
 
        @ day ++ 
    end

    @ mon ++
end
