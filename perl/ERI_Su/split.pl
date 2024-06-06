#!/usr/bin/perl
require "/global/homes/s/shenjian/software/perl/functions.pl";

for($w=2;$w<=3;$w++){
	for($y=1989; $y<=2009; $y++) {
		for($m=1; $m<=12; $m++){
			$f = sprintf("eri_%dd_%4d%02d", $w, $y, $m);
			print "Working on file $f ...\n";
			system("cdo splitday $f.grb $f");
	
			for($d=1; $d<=monthdays($y,$m); $d++) {
				$fd = $f . sprintf("%02d", $d);
				system("cdo splithour $fd.grb $fd");
				unlink("$fd.grb");
			}
		}
	}
}
