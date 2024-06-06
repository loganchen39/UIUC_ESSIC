#!/usr/bin/perl -Ipath_to_where_ECMWF::DataServer_is_installed
use ECMWF::DataServer;
require "/global/u2/s/shenjian/software/perl/functions.pl";

my $client = ECMWF::DataServer->new(
	portal => 'http://data-portal.ecmwf.int/data/d/dataserver/',
	token  => 'fc8baf26d637a089e4ffcda516cf7d9f',
	email  => 'zfsu79@illinois.edu',
);


$sy = 1989; $ey = 2009;
for($y=$sy; $y<=$ey; $y++) {
	for($m=1; $m<=12; $m++) {
		$date = "";
		for($d=1; $d<=monthdays($y, $m); $d++) {
			$date .= sprintf("%4d-%02d-%02d/", $y, $m, $d);
		}
		chop($date);
		$filename = "eri_2d_" . sprintf("%4d%02d", $y, $m) . ".grb";

		print "Retrieving ERI 2D data of $y-$m, will save to file $filename ...\n";
		$client->retrieve( 
			grid	=> "1.5/1.5",
			time	=> "00:00:00/06:00:00/12:00:00/18:00:00",
			date	=> "$date",
			stream	=> "oper",
			dataset	=> "interim_daily",
			step	=> "0",
			levtype	=> "sfc",
			type	=> "an",
			class	=> "ei",
			param	=> "165.128/166.128/167.128/168.128/134.128/151.128/235.128/31.128/34.128/141.128/39.128/40.128/41.128/42.128/139.128/170.128/183.128/236.128",
			target  => "$filename",

		);
	}
}

