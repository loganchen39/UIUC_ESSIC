#!/bin/tcsh
#PBS -N CWRF_post
#PBS -q regular
#PBS -l walltime=36:00:00
#PBS -l mppwidth=1
#PBS -V
#PBS -m n
#PBS -j eo


set TIME = `date +%Y%m%d%H%M%S`
set LOGFILE = "log."${TIME}
unlimit
set YYYY = 2008
set YYYN = 2009

cd /global/scratch/sd/shenjian/run/CWRF/jobs/

/project/projectdirs/cwrf/cwrf/postprocess/CWRFpost.pl -d /global/scratch/sd/shenjian/run/CWRF/ERI2/ -i /global/scratch/sd/shenjian/run/CWRF/ERI2/wrfinput_d01 -l /global/scratch/sd/shenjian/run/CWRF/ERI2/namelist.input -w /global/scratch/sd/shenjian/run/CWRF/ERI2/wrf.exe -r 251 -t ${YYYY}0101-${YYYN}0101 -n ${YYYY} -u t2m,t2min,t2max,rainc,rainnc -o /project/projectdirs/cwrf/cwrf_post_results/ERI/1989-2009/${YYYY}/ -f -m "CWRF ERI long run, at revision 251, ${YYYY}" >&! ./post.log.${YYYY}
