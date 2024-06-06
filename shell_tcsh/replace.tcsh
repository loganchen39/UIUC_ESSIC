#!/bin/tcsh

set dum_out = "soda3.4.1_5dy_ocean_or_1981_03_13.nc"

set dum_out = `echo $dum_out | sed -e 's/or/reg/g'`

echo $dum_out 
