#!/bin/tcsh -x

set YR_START = 2009 
set YR_END   = 2009

set yr       = $YR_START
set mon      = 1
set mon_char = ""
while ($yr <= $YR_END)
    @ mon = 1
    while ($mon <= 12)
        if ($mon <= 9) then
            set mon_char = 0$mon
        else
            set mon_char = $mon
        endif
      
        foreach head (pgb flx.ft06)
            /global/homes/t/tjling/bin/cdo.120 splitday ../NCEPRII/2009/$head.${yr}${mon_char} ./2009/${head}.d.$yr$mon_char
        end
 
        @ mon ++
    end    

    @ yr ++
end
