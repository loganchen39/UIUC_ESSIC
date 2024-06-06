#!/usr/bin/python
# #!/usr/common/usg/dynamic_libs/usr/bin/python

#PBS -N CWPSV3_ERI_new_SBCs_2012

#PBS -q regular
#PBS -l mppwidth=1
#PBS -l mppnppn=1
#PBS -l walltime=36:00:00

#PBS -e CWPSV3_ERI_new_SBCs_2012.err
#PBS -o CWPSV3_ERI_new_SBCs_2012.out


import os
import glob
# import mymodule
import shutil
# import subprocess
import re
import sys
# from time import strftime
import time

# For NCEP Reanalysis II input data only. Not exactly.


# FILENAME: mymodule.py
import datetime

def juliand(datestr):  # datestr YYYYMMDDHH....
    year = int(datestr[0:4])
    mon  = int(datestr[4:6])
    day  = int(datestr[6:8])
    t    = time.mktime( (year, mon, day, 0, 0, 0, 0, 0, 0) )

    return str(time.gmtime(t)[7])

def timesplit(time_begin, time_end):
    timelist = []
    hourstep = []

    for i in range(0, 365*24*50):
        d = datetime.datetime(int(time_begin[0:4]), int(time_begin[4:6]), int(time_begin[6:8])  \
            , int(time_begin[8:10])) + datetime.timedelta(hours=i)
        dstr = d.strftime("%Y%m%d%H")

        if (int(time_begin) < int(dstr) < int(time_end)):
            if ((d.day==1) and (d.hour==0)):  # first day, hour of month
                timelist.append(dstr)
                hourstep.append(i)
        elif (int(dstr)==int(time_begin)):
            timelist.append(dstr)
            hourstep.append(i)
        elif (int(dstr)==int(time_end)):
            timelist.append(dstr)
            hourstep.append(i)
            break

    return (timelist, hourstep, juliand(time_begin))

def datelist(date_begin, date_end):
    dlist = []

    for i in range(-1, 365*50):
        d = datetime.datetime( int(date_begin[0:4]), int(date_begin[4:6])  \
            , int(date_begin[6:8]) ) + datetime.timedelta(days=i)
        dstr = d.strftime("%Y%m%d")

        if (int(dstr) <= int(date_end[0:8])):
            dlist.append(dstr)
        elif (int(dstr) > int(date_end[0:8])):
            break

    return (dlist)

def symlink(src, dst):
    if (os.path.exists(dst)):
        os.remove(dst)

    os.symlink(src,dst)

def sysecho(s):
    os.system("echo \"" + s + "\"")

# END OF FILENAME: mymodule.py


# lgchen(20100310): FOR link_grib.csh
def link_grib(dlist):
    # print len(dlist), dlist

    # alpha = [A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z]
    alpha = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N'  \
        , 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']
    i1    = 0
    i2    = 0
    i3    = 0

    if (1==len(dlist)) or (2==len(dlist) and "."==dlist[1]):
        os.system("rm -f GRIBFILE.??? >& /dev/null")

        for fn in glob.glob(dlist[0] + "*"):
            fn_gb = "GRIBFILE." + alpha[i3] + alpha[i2] + alpha[i1]
            os.system("ln -sf " + fn + " " + fn_gb)

            i1 += 1
            if i1 > 25:
                i1 = 0
                i2 = i2 + 1
                if i2 > 25:
                    i2 = 0
                    i3 += 1
                    if i3 > 25:
                        print "RAN OUT OF GRIB FILE SUFFIXES!"
                        os.system("exit")
    elif len(dlist) > 1:
        os.system("rm -f GRIBFILE.??? >& /dev/null")

        for fn in dlist:
            if "." != fn:
                fn_gb = "GRIBFILE." + alpha[i3] + alpha[i2] + alpha[i1]
                os.system("ln -sf " + fn + " " + fn_gb)

                i1 += 1
                if i1 > 25:
                    i1 = 0
                    i2 = i2 + 1
                    if i2 > 25:
                        i2 = 0
                        i3 += 1
                        if i3 > 25:
                            print "RAN OUT OF GRIB FILE SUFFIXES!"
                            os.system("exit")
    elif 0 == len(dlist):
        print "\n\nERROR: No grib data to link!"
        print "Please provide some GRIB data to link"
        os.system("exit")
        
