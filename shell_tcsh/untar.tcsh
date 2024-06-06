#!/bin/tcsh -fv

cd /global/homes/l/lgchen/scratch/data/CWRF_raw_data/NCEPRII/2000-2006

set PRE_FLX = "flx.ft06."
set PRE_PGB = "pgb.anl."
set year    = 2006

set mon = 1
while ($mon <= 12)
    if ($mon <= 9) then
        set fn_flx = ${PRE_FLX}${year}0${mon}".tar"
        set fn_pgb = ${PRE_PGB}${year}0${mon}".tar"
    else
        set fn_flx = ${PRE_FLX}${year}${mon}".tar"
        set fn_pgb = ${PRE_PGB}${year}${mon}".tar"
    endif

    tar xvf $fn_flx
    tar xvf $fn_pgb

    @ mon++
end
