#!/usr/bin/perl -w
# Min Xu 

# read the narr data and save them to the file
  use strict;
  use Cwd;

  ### my $narr_web='http://nomads.ncdc.noaa.gov/data/narr';
  ### my $narr_hea='narr-a_221_';
  ### my $narr_tai='00_000.grb';

  my $narr_web='http://nomads.ncdc.noaa.gov/data/narr';
  my $narr_hea='narr-a_221_'; #'./grbdata/';
  my $narr_tai='00_000.grb';
  my $narr_iinv='00_000.inv';

  my @edys=(0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);

  my @vars=( 'PRMSL:MSL');
  my $narr_inv = "";
###  my @vars=('DSWRF:sfc', 'DLWRF:sfc', 'USWRF:sfc', 'ULWRF:sfc', 'TMP:sfc', 
###            'PRES:sfc', 'APCP:sfc', 'LHTFL:sfc', 'SHTFL:sfc', 'GFLUX:sfc',
###            'SPFH:2 m', 'TMP:2 m', 'UGRD:10 m', 'VGRD:10 m', 
###            'LCDC:low', 'MCDC:mid', 'HCDC:high', 'TCDC:atmos', 'CLWMR');


  my $iyini = 2004; my $iyend = 2004;
  my $imini = 4;    my $imend = 10;

  my $narr_met='/u/ac/minxu/scratch-global/narr_oml';
  my $narr_fil; 
  my $narr_bin;

  my $iy; my $im; my $id; my $ih;
  my $cy; my $cm; my $cd; my $ch;

  my $dir = getcwd ;


  $ENV{'GRIBTAB'} = '/u/ac/minxu/bin/nceptab_131';

  for ($iy = $iyini; $iy <= $iyend; $iy++)
  {
     $cy = "$iy";
     for ($im = $imini; $im <= $imend; $im = $im+1)
     {
        $cm       = sprintf("%02d", $im);
        $narr_bin = "$narr_hea$cy$cm\_bin";
		for ($id = 1; $id <= $edys[$im]; $id++)
		###for ($id = $edys[$im]; $id <= $edys[$im]; $id++)
        {
            $cd = sprintf("%02d", $id);

            for ($ih = 0; $ih < 24; $ih = $ih+3)
            {
               $ch       = sprintf("%02d", $ih);
               $narr_fil = "$narr_hea$cy$cm$cd\_$ch$narr_tai";
			   $narr_inv = "$narr_hea$cy$cm$cd\_$ch$narr_iinv";
	
	       if (-e "$dir/stop_sign"  )
	       { 
		  print "Must stop here!\n";
	          exit;
	       }
               # wget
			   			   
			   #system( "./get_inv.pl $narr_web/$iy$cm/$iy$cm$cd/$narr_inv | grep -f greplst | get_grib.pl $narr_web/$iy$cm/$iy$cm$cd/$narr_fil $narr_fil");
			   system( "./get_inv.pl $narr_web/$iy$cm/$iy$cm$cd/$narr_inv | grep -i 'PRMSL:MSL' | get_grib.pl $narr_web/$iy$cm/$iy$cm$cd/$narr_fil $narr_fil");
#	           system( "wget -c $narr_web/$iy$cm/$iy$cm$cd/$narr_fil" ) == 0 or die "wget \n";
			   ## my $var;
               ## my $ofl;
               ## foreach $var (@vars)
               ## {
               ##   $ofl=$var;
               ##   $ofl=~s/\s/_/g;
               ##   print "$ofl \n";
		 	   ##   print "wgrib -s $narr_fil | grep -i \'$var\' | wgrib -nh -bin -i -append -o $ofl.bin $narr_fil";
               ##   system("wgrib -s $narr_fil | grep -i \'$var\' | wgrib -nh -bin -i -append -o $ofl.bin $narr_fil") == 0 
               ##                  or "die in system";
               ## }

               ## print  "INTERP -ini $cy-$cm-$cd\_$ch:00:00 -inv 3h <nmli.inp \n";
               ## system("INTERP -ini $cy-$cm-$cd\_$ch:00:00 -inv 3h <nmli.inp") == 0 || die "error in interp";
   ###	       ##     unlink $narr_fil;
               ## system("rm -f *.bin") == 0 || die "erroe in rm\n";
            }
        }
     } 
     # system("msscmd cd NARR/BUOYS, mput '*narr.dat'") ==0 || die "error in cmd\n";
  }
