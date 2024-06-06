#!/usr/bin/perl
@MaxDays = (0, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);

for($m=1; $m<=12; $m++) {
	$cm = ($m < 10) ? "0" . $m : $m;
	$MaxD = $MaxDays[$m];

	for($d=1; $d<=$MaxD; $d++) {
		$cd = ($d < 10) ? "0" . $d : $d;

		for($h=0; $h<=21; $h=$h+3) {
			$ch = ($h < 10) ? "0" . $h : $h;
	
			if($h == 0) {

				$path = "http://nomads.ncdc.noaa.gov/data/narr/2000" . $cm . "/2000" . $cm . $cd . "/narr-a_221_2000" . $cm . $cd . "_0000_fff.idx";
				system("wget \"$path\"");

				$path = "http://nomads.ncdc.noaa.gov/data/narr/2000" . $cm . "/2000" . $cm . $cd . "/narr-a_221_2000" . $cm . $cd . "_". $ch . "00_000.ctl";
				system("wget \"$path\"");
			}
			$path = "http://nomads.ncdc.noaa.gov/data/narr/2000" . $cm . "/2000" . $cm . $cd . "/narr-a_221_2000" . $cm . $cd . "_". $ch . "00_000.grb";
			system("wget \"$path\"");

			$path = "http://nomads.ncdc.noaa.gov/data/narr/2000" . $cm . "/2000" . $cm . $cd . "/narr-a_221_2000" . $cm . $cd . "_". $ch . "00_000.inv";
			system("wget \"$path\"");
		}
	}
}
