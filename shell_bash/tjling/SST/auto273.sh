#!/bin/bash
datadir="/scratch/scratchdirs/tjling/OISST/V2"
workdir="/scratch/scratchdirs/tjling/OISST/V2/toGRIB"
db="19810901"
de="20091231"
i=0
d=$db
mkdir -p 273
cd $workdir
while [ "$d" -ne "$de" ]
do
  d=`date -d "$db $i days" +%Y%m%d`
  y=${d:0:4}
  #ls -l $y/$d.grb
  if [ -d "273/$y" ]
  then
	    echo ""
  else
  		mkdir -p 273/$y
  fi 
  /global/u2/t/tjling/bin/cdo.120 -f grb addc,273.15 $y/$d.grb 273/$y/$d.grb
  let i=i+1
done	



