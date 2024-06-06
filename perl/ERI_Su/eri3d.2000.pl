#!/usr/bin/perl -Ipath_to_where_ECMWF::DataServer_is_installed
use ECMWF::DataServer;
require "/global/u2/s/shenjian/software/perl/functions.pl";

my $client = ECMWF::DataServer->new(
	portal => 'http://data-portal.ecmwf.int/data/d/dataserver/',
	token  => 'fc8baf26d637a089e4ffcda516cf7d9f',
	email  => 'zfsu79@illinois.edu',
);


$sy = 2000; $ey = 2009;
for($y=$sy; $y<=$ey; $y++) {
	for($m=1; $m<=12; $m++) {
		$date = "";
		for($d=1; $d<=monthdays($y, $m); $d++) {
			$date .= sprintf("%4d-%02d-%02d/", $y, $m, $d);
		}
		chop($date);
		$filename = "eri_3d_" . sprintf("%4d%02d", $y, $m) . ".grb";

		print "Retrieving ERI 3D data of $y-$m, will save to file $filename ...\n";
		$client->retrieve( 
			grid	=> "1.5/1.5",
			time	=> "00:00:00/06:00:00/12:00:00/18:00:00",
			date    => "$date",
			stream	=> "oper",
			dataset	=> "interim_daily",
			step	=> "0",
			levtype	=> "pl",
			type	=> "an",
			class	=> "ei",
			param	=> "129.128/130.128/131.128/132.128/157.128",
			levelist=> "1/2/3/5/7/10/20/30/50/70/100/125/150/175/200/225/250/300/350/400/450/500/550/600/650/700/750/775/800/825/850/875/900/925/950/975/1000",
			target  => "$filename",
		);
	}
}

