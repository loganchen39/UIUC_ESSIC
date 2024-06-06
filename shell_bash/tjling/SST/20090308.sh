#!/bin/bash

DIR_NC="/home/pub/lgchen/OISST_v2/20090308"
DIR_GRIB="/home/pub/lgchen/OISST_v2/20090308"

db="20090308"
de="20090309"
i=0
d=$db

cd $DIR_GRIB

while [ "$d" -ne "$de" ]
do
    d=`date -d "$db $i days" +%Y%m%d`
    echo $d
    y=${d:0:4}

    # if [ -e $DIR_NC/AMSR-AVHRR/$y/amsr-avhrr-v2.$d.nc ]
    # then
    #     cp $DIR_NC/AMSR-AVHRR/$y/amsr-avhrr-v2.$d.nc  $DIR_GRIB/$d.nc
    # else
    #     cp $DIR_NC/AVHRR/$y/avhrr-only-v2.$d.nc  $DIR_GRIB/$d.nc
    # fi

    fn_nc=$d.nc
    # gunzip -f $fn_nc."gz"

    ncpdq -O -U $fn_nc -o temp1.nc
    ncks -O -v sst  temp1.nc -o temp.nc
    ncatted -a _FillValue,,o,f,-9.99 temp.nc
    cdo -f grb -b 32 copy temp.nc temp.grb
    wgrib temp.grb | wgrib temp.grb -i -PDS -GDS -o bindump > temp.out
    sed -e "s/PRES:kpds5=1:kpds6=99/TMP:kpds5=11:kpds6=1/g"  \
        -e "s/PDS=\(................\)0163/PDS=\10b01/g" temp.out > aaa
    cat aaa | /nas/lgchen/bin/gribw/gribw/gribw -prec 32 bindump -o  "temp1.grb"
    fn_grib=`basename $fn_nc ".nc"`
    cdo -f grb addc,273.15 temp1.grb $fn_grib".grb"

    # if [ -d "$y" ]
    # then
    #     echo ""
    # else
   	#     mkdir -p $y
    # fi 
    # mv $fn_grib".grb" $y/
    # rm $fn_nc
    let i=i+1
done	
