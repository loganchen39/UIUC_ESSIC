#!/usr/bin/perl
require $ENV{'HOME'} . "/software/perl/functions.pl";

$dir = $ARGV[0];
$pat = $ARGV[1];
$sy0 = $ARGV[2];
$sm0 = $ARGV[3];
$sd0 = $ARGV[4];
$ey0 = $ARGV[5];
$em0 = $ARGV[6];
$ed0 = $ARGV[7];

die("Usage: $0 DIR PATTERN YYYY MM DD YYYY MM DD\n") if(!$ed0);

die("$dir not exists or not a directory.\n") if(!(-e $dir && -d $dir));

for($y=$sy0; $y<=$ey0; $y++) {
	$sm = ($y == $sy0) ? $sm0 : 1;
	$em = ($y == $ey0) ? $em0 : 12;
	for($m=$sm; $m<=$em; $m++) {
		$sd = ($y == $sy0 && $m == $sm0) ? $sd0 : 1;
		$ed = ($y == $ey0 && $m == $em0) ? $ed0 : monthdays($y, $m);

		$cm = sprintf("%02d", $m);
		for($d=$sd; $d<=$ed; $d++) {
			$cd = sprintf("%02d", $d);

			$file = $pat;
			$file =~s/YYYY/$y/g;
			$file =~s/MM/$cm/g;
			$file =~s/DD/$cd/g;

			if(!-e "$dir/$file") {
				print "File $dir/$file missing !!!\n";
				next;
			}
			if(-z "$dir/$file") {
				print "File $dir/$file size = 0 !!!\n";
				next;
			}
		}
	}
}
