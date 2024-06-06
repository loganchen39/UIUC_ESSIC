#!/usr/bin/perl

$dirs = $ARGV[0];
die("Usage $0 directories.\n\t* and ? can be used in 'directories'\n\te.g: $0 '/path/to/ccs*'\n") if(!$dirs);

if($dirs =~ /^(.*)\/([^\/]*)$/) {
	$parentdir = $1;
	$subdirs   = $2;
} else {
	$parentdir = "./";
	$subdirs   = $dirs;
}
$subdirs=~s/\*/\.\*/g;
$subdirs=~s/\?/\./g;
$ls = `/bin/ls -1 $parentdir`;
@alldirs = split("\n", $ls);
$total = 0;
$valid = 0;
%failed;
foreach $dir (sort @alldirs) {
	next if($dir !~ /$subdirs/i);
	$total ++;
	$logfilels = `ls -1t $parentdir/$dir/log.*`;
	@logfiles  = split("\n", $logfilels);
	$logfile_tn = @logfiles;
	$logfile_n = 0;
	$logfile = $logfiles[$logfile_n];
	while(-z $logfile) {
		$logfile_n ++;
		$logfile = $logfiles[$logfile_n];
		die("All log files in $parentdir/$dir is zero-sized, skip.\n") if($logfile_n >= $logfile_tn);
	}
	if($logfile eq "") {
		print "No log file found in $parentdir/$dir, skip this directory.\n";
		$msg = "Not started";
		$failed{$msg} ++;
		next;
	}
	$valid_flag = 0;
	$msg = "";
	open(FH, "<$logfile") || die("Cannot open $logfile for read.\n");
	while(<FH>) {
		if($_ =~ /now itimestep\s+=\s+(\d*)/i) {
			$ts = $1;
			if($ts > 1 && $valid_flag == 0) {
				$valid ++;
				$valid_flag = 1;
			}
		} elsif($_ =~ /program over/i) {
			$msg = "successfully finished";
			$failed{$msg} ++;
		} elsif($_ =~ / exit signals: (.*)/) {
			$msg = $1;
			$failed{$msg} ++;
		}
	}
	close(FH);
	if($msg eq "") {
		$msg = "Not finished";
		$failed{$msg} ++;
	}
	if($msg!~/successfully finished/) {
		$runts=ContinueRunTimeStep($ts);
		$msg .= ", if needed, restart from TimeStep=$runts";
	}
	printf("%5d\t%40s:\tTimestep=%5d\t(%s)\n",$total,$dir,$ts,$msg);
}

print "\nTotal $total directories found as '$dirs', $valid have log file:\n";
foreach $err (sort keys %failed) {
	printf("\t%5d %s\n", $failed{$err},$err);
}

sub ContinueRunTimeStep($) {
	my ($ts) = @_;
	return    1 if($ts <=  124);
	return  125 if($ts <=  240);
	return  241 if($ts <=  364);
	return  365 if($ts <=  484);
	return  485 if($ts <=  608);
	return  609 if($ts <=  728);
	return  729 if($ts <=  852);
	return  853 if($ts <=  976);
	return  977 if($ts <= 1096);
	return 1097 if($ts <= 1220);
	return 1221 if($ts <= 1340);
	return 1341;
}
