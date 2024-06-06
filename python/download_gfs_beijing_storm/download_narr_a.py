#!/usr/bin/python

import os
import sys
import shutil
import glob
import re
import datetime  
# import time
# import str

DATETIME_START = datetime.datetime(1987, 11, 30, 0 )
DATETIME_END   = datetime.datetime(1988, 2 , 29, 21)
TIMEDELTA_NARR = datetime.timedelta(0, 3*60*60)

URL_ROOT = "http://nomads.ncdc.noaa.gov/data/narr"
DATA_DIR = '/nas/lgchen/data/narr_a/1988'

os.chdir(DATA_DIR)


datetime_iter = DATETIME_START
while (datetime_iter <= DATETIME_END):
    str_dt   = datetime_iter.strftime('%Y%m%d%H')
    url_file = URL_ROOT + '/' + str_dt[0:6] + '/' + str_dt[0:8] + '/' + 'narr-a_221_'  \
        + str_dt[0:8] + '_' + str_dt[8:10] + "00_000.grb"
    
    os.system('wget ' + url_file) 

    datetime_iter = datetime_iter + TIMEDELTA_NARR
