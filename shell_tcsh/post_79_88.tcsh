#!/bin/tcsh
#PBS -N 1979_1988_ECHAM_post
#PBS -q regular
#PBS -l walltime=36:00:00
#PBS -l mppwidth=1
#PBS -V
#PBS -m n
#PBS -j eo


set TIME    = `date +%Y%m%d%H%M%S`
set LOGFILE = "log."${TIME}
unlimit

/project/projectdirs/cwrf/cwrf/postprocess/CWRFpost.pl -d /global/scratch/sd/lgchen/projects/CWRFV3/cwrf_run/ECHAM_1979010200_1991010100/run/ -r 257 -n AMIP10_79010200_89010100 >&! ./ECHAM_AMIP10_79010200_89010100_post.log
