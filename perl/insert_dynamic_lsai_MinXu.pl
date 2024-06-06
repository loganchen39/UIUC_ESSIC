#!/usr/bin/perl -w

# Min Xu
# ESSIC
# 2011/02/08


  use strict;

  # my @years = (1988, 1993);
  my @years = (1988);
  my @mnths = (1..12);
  # my @mnths = (1..1);

  my $cmdpp = 'qsub CWRFPREP_1988.ser.2Vtable_new.py';

  my $sbcdir = '/global/scratch/sd/lgchen/projects/CWPSV3_tiejun_20091223-1154_ser_v4/wrfcdf_v3.1/sbcs/';
  my $laidir = '/global/scratch/sd/lgchen/projects/CWPSV3_tiejun_20091223-1154_ser_v4/minxu/lai_sai/';


  my $xlaifn = 'lgv_scl2m_YYYYMM_195x138.dat';
  my $claifn = 'lai';

  my $xsaifn = 'sai_scl2m_YYYYMM_195x138.dat';
  my $csaifn = 'sai';

  my ($iy, $im, $cm, $fnxlai, $fnxsai);


  foreach $iy (@years)
  {

      foreach $im (@mnths)
      {

         $cm = sprintf("%02d", $im); 

         $fnxlai = $xlaifn;
         $fnxlai =~ s/YYYY/$iy/;
         $fnxlai =~ s/MM/$cm/;

         $fnxsai = $xsaifn;
         $fnxsai =~ s/YYYY/$iy/;
         $fnxsai =~ s/MM/$cm/;

         print $fnxlai, '-', $fnxsai, "\n";

         # remove the files
         unlink "$sbcdir$claifn$cm";
         unlink "$sbcdir$csaifn$cm";

         # create the symbolic link
         system ("repnan.exe $laidir$fnxlai");
         system ("repnan.exe $laidir$fnxsai");

         symlink "$laidir$fnxlai","$sbcdir$claifn$cm";
         symlink "$laidir$fnxsai","$sbcdir$csaifn$cm";

      }

      system($cmdpp);
  }
  print @mnths, 'xxx', @years
