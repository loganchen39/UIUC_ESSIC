#!/bin/tcsh -fv

unalias cp

cp -f config.nml.template config.nml
./PrOpt.exe
mv ./result_data/weight.bin ./result_data/weight.bin_0502-0531

set month = 6
set day   = 1
set dofm  = 31

while ($month <= 7)
    if (6 == $month) then
        @ dofm = 30
    else if (7 == $month) then
        @ dofm = 29
    else
        echo "ERROR: invalid month!"
        exit 1
    endif

    @ day = 1
    while($day <= $dofm)
        if ($day <= 9) then
            sed '/sample_end_month/s/05/0'$month'/; /sample_end_day/s/31/0'${day}'/'  \
                config.nml.template >&! config.nml
        else 
            sed '/sample_end_month/s/05/0'$month'/; /sample_end_day/s/31/'$day'/'     \
                config.nml.template >&! config.nml
        endif
        sed -n '/sample_end_month/p; /sample_end_day/p' config.nml  # print to check

        ./PrOpt.exe

        if ($day <= 9) then
            mv ./result_data/weight.bin ./result_data/weight.bin_0502-0${month}0${day}
        else
            mv ./result_data/weight.bin ./result_data/weight.bin_0502-0${month}$day
        endif    
    
        @ day++
    end   

    @ month++ 
end








































































































































































































































