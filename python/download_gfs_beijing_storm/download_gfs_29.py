#!/usr/bin/python

import os
import sys
import shutil
import glob
import re
import datetime  
# import time
# import str

DATETIME_START = datetime.datetime(2012, 7, 2, 0)
DATETIME_END   = datetime.datetime(2012, 7, 2, 0)
TIMEDELTA_NARR = datetime.timedelta(0, 24*60*60)

URL_ROOT = "http://nomads.ncdc.noaa.gov/data/gfs4/201207/"
DATA_DIR = '/global/scratch/sd/lgchen/data/GFS_4/20120702'

os.chdir(DATA_DIR)


datetime_iter = DATETIME_START
while (datetime_iter <= DATETIME_END):
    str_dt  = datetime_iter.strftime('%Y%m%d%H')
    dir_url = URL_ROOT + '/' + str_dt[0:8] + '/'
    # url_file = URL_ROOT + '/' + str_dt[0:6] + '/' + str_dt[0:8] + '/' + 'narr-a_221_'  \
    #     + str_dt[0:8] + '_' + str_dt[8:10] + "00_000.grb"
    
    os.system('wget -r -nd -np -e robots=off -A * ' + dir_url)

    datetime_iter = datetime_iter + TIMEDELTA_NARR
