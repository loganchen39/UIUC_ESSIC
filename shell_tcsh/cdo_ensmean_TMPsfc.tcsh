#!/bin/tcsh -x

set YR_START = 1981 
set YR_END   = 1981

set dofm     = (31 28 31 30 31 30 31 31 30 31 30 31)

set yr       = $YR_START
set mon      = 1
set mon_char = ""
set day      = 1
set day_char = ""

while ($yr <= $YR_END)
    @ mon = 1
    while ($mon <= 12)
        if ($mon <= 9) then
            set mon_char = 0$mon
        else
            set mon_char = $mon
        endif

        @ day = 1
        while ($day <= $dofm[$mon])
            if ($day <= 9) then
                set day_char = 0$day
            else
                set day_char = $day
            endif

            /global/homes/t/tjling/bin/cdo.120 ensmean  \
                ./1979-1981_3h/TMPsfc.${yr}${mon_char}${day_char}_*00.gr*b  \
                ./1981_daily/TMPsfc.d.${yr}${mon_char}${day_char}.grb

            @ day ++
        end
      
        @ mon ++
    end    

    @ yr ++
end
