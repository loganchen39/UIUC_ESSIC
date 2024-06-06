Tool to check CWRF result
Su Shenjian

I wrote a Perl script to check CWRF output:
File: /nas/lv10/cwrf/zfsu/check_result.pl on server Climate
Usage: check_result.pl NetCDF_Data_File
Notice:
1. Based on GrADS, so you have to get GrADS (and X) ready.
2. Tested on Climate and ABE (on Climate, need to change line 4 to: $grads="gradsnc";
