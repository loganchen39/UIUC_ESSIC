#!/bin/bash
set -x
for y in 1979
do
   for m in 01 02 # 03 04 05 06 07 08 09 10 11 12
   do
      for head in pgb flx.ft06
      do
         cdo splitday NCEPRII/$head.$y$m $head.d.$y$m
      done
   done
done