# END OF link_grib.csh


# YYYYMMDDHH
time_begin = "2012090100"
# time_end   = "2012073100"
time_end   = "2012100100"
casename   = "ERI_new_SBCs_201209_20130402_1"

PreMet     = True 
PreNML     = True
PreReal    = True
PreJobCard = False

# Xing's setting
# SCPTSRC    = '/global/u1/x/xingyuan/CWPSV3_tiejun_20091223-1154_ser/user_scripts'
# # namelist.input namelist.wps.NCEP2 should be under SUBSSRC
# SUBSSRC    = SCPTSRC + '/sub_src'
# NMLSRC     = 'namelist.input.ECMWF'
# CWPSSRC    = '/global/u1/x/xingyuan/CWPSV3_tiejun_20091223-1154_ser/CWPSV3.1.1'
# NR2_dir    = '/scratch2/scratchdirs/xingyuan/CWRF-ERI/data'
# SST_dir    = '/scratch2/scratchdirs/xingyuan/SST'
# ZSB_dir    = '/global/u1/x/xingyuan/CWPSV3_tiejun_20091223-1154_ser/wrfzsb'
# VBS_dir    = '/global/u1/x/xingyuan/CWPSV3_tiejun_20091223-1154_ser/wrfcdf_v3.1'
# work_dir   = '/scratch2/scratchdirs/xingyuan/run/' + casename
# realexe    = '/scratch2/scratchdirs/xingyuan/run/real.exe'
# wrfexe     = '/scratch2/scratchdirs/xingyuan/run/wrf.exe'
# wrfsrc     = '/scratch2/scratchdirs/xingyuan/run/run_bak'

CWPS       = '/global/u1/l/lgchen/project/CWPSV3'
SCPTSRC    = CWPS + '/user_scripts'
# namelist.input namelist.wps.NCEP2 should be under SUBSSRC
SUBSSRC    = SCPTSRC + '/sub_src'
NMLSRC     = 'namelist.input.ECMWF'
CWPSSRC    = CWPS + '/CWPSV3.1.1'
ZSB_dir    = CWPS + '/wrfzsb'
VBS_dir    = CWPS + '/wrfcdf_v3.1'
DIR_STATIC = CWPS + '/static'

# NR2_dir  = '/global/scratch/sd/lgchen/data/ERI/1993'
# NR2_dir    = '/project/projectdirs/cwrf/data/ERI'
NR2_dir    = '/global/scratch/sd/lgchen/data/ERI/ln_2011_2012'
SST_dir    = '/global/scratch/sd/lgchen/data/OISST/2012'
work_dir   = '/global/scratch/sd/lgchen/data/CWPS_case/ERI/' + casename

# realexe  = '/global/scratch/sd/lgchen/projects/CWRFV3/CWRF_SVN_SER_1/CWRFV3.1.1/run/real.exe'
realexe    = '/global/u1/l/lgchen/project/CWRFV3/serial/CWRFV3.1.1/run/real.exe'
wrfexe     = '/project/projectdirs/cwrf/cwrf/run/wrf.exe'
wrfsrc     = '/global/u1/l/lgchen/project/CWPSV3/WRFV3'


os.chdir(SCPTSRC)
if not os.path.isdir(work_dir):
    os.mkdir(work_dir)

(timelist, hourstep, begin_julian) = timesplit(time_begin, time_end)

