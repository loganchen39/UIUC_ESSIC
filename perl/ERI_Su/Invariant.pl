#!/usr/bin/perl
use ECMWF::DataServer;
require "/global/u2/s/shenjian/software/perl/functions.pl";

my $client = ECMWF::DataServer->new(
	portal => 'http://data-portal.ecmwf.int/data/d/dataserver/',
	token  => 'fc8baf26d637a089e4ffcda516cf7d9f',
	email  => 'zfsu79@illinois.edu',
);


$filename = "eri_invariant.grb";

print "Retrieving ERI Invariant data, will save to file $filename ...\n";
$client->retrieve( 
	grid	=> "1.5/1.5",
	time	=> "12:00:00",
	date    => "1989-01-01",
	stream	=> "oper",
	dataset	=> "interim_invariant",
	step	=> "0",
	levtype	=> "sfc",
	type	=> "an",
	class	=> "ei",
	param	=> "27.128/28.128/29.128/30.128/74.128/129.128/160.128/161.128/162.128/163.128/172.128",
	target  => "$filename",
);

