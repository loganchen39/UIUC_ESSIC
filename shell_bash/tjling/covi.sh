#!/bin/bash

dmpi=/mnt/tg2/projects/ciaqex/tiejun/cwrf31/mpi/cwrf_src
sing=/mnt/tg2/projects/ciaqex/tiejun/cwrf31/single/cwrf_src

f=$1
if diff $dmpi/$f $sing
then
cp $dmpi/$f ./a.f90

vim a.f90

cp a.f90 $dmpi/$f
cp a.f90 $sing/$f
cp a.f90 src/$f.`date +%Y%m%d_%H%M`
else

echo "$f are not the same one under mpi and single"
fi