for i in range(0, len(timelist) - 1):
    if (PreMet) :
        print time.strftime("%Y-%m-%d %H:%M:%S") + " Prepare Met Files from " \
            + timelist[i] + " to " + timelist[i+1]

        os.chdir(work_dir)

        if (timelist[i] == time_begin) :
            symlink(CWPSSRC + "/ungrib/src/ungrib.exe"        , "ungrib.exe"   )
            symlink(CWPSSRC + "/metgrid/src/metgrid.exe"      , "metgrid.exe"  )
            symlink(CWPSSRC + "/util/src/mod_levs.exe"        , "mod_levs.exe" )
            symlink(CWPSSRC + "/metgrid/METGRID.TBL.ARW.NCEP2", "METGRID.TBL"  )
            symlink(DIR_STATIC + "/geo_em.d01.nc"             , "geo_em.d01.nc")      
            # shutil.copy2    (CWPSSRC + "/link_grib.csh"                , "link_grib.csh")      
            
        # shutil.copy2(NR2_dir + "/data_from_Yuan/static/Static", "Static"     )
        # shutil.copy2("/global/scratch/sd/lgchen/data/ERI/Static_perlDownload_Su", "Static"      )
        shutil.copy2(DIR_STATIC + '/soilhgt_lsm_eri', "Static"      )
        shutil.copy2(SUBSSRC + "/namelist.wps.ECMWF", "namelist.wps")

        f     = open("namelist.wps", "r")
        wpsnl = f.read()
        f.close()

        # change datetime
        wpsnl = re.sub("start_date.*?,", "start_date = '"
            + time.strftime("%Y-%m-%d_%H:%M:%S", time.strptime(timelist[i], "%Y%m%d%H"))
            + "',", wpsnl)
        wpsnl = re.sub("end_date.*?,", "end_date = '"
            + time.strftime("%Y-%m-%d_%H:%M:%S", time.strptime(timelist[i+1], "%Y%m%d%H"))
            + "',", wpsnl)

        # do 2D ungrib
        # symlink(CWPSSRC + "/ungrib/Variable_Tables/tmp/Vtable.ERA-interim.pl", "Vtable")
        symlink(CWPSSRC + "/ungrib/Variable_Tables/Vtable.ECMWF", "Vtable")
        wpsnl = re.sub("prefix.*"          , "prefix  = 'NR2_2D', "       , wpsnl)
        wpsnl = re.sub("interval_seconds.*", "interval_seconds  = 21600, ", wpsnl)

        f = open("namelist.wps", "w")
        f.write(wpsnl)
        f.close()

        dlist = datelist(timelist[i], timelist[i+1])
        flist = range(0, 4*(len(dlist)-2) + 2)
        k     = 0

        for j in range(0, len(dlist)):
            # dlist[j] = NR2_dir + "/SRF-" + dlist[j][0:6] + "* "
            # dlist[j] = NR2_dir + "/eri_2d_" + dlist[j][0:6] + "* "  # file per month
            if 0 == j:
                flist[k]   = NR2_dir + "/eri_2d_" + dlist[j] + "18.gr*b" + " "
                k += 1
            elif len(dlist)-1 == j:
                flist[k]   = NR2_dir + "/eri_2d_" + dlist[j] + "00.gr*b" + " "
                k += 1
            else:
                flist[k]   = NR2_dir + "/eri_2d_" + dlist[j] + "00.gr*b" + " "
                flist[k+1] = NR2_dir + "/eri_2d_" + dlist[j] + "06.gr*b" + " "
                flist[k+2] = NR2_dir + "/eri_2d_" + dlist[j] + "12.gr*b" + " "
                flist[k+3] = NR2_dir + "/eri_2d_" + dlist[j] + "18.gr*b" + " "
                k += 4

        # os.system("./link_grib.csh " + "".join(dlist))
        # link_grib(dlist)
        link_grib(flist)
        os.system("./ungrib.exe >&! /dev/null")
        # os.system("./ungrib.exe >&! ./ungrib_2d.txt")

        # sys.exit()

        # do SST ungrib
        symlink(CWPSSRC + "/ungrib/Variable_Tables/Vtable.SST", "Vtable")
        wpsnl = re.sub("prefix.*"          , "prefix  = 'SST', "          , wpsnl)
        wpsnl = re.sub("interval_seconds.*", "interval_seconds  = 86400, ", wpsnl)

        f = open("namelist.wps", "w")
        f.write(wpsnl)
        f.close()

        dlist = datelist(timelist[i], timelist[i+1])
        for j in range(0, len(dlist)):
            # dlist[j] = SST_dir + "/" + dlist[j][0:4] + "/" + dlist[j] + ".grb" + " "
            dlist[j] = SST_dir + "/" + dlist[j] + ".grb" + " "
        # os.system("./link_grib.csh " + "".join(dlist))
        link_grib(dlist)
        os.system("./ungrib.exe >&! /dev/null")
        # os.system("./ungrib.exe >&! ./ungrib_sst.txt")

        # do 3D ungrib
        # symlink(CWPSSRC + "/ungrib/Variable_Tables/tmp/Vtable.ERA-interim.pl", "Vtable")
        symlink(CWPSSRC + "/ungrib/Variable_Tables/Vtable.ECMWF", "Vtable")
        wpsnl = re.sub("prefix.*"          , "prefix  = 'NR2_3D', "       , wpsnl)
        wpsnl = re.sub("interval_seconds.*", "interval_seconds  = 21600, ", wpsnl)

        f = open("namelist.wps", "w")
        f.write(wpsnl)
        f.close()

        dlist = datelist(timelist[i], timelist[i+1])
        k     = 0
        for j in range(0, len(dlist)):
            # dlist[j] = NR2_dir + "/ATM-" + dlist[j][0:6] + "* "
            # dlist[j] = NR2_dir + "/eri_3d_" + dlist[j][0:6] + "* "
            if 0 == j:
                flist[k]   = NR2_dir + "/eri_3d_" + dlist[j] + "18.gr*b" + " "
                k += 1
            elif len(dlist)-1 == j:
                flist[k]   = NR2_dir + "/eri_3d_" + dlist[j] + "00.gr*b" + " "
                k += 1
            else:
                flist[k]   = NR2_dir + "/eri_3d_" + dlist[j] + "00.gr*b" + " "
                flist[k+1] = NR2_dir + "/eri_3d_" + dlist[j] + "06.gr*b" + " "
                flist[k+2] = NR2_dir + "/eri_3d_" + dlist[j] + "12.gr*b" + " "
                flist[k+3] = NR2_dir + "/eri_3d_" + dlist[j] + "18.gr*b" + " "
                k += 4
 
        # link_grib(dlist) 
        link_grib(flist) 
        os.system("./ungrib.exe >&! /dev/null")
        # os.system("./ungrib.exe >&! ./ungrib_3d.txt")

        # sys.exit()

        # filter data
        for j in glob.glob("NR2_3D*"):
            os.system("./mod_levs.exe " + j + " new_" + j)

        os.system("./metgrid.exe >&! /dev/null")
        # os.system("./metgrid.exe >&! ./metgrid.output.log")
        # sys.exit()

        # temporary commented:
        if (os.path.exists("met_em.d01." 
            + time.strftime("%Y-%m-%d_%H", time.strptime(timelist[i+1], "%Y%m%d%H"))
            + ":00:00.nc")):
            for ungrbfile in glob.glob("*NR2_*") + glob.glob("GRIB*") + glob.glob("SST*"):
                os.remove(ungrbfile)
        else:
            print "Prepare Met Files ERROR !!!!!!!!!!!!!!!!!!!!"
            sys.exit()

    if (PreReal or PreNML):
        print time.strftime("%Y-%m-%d %H:%M:%S") + " Prepare REAL Files from "  \
            + timelist[i] + " to " + timelist[i+1]

        os.chdir(work_dir)

        # shutil.copy2(SUBSSRC + "/" + NMLSRC, "namelist.input")
        shutil.copy2(SUBSSRC + "/namelist.input.ECMWF", "namelist.input")

        f     = open("namelist.input", "r")
        wrfnl = f.read()
        f.close()

        wrfnl = re.sub("start_year .*?," , "start_year                          = "
            + time.strftime("%Y", time.strptime(timelist[i], "%Y%m%d%H")) + ",", wrfnl)
        wrfnl = re.sub("start_month .*?,", "start_month                         = "
            + time.strftime("%m", time.strptime(timelist[i], "%Y%m%d%H")) + ",", wrfnl)
        wrfnl = re.sub("start_day  .*?," , "start_day                           = "
            + time.strftime("%d", time.strptime(timelist[i], "%Y%m%d%H")) + ",", wrfnl)
        wrfnl = re.sub("start_hour .*?," , "start_hour                          = "
            + time.strftime("%H", time.strptime(timelist[i], "%Y%m%d%H")) + ",", wrfnl)
        wrfnl = re.sub("end_year .*?,"   , "end_year                            = "
            + time.strftime("%Y", time.strptime(timelist[i+1], "%Y%m%d%H")) + ",", wrfnl)
        wrfnl = re.sub("end_month .*?,"  , "end_month                           = "
            + time.strftime("%m", time.strptime(timelist[i+1], "%Y%m%d%H")) + ",", wrfnl)
        wrfnl = re.sub("end_day  .*?,"   , "end_day                             = "
            + time.strftime("%d", time.strptime(timelist[i+1], "%Y%m%d%H")) + ",", wrfnl)
        wrfnl = re.sub("end_hour .*?,"   , "end_hour                            = "
            + time.strftime("%H", time.strptime(timelist[i+1], "%Y%m%d%H")) + ",", wrfnl)
        wrfnl = re.sub("julyr .*?,"      , "julyr                               = "
            + time.strftime("%Y", time.strptime(timelist[i], "%Y%m%d%H")) + ",", wrfnl)
        wrfnl = re.sub("julday .*?,"     , "julday                              = "
            + time.strftime("%j", time.strptime(timelist[i], "%Y%m%d%H")) + ",", wrfnl)

        if (time_begin == timelist[i]):  # 1st month
            wrfnl = re.sub(" restart  .*?,", " restart                             = .false.,", wrfnl)
        else:
            wrfnl = re.sub(" restart  .*?,", " restart                             = .true.," , wrfnl)

        f = open("namelist.input", "w")
        f.write(wrfnl)
        f.close()

        shutil.copy2("namelist.input", "namelist.input." + timelist[i])

        if (PreReal):
            symlink(realexe, "real.exe")
            os.system("./real.exe >&! /dev/null")
            # os.system("./real.exe >&! ./real.log")

            # set vbs
            if (timelist[i] == time_begin):
                if not os.path.isdir("sbcs"):
                    os.mkdir("sbcs")
                for sbc in os.listdir(VBS_dir + "/sbcs"):
                    if not os.path.isdir(VBS_dir + "/sbcs/" + sbc):
                        shutil.copy2(VBS_dir + "/sbcs/" + sbc, "sbcs/" + sbc)
                symlink(VBS_dir + "/vbs.re.exe", "vbs.re.exe")

            f = open("tempin", "w")
            f.write(time.strftime("%Y %m %d", time.strptime(timelist[i]  , "%Y%m%d%H")) + "\n")
            f.write(time.strftime("%Y %m %d", time.strptime(timelist[i+1], "%Y%m%d%H")) + "\n")
            f.write(" " + "\n")
            f.write(" " + "\n")
            f.close()

            os.system("./vbs.re.exe < tempin >&! /dev/null")
            # os.system("./vbs.re.exe < tempin >&! ./vbs.re.log")

            # bkup
            os.chdir(work_dir)
            realout = glob.glob("wrf*_d01")
            for tmpfile in realout:
                shutil.move(tmpfile, tmpfile + "." + timelist[i])

            # mv met_Files
            if not os.path.isdir(work_dir + "/bk_met_files"):
                os.mkdir(work_dir + "/bk_met_files")
            for tmpfile in glob.glob("met_em.d01.*"):
                shutil.move(tmpfile, work_dir + "/bk_met_files/" + tmpfile)

    if ( PreJobCard ):
        print time.strftime("%Y-%m-%d %H:%M:%S") + " Prepare WRF Files from "  \
            + timelist[i] + " to " + timelist[i+1]

        os.chdir(work_dir)

        if ( not os.path.exists("namelist.input." + timelist[i])) :
            shutil.copy2(SUBSSRC + "/namelist.input", "namelist.input")

            f     = open("namelist.input", "r")
            wrfnl = f.read()
            f.close()

            wrfnl = re.sub("start_year .*?," , "start_year                          = "
                + time.strftime("%Y", time.strptime(timelist[i], "%Y%m%d%H")) + ",", wrfnl)
            wrfnl = re.sub("start_month .*?,", "start_month                         = "
                + time.strftime("%m", time.strptime(timelist[i], "%Y%m%d%H")) + ",", wrfnl)
            wrfnl = re.sub("start_day  .*?," , "start_day                           = "
                + time.strftime("%d", time.strptime(timelist[i], "%Y%m%d%H")) + ",", wrfnl)
            wrfnl = re.sub("start_hour .*?," , "start_hour                          = "
                + time.strftime("%H", time.strptime(timelist[i], "%Y%m%d%H")) + ",", wrfnl)
            wrfnl = re.sub("end_year .*?,"   , "end_year                            = "
                + time.strftime("%Y", time.strptime(timelist[i+1], "%Y%m%d%H")) + ",", wrfnl)
            wrfnl = re.sub("end_month .*?,"  , "end_month                           = "
                + time.strftime("%m", time.strptime(timelist[i+1], "%Y%m%d%H")) + ",", wrfnl)
            wrfnl = re.sub("end_day  .*?,"   , "end_day                             = "
                + time.strftime("%d", time.strptime(timelist[i+1], "%Y%m%d%H")) + ",", wrfnl)
            wrfnl = re.sub("end_hour .*?,"   , "end_hour                            = "
                + time.strftime("%H", time.strptime(timelist[i+1], "%Y%m%d%H")) + ",", wrfnl)

            if (time_begin == timelist[i]):  # 1st month
                wrfnl = re.sub(" restart  .*?,", " restart                             = .false.,", wrfnl )
            else:
                wrfnl = re.sub(" restart  .*?,", " restart                             = .true.," , wrfnl )

            f = open("namelist.input", "w")
            f.write(wrfnl)
            f.close()
            shutil.copy2("namelist.input", "namelist.input." + timelist[i])

        f       = open(SUBSSRC + "/job.card", "r")
        jobcard = f.read()
        f.close()

        jobcard = jobcard.replace("[casetime]"       , casename + timelist[i])
        jobcard = jobcard.replace("[work_dir]"       , work_dir)
        jobcard = jobcard.replace("[timestring]"     , timelist[i])
        jobcard = jobcard.replace("[timestringyear]" , timelist[i][0:4])
        jobcard = jobcard.replace("[wrfrst_lasttime]", "wrfrst_d01_"
            + time.strftime("%Y-%m-%d_%H", time.strptime(timelist[i+1], "%Y%m%d%H"))
            + ":00:00")
        jobcard = jobcard.replace("[next_job_card]", "JOB." + timelist[i+1])

        if (timelist[i+1] == time_end):
            jobcard = jobcard.replace("[runnext]", "#")
        else:
            jobcard = jobcard.replace("[runnext]", " ")

        f = open("JOB." + timelist[i], "w")
        f.write(jobcard)
        f.close()

        symlink(wrfexe, "wrf.exe")

        f = open(SUBSSRC + "/wrfrunfiles", "r")
        files = f.read()
        f.close()

        for tmpfile in files.split("\n"):
            s = tmpfile.strip()
            if (s != ""):
                symlink(wrfsrc + "/" + s, s)
