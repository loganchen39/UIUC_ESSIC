#!/bin/bash
root="/mnt/lfs0/projects/ciaqex/tiejuntemp/cwrf31/works/E29NSC04/bk_met_files"
y=2004
fl=""
for m in 04 05 06 07 08 09 10
do
		#    #met_em.d01.2004-06-19_00:00:00.nc
		    ncra -v PMSL ./met_em.d01.${y}-${m}-*.nc -o psl.$m.nc
		    fl=$fl" "psl.$m.nc
done
ncrcat -O $fl -o temp.nc
ncrename -v PMSL,psl temp.nc -o psl.nc
	
