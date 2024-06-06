#!/bin/bash

dirmpi=/mnt/tg2/projects/ciaqex/tiejun/cwrf31/mpi/cwrf_src
dirsing=/home/tiejun/disk/cwrf31/SVN/CWRF_SVN/cwrf_src

# ls $dirmpi > mpifiles
# ls $dirsing > sinfiles

if diff mpifiles sinfiles
then
  echo "No of files is same. check if content of every file are different!"
  for i in `cat mpifiles`
  do
    if [[ "$i" != "log" && "$i" != "inputFile_2_linkfile_4_CWRF.out" && "$i" != "inputFile_2_linkfile_4_CWRF_wjet" ]]
    then
      if diff $dirmpi/$i $dirsing > /dev/null
      then
        #echo $dirmpi/$i is same with $dirsing/$i
	continue
      else
        echo "========================================================================================"
        echo $dirmpi/$i is not same with $dirsing/$i
        ls -l $dirmpi/$i $dirsing/$i
      fi
    fi
  done
else
  echo "The files' no or names are different!"
fi
