#!/bin/sh

ifort -free -O -convert big_endian done_dir2file_zjh.F ~/lib/libc/subcom_lib.o -o done_dir2file_zjh.exe

ifort -free -O -I. -convert big_endian regrid2dir.F -o regrid2dir.exe

ifort -free -O -convert big_endian done.cut.F ~/lib/libc/subcom_lib.o -o done.cut.exe
