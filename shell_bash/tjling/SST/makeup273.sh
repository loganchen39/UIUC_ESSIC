#!/bin/bash
datadir="/scratch/scratchdirs/tjling/OISST/V2"
workdir="/scratch/scratchdirs/tjling/OISST/V2/toGRIB"
db="19810901"
de="20091231"
i=0
d=$db
mkdir -p 273
cd $workdir
for d in 19820425 19830424 19840429 19850428 19860427 19870405 19880403 19890402 19900401 19910407
do
#  d=`date -d "$db $i days" +%Y%m%d`
  y=${d:0:4}
  #ls -l $y/$d.grb
  if [ -d "273/$y" ]
  then
	    echo ""
  else
  		mkdir -p 273/$y
  fi 
  /global/u2/t/tjling/bin/cdo.120 -f grb addc,273.15 $y/$d.grb 273/$y/$d.grb
#  let i=i+1
done	



