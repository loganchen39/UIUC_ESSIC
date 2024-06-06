#!/usr/bin/perl
$SY = $ARGV[0];
$SM = $ARGV[1];
$EY = $ARGV[2];
$EM = $ARGV[3];
die("Usage: $0 StartYYYY StartMM EndYYYY EndMM.\n") if(!$EM);

$url = "http://nomad3.ncep.noaa.gov/pub/reanalysis-2/6hr/";

for($y=$SY; $y<=$EY; $y++) {
	$m1 = ($y == $SY) ? $SM : 1;
	$m2 = ($y == $EY) ? $EM : 12;
        for($m=$m1; $m<=$m2; $m++) {
                $ym = $y . sprintf("%02d", $m);
                $pgb = $url . "/pgb/pgb." . $ym;
                $flx = $url . "/flx/flx.ft06." . $ym;
                system("wget $pgb");
                system("wget $flx");
        }
}

