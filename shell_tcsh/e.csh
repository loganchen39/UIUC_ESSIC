#!/bin/csh -f
set mstore = /crunch/c16/ftp/pub/sun/ESSIC/ECHAM10
mkdir -p $mstore
set ens=(10)
foreach mem ( $ens )
set expcount = 1979
while ( $expcount < = 2011 )
echo Now in RUN $expcount
set filedir = /mstore/iri_1/forecast_usr/ECHAM4_3.23.D/EXP.D/LongRun1.D/IriLong${mem}.D
cd $filedir
cp  EC4AMIP${mem}_${expcount}??.01 $mstore
#ls -lrt *.01
@ expcount = $expcount + 1
end
end
exit
