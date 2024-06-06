#!/bin/bash
datadir="/scratch/scratchdirs/tjling/OISST/V2"
workdir="/scratch/scratchdirs/tjling/OISST/V2/toGRIB"
db="19920405"
de="19920406"
i=0
d=$db
cd $workdir
while [ "$d" -ne "$de" ]
do
  d=`date -d "$db $i days" +%Y%m%d`
  echo $d
  y=${d:0:4}
  if [ -e $datadir/NetCDF/$y/AVHRR-AMSR/amsr-avhrr-v2.$d.nc.gz ]
  then
		  cp $datadir/NetCDF/$y/AVHRR-AMSR/amsr-avhrr-v2.$d.nc.gz \
             $workdir/$d.nc.gz
  else
		  cp $datadir/NetCDF/$y/AVHRR/avhrr-only-v2.$d.nc.gz \
		     $workdir/$d.nc.gz
  fi
  file=$d.nc
  gunzip -f $file."gz"
  ncpdq -O -U $file -o temp1.nc
  ncks -O -v sst  temp1.nc -o temp.nc
  ncatted -a _FillValue,,o,f,-9.99 temp.nc
  cdo -f grb -b 32 copy temp.nc temp.grb
  wgrib temp.grb | wgrib temp.grb -i -PDS -GDS -o bindump > temp.out
  sed -e "s/PRES:kpds5=1:kpds6=99/TMP:kpds5=11:kpds6=1/g" \
      -e "s/PDS=\(................\)0163/PDS=\10b01/g" temp.out > aaa
  gribfile=`basename $file ".nc"`
  cat aaa | ~/bin/gribw -prec 32 bindump -o  $gribfile".grb"
  if [ -d "$y" ]
  then
	    echo ""
  else
  		mkdir -p $y
  fi 
  mv $gribfile".grb" $y/
  
  rm $file
  let i=i+1
done	



