#!/usr/bin/perl

print "This script will change year ONLY, will keep month, date, time as it is.\n\n";

die("Usage: $0 new_YYYY file.grb.\n") if(!$ARGV[1]);

if($ARGV[0] =~/^(\d{4})$/) {
	$year = $1;
} else {
	die("Wrong YYYY format.\n");
}
$file = $ARGV[1];

$wgrib = "wgrib -s -ncep_opn";
die("File $file not exists.\n") if(!-e $file);
@head = split("\n",`$wgrib -h $file`);
$n_record = 0; my %record_time;
foreach $line (@head) {
	if($line =~ /^(\d+):(\d+):d=(\d+):.*/i) {
		$n_record ++;
		$record_time{$3} = 1;
	}
}
$time_str = "";
foreach $t (sort keys %record_time) { $time_str .= $t; }
if($time_str =~ /^(\d{2})(\d{2})(\d{2})(\d{2})$/) {
	$oy = $1; $month = $2; $date = $3; $hour = $4;
} else {
	print "Unknow time record of file $file: $time_str.\n";
	exit;
}

$newfile = $file;
$newfile =~s/19$time_str/$year$month$date$hour/i;
print "Total $n_record found in file $file, Month=$month, Date=$date; Hour=$hour, Year=$oy--->$year, ($newfile)\n";

$tmpfile = "cdo.tmp.grb";
unlink $tmpfile if(-e $tmpfile);
$cmd = "cdo -s setyear,$year $file $tmpfile";
system($cmd);
$cmd = "cdo -s settime,$hour:00 $tmpfile $newfile";
system($cmd);
unlink $tmpfile if(-e $tmpfile);

