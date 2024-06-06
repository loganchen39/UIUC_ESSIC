#!/usr/bin/perl

require $ENV{'HOME'} . "/software/perl/functions.pl";
$y = $ARGV[0];
$n = $ARGV[1];

print "The $n th day of year $y is: \n";
my %r = doy2date($y, $n);
print "Year=" . $r{'year'} . "\tMonth=" . $r{'month'} . "\tDay=" . $r{'day'} . "\n\n";
