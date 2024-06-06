#!/bin/csh

## Min Xu
# to do: set a jobname, and combine oe files

# comment, when use the command line to set PBS, seems it invoild all setting in scripts.

# -- #PBS setting
# # -- account
#
#PBS -l nodes=192

# # -- Specify a maximum wallclock of 4 hours
#PBS -l walltime=72:00:00
#
# # -- Set the name of the job, or moab will default to STDIN

#PBS -l pmem=200MB

#Usage: qsub $0 -v RSTYEAR=, RSTMNTH=, RSTCDAY=
#  initial run qsub $0
#  restart run qsub $0 -v RSTYEAR=, RSTMNTH=, RSTCDAY=

#MPI settings

#timing

@ DURTIM = 30
@ TOTTIM = 72 * 60

# global time setting for longrun, they will not changed for the whole run

set SCRIPNM = $0

set QSUBCMD = /usr/local/torque/2.5.7/bin/qsub
set BGNYEAR = 1998
set ENDYEAR = 2008
set BGNMNTH = 11
set ENDMNTH = 12

set CASEID = "T_XLAKE_LNG"
set RUNDIR = "/homes/minxu/lustre/cwrfinp/RUN2/"
set NMLDIR = "/homes/minxu/lustre/cwrfinp/NML/"
set INPDIR = "/homes/minxu/lustre/cwrfinp/ERI/new_lchen/XLAKE"
set SRCDIR = "/homes/minxu/CWRF_XLAKE/CWRFV3.1.1/main/"
set EXEFIL = "wrf.exe.fsnv.cs.vemis.unstable.cslim.m.lisss"
set JOBIDD = "LISSS01"

#set RLTIME = `date +%F_%R`
#set JOBIDD = `echo $PBS_JOBID | sed "s/ext-6-0.evergreen.umd.edu/$RLTIME/"`

setenv BASEDIR /homes/minxu/lustre/cwrf_test_lake
setenv STMPDIR ${BASEDIR}/${CASEID}
setenv WORKDIR ${STMPDIR}/cwrf.$JOBIDD

#restart run only
if($?RSTYEAR) then
    echo $RSTYEAR | egrep -q '^[0-9]+$'   # number = 0, else = 1
    if($?) then
       set output = ''
       set output = `/bin/ls -t wrfrst_d01_* | head -n 2 |tail -1`
       if($output != "") then
           echo "$output:t"
           set RSTYEAR = `echo $output:t | gawk '{print substr($0,12,4)}'`
           set RSTMNTH = `echo $output:t | gawk '{print substr($0,17,2)}'`
           set RSTCDAY = `echo $output:t | gawk '{print substr($0,20,2)}'`
           echo $RSTYEAR, $RSTMNTH, $RSTCDAY

       else
           echo "server error"
           exit 9
       endif
    endif
endif


# testing the arguments
# +xum attn: the RST* will be defined only using qsub -v options, otherwise they are undefined.
# so the following will not be executed after resubmission.
# xum, only exectute in initial run

if(! $?RSTYEAR) then
   set RSTYEAR = $BGNYEAR
endif

if(! $?RSTMNTH) then
   set RSTMNTH = $BGNMNTH
endif

if(! $?RSTCDAY) then
   set RSTCDAY = 1
endif

echo $RSTYEAR


if($RSTYEAR == $BGNYEAR && $RSTMNTH == $BGNMNTH && $RSTCDAY == 1) then
   set rstrtrun = 'false'
else
   set rstrtrun = 'true'
endif

# xum generate the time series YYYYMM

set TIMES =
foreach iy (`seq $RSTYEAR 1 $ENDYEAR`)

    if( $iy == $RSTYEAR ) then
        set STRTMON = $RSTMNTH
    else
        set STRTMON = 1
    endif
    if( $iy == $ENDYEAR ) then
        set STOPMON = $ENDMNTH
    else
        set STOPMON = 12
    endif

    foreach im (`seq $STRTMON 1 $STOPMON`)

        if( $im < 10 ) then
            set cm = 0$im
        else
            set cm =  $im
        endif
        set TIMES = ($TIMES $iy$cm)
    end

end

echo $TIMES

#set TIMES = ("199211" "199212" \
#             "199301" "199302" "199303" "199304" "199305" "199306" "199307" "199308" "199309" "199310" "199311" "199312")

# end of generate TIMES

setenv NPES $PBS_NP

# fixed settings
set INPFIL = "wrfinput_d01"
set BDYFIL = "wrfbdy_d01"
set LOWFIL = "wrflowinp_d01"
set SSTFIL = "wrfsst_d01"
set VEGFIL = "wrfveg_d01"
set NMLFIL = "namelist.input"

# only once per run
set echo
setenv F_UFMTENDIAN big
setenv GMPIENVVAR F_UFMTENDIAN
echo -n "NODEFILE:"
umask 022
unlimit

