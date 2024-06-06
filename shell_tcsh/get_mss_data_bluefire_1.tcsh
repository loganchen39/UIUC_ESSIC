#!/bin/tcsh -x

cd /ptmp/lgchen/projects/CWRFV3_new/CWRF_SVN/CWRFV3.1.1/run_cu7_zml_2

# set mon      = 12
# set dofm     = 31
# set day      = 1
# set day_char = ""
# 
# while ($day <= $dofm)
#     if ($day <= 9) then
#         set day_char = 0$day
# 	else
# 		set day_char = $day
#     endif
# 
# 	msrcp mss:/LGCHEN/cu7_zml_org/wrfout_d01_1992-12-${day_char}_00:00:00  .
# 
# 	@ day ++
# end

set mon      = 10
set dofm     = (31 30)
set idx      = 1
# set day      = 1
set day_char = ""

while ($mon <= 11) 
    set day = 1
	@ idx = $mon - 9
	while ($day <= $dofm[$idx])
        if ($day <= 9) then
            set day_char = 0$day
		else
			set day_char = $day
		endif

		msrcp mss:/LGCHEN/cu7_zml_org_2nd_right/wrfout_d01_1993-${mon}-${day_char}_00:00:00  .

        @ day ++
	end

	@ mon ++
end
