#!/bin/bash

dirmpi=/mnt/tg2/projects/ciaqex/tiejun/cwrf31/mpi/cwrf_src
dirsing=/mnt/tg2/projects/ciaqex/tiejun/cwrf31/single/cwrf_src

f=$1
f1=$dirmpi/$f
f2=$dirsing/$f

if [ $f1 -nt $f2 ]
then
   echo $f1 is newer than $f2
   echo "cp $f1 $f2"
   cp $f1 $f2
else
   echo $f1 is older than $f2
   echo "cp $f2 $f1"
   cp $f2 $f1
fi