ln -sf ${RUNDIR}/* .
ln -sf ${SRCDIR}/$EXEFIL wrf.exe
# monthly loop
foreach TIME ($TIMES)

    @   LIMTIM = $TOTTIM - $DURTIM

    if($LIMTIM <= 2) then
       set LIMTIM = 2
    endif


    set BGNTIM = `date +%s`

    set TIMSTR = "."$TIME"0100"

#    ln -sf ${NMLDIR}/${NMLFIL}${TIMSTR}  $NMLFIL
    ln -sf ${INPDIR}/${INPFIL}${TIMSTR}  $INPFIL
    ln -sf ${INPDIR}/${BDYFIL}${TIMSTR}  $BDYFIL
    ln -sf ${INPDIR}/${LOWFIL}${TIMSTR}  $LOWFIL
    ln -sf ${INPDIR}/${SSTFIL}${TIMSTR}  $SSTFIL
    ln -sf ${INPDIR}/${VEGFIL}${TIMSTR}  $VEGFIL


    rm -f namelist.input

    # namelist modified
    set iyini = `echo $TIME |cut -c 1-4|bc`
    set imini = `echo $TIME |cut -c 5-6|bc`

    #+xum fix bugs to avoid the idini to rstcday in next month run
    if($TIME == $TIMES[1]) then
       set idini = $RSTCDAY
    else
       set idini = 1
    endif

    set iyend = $iyini
    set imend = $imini


    @ imend = $imini + 1

    if ($imend == '13') then
       set imend = 1
       @ iyend = $iyini + 1
    else
       echo $TIME
    endif

    if( $imini < 10 ) then
       set cmini = 0$imini
    else
       set cmini =  $imini
    endif
    if ($TIME == $TIMES[1] && $rstrtrun == 'false') then
       set rstrt = 'false'
    else
       set rstrt = 'true'
    endif

    /bin/rm -f  namelist.input$TIMSTR
    sed   -e "/start_year/ { s/1992/$iyini/g }" \
          -e "/end_year/   { s/1992/$iyend/g }" \
          -e "/start_month/{ s/11/$imini/g }" \
          -e "/end_month/  { s/12/$imend/g }" \
          -e "/start_day/  { s/01/$idini/g }" \
          -e "/julyr/      { s/1992/$iyini/g }" \
          -e "/restart    /{ s/false/$rstrt/g }" $NMLDIR/namelist.input.1992110100 > namelist.input$TIMSTR

    /bin/cp -f namelist.input$TIMSTR namelist.input
    # -end namelist

    rm -f rsl.error.0* rsl.out.0*

    echo "gtimeout ${LIMTIM}m mpirun -np $NPES ./wrf.exe >& ! wrf.log$TIMSTR"
    gtimeout ${LIMTIM}m mpirun -np $NPES ./wrf.exe >& ! wrf.log$TIMSTR
    set myst = $?

    echo $myst

    switch ($myst)
       case 124:
           echo "kill the program"
           echo "resubmiting job ..."

           #second latest wrfrst file

           set output = `/bin/ls -t wrfrst_d01_${iyini}-${cmini}* | head -n 2 |tail -1`
           echo "$output:t"
           set rstrtyr = `echo $output:t | gawk '{print substr($0,12,4)}'`
           set rstrtmn = `echo $output:t | gawk '{print substr($0,17,2)}'`
           set rstrtdy = `echo $output:t | gawk '{print substr($0,20,2)}'`
           echo $rstrtyr, $rstrtmn, $rstrtdy

           cd $HOME/runscript
           $QSUBCMD $SCRIPNM -v RSTYEAR=$rstrtyr,RSTMNTH=$rstrtmn,RSTCDAY=$rstrtdy
           exit 124
           breaksw
       case 125:
           echo "timeout failure"
           exit 126
           breaksw
       case 126:
           echo "cannot exec command"
           exit 126
           breaksw
       case 127:
           echo "cannot find command"
           exit 126
           breaksw
       case 1:
           echo "CWRF run error, please check error file"
           exit 1
           breaksw
       default:
           echo $myst
           breaksw
    endsw

    set ENDTIM = `date +%s`

    @ DURTIM = $DURTIM + $ENDTIM / 60 - $BGNTIM / 60

    echo $DURTIM

    /bin/mv -f rsl.out.0000   rsl.out$TIMSTR
    /bin/mv -f rsl.error.0000 rsl.err$TIMSTR

    #+xum for safty reason, keep the first day rstfile
    #/bin/rm -f wrfrst_d01_${iyini}-${cmini}*
    /bin/rm -f `ls wrfrst_d01_${iyini}-${cmini}* | grep -v wrfrst_d01_${iyini}-${cmini}-01_00:00:00`
    echo $NPES
end

exit 0#!/bin/csh

## Min Xu
# to do: set a jobname, and combine oe files

# comment, when use the command line to set PBS, seems it invoild all setting in scripts.

# -- #PBS setting
# # -- account
#
#PBS -l nodes=192

# # -- Specify a maximum wallclock of 4 hours
#PBS -l walltime=72:00:00
#
# # -- Set the name of the job, or moab will default to STDIN

#PBS -l pmem=200MB

#Usage: qsub $0 -v RSTYEAR=, RSTMNTH=, RSTCDAY=
#  initial run qsub $0
#  restart run qsub $0 -v RSTYEAR=, RSTMNTH=, RSTCDAY=

#MPI settings

#timing

@ DURTIM = 30
@ TOTTIM = 72 * 60

# global time setting for longrun, they will not changed for the whole run

set SCRIPNM = $0

set QSUBCMD = /usr/local/torque/2.5.7/bin/qsub
set BGNYEAR = 1998
set ENDYEAR = 2008
set BGNMNTH = 11
set ENDMNTH = 12

set CASEID = "T_XLAKE_LNG"
set RUNDIR = "/homes/minxu/lustre/cwrfinp/RUN2/"
set NMLDIR = "/homes/minxu/lustre/cwrfinp/NML/"
set INPDIR = "/homes/minxu/lustre/cwrfinp/ERI/new_lchen/XLAKE"
set SRCDIR = "/homes/minxu/CWRF_XLAKE/CWRFV3.1.1/main/"
set EXEFIL = "wrf.exe.fsnv.cs.vemis.unstable.cslim.m.lisss"
set JOBIDD = "LISSS01"

#set RLTIME = `date +%F_%R`
#set JOBIDD = `echo $PBS_JOBID | sed "s/ext-6-0.evergreen.umd.edu/$RLTIME/"`

setenv BASEDIR /homes/minxu/lustre/cwrf_test_lake
setenv STMPDIR ${BASEDIR}/${CASEID}
setenv WORKDIR ${STMPDIR}/cwrf.$JOBIDD

#restart run only
if($?RSTYEAR) then
    echo $RSTYEAR | egrep -q '^[0-9]+$'   # number = 0, else = 1
    if($?) then
       set output = ''
       set output = `/bin/ls -t wrfrst_d01_* | head -n 2 |tail -1`
       if($output != "") then
           echo "$output:t"
           set RSTYEAR = `echo $output:t | gawk '{print substr($0,12,4)}'`
           set RSTMNTH = `echo $output:t | gawk '{print substr($0,17,2)}'`
           set RSTCDAY = `echo $output:t | gawk '{print substr($0,20,2)}'`
           echo $RSTYEAR, $RSTMNTH, $RSTCDAY

       else
           echo "server error"
           exit 9
       endif
    endif
endif


# testing the arguments
# +xum attn: the RST* will be defined only using qsub -v options, otherwise they are undefined.
# so the following will not be executed after resubmission.
# xum, only exectute in initial run

if(! $?RSTYEAR) then
   set RSTYEAR = $BGNYEAR
endif

if(! $?RSTMNTH) then
   set RSTMNTH = $BGNMNTH
endif

if(! $?RSTCDAY) then
   set RSTCDAY = 1
endif

echo $RSTYEAR


if($RSTYEAR == $BGNYEAR && $RSTMNTH == $BGNMNTH && $RSTCDAY == 1) then
   set rstrtrun = 'false'
else
   set rstrtrun = 'true'
endif

# xum generate the time series YYYYMM

set TIMES =
foreach iy (`seq $RSTYEAR 1 $ENDYEAR`)

    if( $iy == $RSTYEAR ) then
        set STRTMON = $RSTMNTH
    else
        set STRTMON = 1
    endif
    if( $iy == $ENDYEAR ) then
        set STOPMON = $ENDMNTH
    else
        set STOPMON = 12
    endif

    foreach im (`seq $STRTMON 1 $STOPMON`)

        if( $im < 10 ) then
            set cm = 0$im
        else
            set cm =  $im
        endif
        set TIMES = ($TIMES $iy$cm)
    end

end

echo $TIMES

#set TIMES = ("199211" "199212" \
#             "199301" "199302" "199303" "199304" "199305" "199306" "199307" "199308" "199309" "199310" "199311" "199312")

# end of generate TIMES

setenv NPES $PBS_NP

# fixed settings
set INPFIL = "wrfinput_d01"
set BDYFIL = "wrfbdy_d01"
set LOWFIL = "wrflowinp_d01"
set SSTFIL = "wrfsst_d01"
set VEGFIL = "wrfveg_d01"
set NMLFIL = "namelist.input"

# only once per run
set echo
setenv F_UFMTENDIAN big
setenv GMPIENVVAR F_UFMTENDIAN
echo -n "NODEFILE:"
umask 022
unlimit

ln -sf ${RUNDIR}/* .
ln -sf ${SRCDIR}/$EXEFIL wrf.exe
# monthly loop
foreach TIME ($TIMES)

    @   LIMTIM = $TOTTIM - $DURTIM

    if($LIMTIM <= 2) then
       set LIMTIM = 2
    endif


    set BGNTIM = `date +%s`

    set TIMSTR = "."$TIME"0100"

#    ln -sf ${NMLDIR}/${NMLFIL}${TIMSTR}  $NMLFIL
    ln -sf ${INPDIR}/${INPFIL}${TIMSTR}  $INPFIL
    ln -sf ${INPDIR}/${BDYFIL}${TIMSTR}  $BDYFIL
    ln -sf ${INPDIR}/${LOWFIL}${TIMSTR}  $LOWFIL
    ln -sf ${INPDIR}/${SSTFIL}${TIMSTR}  $SSTFIL
    ln -sf ${INPDIR}/${VEGFIL}${TIMSTR}  $VEGFIL


    rm -f namelist.input

    # namelist modified
    set iyini = `echo $TIME |cut -c 1-4|bc`
    set imini = `echo $TIME |cut -c 5-6|bc`

    #+xum fix bugs to avoid the idini to rstcday in next month run
    if($TIME == $TIMES[1]) then
       set idini = $RSTCDAY
    else
       set idini = 1
    endif

    set iyend = $iyini
    set imend = $imini


    @ imend = $imini + 1

    if ($imend == '13') then
       set imend = 1
       @ iyend = $iyini + 1
    else
       echo $TIME
    endif

    if( $imini < 10 ) then
       set cmini = 0$imini
    else
       set cmini =  $imini
    endif
    if ($TIME == $TIMES[1] && $rstrtrun == 'false') then
       set rstrt = 'false'
    else
       set rstrt = 'true'
    endif

    /bin/rm -f  namelist.input$TIMSTR
    sed   -e "/start_year/ { s/1992/$iyini/g }" \
          -e "/end_year/   { s/1992/$iyend/g }" \
          -e "/start_month/{ s/11/$imini/g }" \
          -e "/end_month/  { s/12/$imend/g }" \
          -e "/start_day/  { s/01/$idini/g }" \
          -e "/julyr/      { s/1992/$iyini/g }" \
          -e "/restart    /{ s/false/$rstrt/g }" $NMLDIR/namelist.input.1992110100 > namelist.input$TIMSTR

    /bin/cp -f namelist.input$TIMSTR namelist.input
    # -end namelist

    rm -f rsl.error.0* rsl.out.0*

    echo "gtimeout ${LIMTIM}m mpirun -np $NPES ./wrf.exe >& ! wrf.log$TIMSTR"
    gtimeout ${LIMTIM}m mpirun -np $NPES ./wrf.exe >& ! wrf.log$TIMSTR
    set myst = $?

    echo $myst

    switch ($myst)
       case 124:
           echo "kill the program"
           echo "resubmiting job ..."

           #second latest wrfrst file

           set output = `/bin/ls -t wrfrst_d01_${iyini}-${cmini}* | head -n 2 |tail -1`
           echo "$output:t"
           set rstrtyr = `echo $output:t | gawk '{print substr($0,12,4)}'`
           set rstrtmn = `echo $output:t | gawk '{print substr($0,17,2)}'`
           set rstrtdy = `echo $output:t | gawk '{print substr($0,20,2)}'`
           echo $rstrtyr, $rstrtmn, $rstrtdy

           cd $HOME/runscript
           $QSUBCMD $SCRIPNM -v RSTYEAR=$rstrtyr,RSTMNTH=$rstrtmn,RSTCDAY=$rstrtdy
           exit 124
           breaksw
       case 125:
           echo "timeout failure"
           exit 126
           breaksw
       case 126:
           echo "cannot exec command"
           exit 126
           breaksw
       case 127:
           echo "cannot find command"
           exit 126
           breaksw
       case 1:
           echo "CWRF run error, please check error file"
           exit 1
           breaksw
       default:
           echo $myst
           breaksw
    endsw

    set ENDTIM = `date +%s`

    @ DURTIM = $DURTIM + $ENDTIM / 60 - $BGNTIM / 60

    echo $DURTIM

    /bin/mv -f rsl.out.0000   rsl.out$TIMSTR
    /bin/mv -f rsl.error.0000 rsl.err$TIMSTR

    #+xum for safty reason, keep the first day rstfile
    #/bin/rm -f wrfrst_d01_${iyini}-${cmini}*
    /bin/rm -f `ls wrfrst_d01_${iyini}-${cmini}* | grep -v wrfrst_d01_${iyini}-${cmini}-01_00:00:00`
    echo $NPES
end

exit 0
