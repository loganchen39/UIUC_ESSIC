#!/bin/csh -f
#  Set the name of the job.
#$ -N PREP.WRF.HR
#!!!change
#  Make sure that the .e and .o file arrive in the working directory
#$ -cwd
#  Set the account to jetmgmt
#$ -A ciaqex
#  Ask for 1 cpus of type comp
#$ -pe wcomp 1
#$ -p 24
#  My code is re-runnable
#$ -r n
#  The max walltime for this job is 15 hours
#$ -l h_rt=2:00:00
set echo
setenv F_UFMTENDIAN big
setenv GMPIENVVAR F_UFMTENDIAN
echo "STARTING THE JOB"
echo -n "NODEFILE:"
cd /mnt/tg2/projects/ciaqex/tiejun/CWRF132/CWRFV1.3.2/run/diff_v213_hr.93
umask 022
unlimit
setenv NCARG_ROOT /home/tiejun/ncl
/home/tiejun/ncl/bin/ncl draw2d.ncl
echo "RUN OVER"

