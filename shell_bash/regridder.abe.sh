#!/bin/sh

DATADIR=/scratch/users/lgchen/DailyAccRF
PROGRAMDIR=/u/ac/lgchen/projects/trmm2rcm/ZJH

YEAR=1999
while test ${YEAR} -le 2008
do
  cd ${DATADIR}/${YEAR}
  for FILENAME in *.bin
  do
    echo Processing file ${FILENAME} ...
    cd ${PROGRAMDIR}
    rm dailyrecord.dat
    ln -sf ${DATADIR}/${YEAR}/${FILENAME} dailyrecord.dat

    done_dir2file_zjh.exe
    regridder.abe.exe
    regrid2dir.exe
    done.cut.exe
    
    mv new.regrid.data ${DATADIR}/${YEAR}/Interp.${FILENAME}
    echo -e "File ${FILENAME} finished.\n\n"
  done

  let YEAR=${YEAR}+1
done
