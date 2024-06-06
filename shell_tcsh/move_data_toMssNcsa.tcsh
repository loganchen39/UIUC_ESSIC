#!/bin/tcsh

# Description: Transfer the CMAQ result data from 2049 to 2052 to MSS of NCSA
# Author     : Ligang Chen, lgchen@illinois.edu
# Created    : 06/25/2009
# Modified   : 06/25/2009

set SOURCE_DATA_DIR = /scratch/users/lgchen/CMAQ/output/cctm
set TARGET_HOST     = mss.ncsa.uiuc.edu
set TARGET_DATA_DIR = /UROOT/u/ac/lgchen/CMAQ/output/cctm

set year = 2048

while ($year <= 2052)
  cd $SOURCE_DATA_DIR/$year
  
  # msscmd cd $TARGET_DATA_DIR/$year, mput ACONC.*
  # msscmd cd $TARGET_DATA_DIR/$year, mput AEROVIS.*
  # msscmd cd $TARGET_DATA_DIR/$year, mput CGRID.*
  # msscmd cd $TARGET_DATA_DIR/$year, mput CONC.*
  # msscmd cd $TARGET_DATA_DIR/$year, mput DRYDEP.*
  # msscmd cd $TARGET_DATA_DIR/$year, mput R2_CAS001.log.*
  # msscmd cd $TARGET_DATA_DIR/$year, mput SSEMIS1.*
  # msscmd cd $TARGET_DATA_DIR/$year, mput WETDEP1.*

  set mon = 1

  while ($mon <= 12)
    if ($mon <= 9) then
      set yr_mon = ${year}0$mon
    else
      set yr_mon = ${year}$mon
    endif

    scp ACONC.$yr_mon*         ${TARGET_HOST}:$TARGET_DATA_DIR/$year
    scp AEROVIS.$yr_mon*       ${TARGET_HOST}:$TARGET_DATA_DIR/$year
    scp CGRID.$yr_mon*         ${TARGET_HOST}:$TARGET_DATA_DIR/$year
    scp CONC.$yr_mon*          ${TARGET_HOST}:$TARGET_DATA_DIR/$year
    scp DRYDEP.$yr_mon*        ${TARGET_HOST}:$TARGET_DATA_DIR/$year
    scp R2_CAS001.log.$yr_mon* ${TARGET_HOST}:$TARGET_DATA_DIR/$year
    scp SSEMIS1.$yr_mon*       ${TARGET_HOST}:$TARGET_DATA_DIR/$year
    scp WETDEP1.$yr_mon*       ${TARGET_HOST}:$TARGET_DATA_DIR/$year

    @ mon++
  end
   
  @ year++
end
