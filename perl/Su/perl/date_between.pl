#!/usr/bin/perl

require $ENV{'HOME'} . "/software/perl/functions.pl";
$sy = $ARGV[0];
$sm = $ARGV[1];
$sd = $ARGV[2];
$ey = $ARGV[3];
$em = $ARGV[4];
$ed = $ARGV[5];

print "Set $sy-$sm-$sd as the 1st day, $ey-$em-$ed will be the ";
print date_between($sy,$sm, $sd, $ey, $em, $ed);
print " day\n";
