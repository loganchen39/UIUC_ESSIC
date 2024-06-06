#!/usr/bin/perl
$SY = $ARGV[0];
$SM = $ARGV[1];
$EY = $ARGV[2];
$EM = $ARGV[3];
die("Usage: $0 StartYYYY StartMM EndYYYY EndMM.\n") if(!$EM);

$url = "http://nomads.ncdc.noaa.gov/data/narr/";

for($y=$SY; $y<=$EY; $y++) {
	$m1 = ($y == $SY) ? $SM : 1;
	$m2 = ($y == $EY) ? $EM : 12;
	for($m=$m1; $m<=$m2; $m++) {
   		$ym = $y . sprintf("%02d", $m);
		$monthd = monthdays($y, $m);
		for($d=1; $d<=$monthd; $d++) {
			$ymd = $ym . sprintf("%02d", $d);
			for($h=0; $h<=21; $h+=3) {
				$ymdh = $ymd . "_" . sprintf("%02d", $h) . "00";
				$file = $url . "/$ym/$ymd/narr-a_221_" . $ymdh . "_000";
				$inv = $file . ".inv";
				$grb = $file . ".grb";
				$tmpsfc = "TMPsfc.$ymdh.grb";
				$tmp2m  = "TMP2m.$ymdh.grb";

				system("./get_inv.pl \"$inv\" | grep \":TMP:\" | grep \":sfc:\" | get_grib.pl \"$grb\" $tmpsfc");
				system("./get_inv.pl \"$inv\" | grep \":TMP:\" | grep \":2 m above gnd:\" | get_grib.pl \"$grb\" $tmp2m");
			}
		}
	}
}

sub monthdays($$) {
	my ($year, $month) = @_;
	%MonthTotalDays = ( 1 => 31,
   					    2 => 28,
   					    3 => 31,
   					    4 => 30,
   					    5 => 31,
   					    6 => 30,
   					    7 => 31,
   					    8 => 31,
   					    9 => 30,
   					   10 => 31,
   					   11 => 30,
   					   12 => 31);
	if ($month =~ /^0(\d)$/) { $month = $1; }
	return ($month == 2) ? $MonthTotalDays{$month} + isleap($year) : $MonthTotalDays{$month};
}

sub isleap($) {
	my ($y) = @_;
	return 1 if (( $y % 400 ) == 0 ); # 400's are leap
	return 0 if (( $y % 100 ) == 0 ); # Other centuries are not
	return 1 if (( $y % 4 ) == 0 );   # All other 4's are leap
	return 0;                         # Everything else is not
}

