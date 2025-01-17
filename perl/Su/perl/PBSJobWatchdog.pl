#!/usr/bin/perl
require $ENV{'HOME'} . "/software/perl/functions.pl";

$loginname = `whoami`; chop($loginname);
$home = $ENV{'HOME'};
$host = `hostname -a`; chop($host);
$uname = `uname -a`; chop($uname);
$host .= " " . $uname;

$pbsscript = $ARGV[0]; $flagfile = $ARGV[1]; $keystring = $ARGV[2];
if($pbsscript eq "") {
	print "\nUsage : $0 PBSJobScript [Flagfile KeyString]\n\n";
	print "\tPBSJobScript: qsub script to submit PBS job, with full path.\n";
	print "\tFlagFile    : a file to identify which stage is running\n";
	print "\tKeyString   : this watchdog will exit if {KeyString} found in file {FlagFile}\n\n";
	print "\nNotice: If {FlagFile} and {KeyString} not given, the watchdog will submit PBS\n";
	print "\tjob {PBSJobScript} in a endless loop, remember to do something in the\n";
	print "\t{PBSJobScript} file to avoid processing the last section again and again.\n\n";
	print "\nLog file will be written to ~/scratch-global/log/{PBSJobName}_{date}.log\n\n";
	exit;
}

if(!-e $pbsscript) {
	print "PBSScript file: $pbsscript not found.\n";
	exit;
}
$pbsname = getPBSName($pbsscript);
if($pbsname eq "") {
	print "Unknow PBSJobName, the PBSJob script file $pbsscript must contains a line to set the PBS job name, such as:\n#PBS -N jobname\n\n";
	exit;
}

%t = getCurrentTime(1);
$logfile = $home . "/scratch/log/" . $pbsname . '_' . $t{'yyyymmdd'} . $t{'hhmmss'} .  ".log";
print "Log file: $logfile\n";

open(LOG, ">$logfile") || die("Cannot open log file for write: $logfile\n");
select(LOG);

print $lt = localtime;
print "\nRunning on $host (PID=$$) with command line parameters:\n";
print "\t0: " . $ARGV[0] . "\n";
print "\t1: " . $ARGV[1] . "\n";
print "\t2: " . $ARGV[2] . "\n";
print "\t3: " . $ARGV[3] . "\n\n\n";

$sleeptime = 30;
$JobID = "";

while(1) {
	checkFlagFile($flagfile, $keystring);

	#$JobID = checkRunningJob($pbsname, $pbsspool);

	if($JobID eq "") {			### no running, check queue
		$JobID = checkQueueJob($loginname, $pbsname);
	}
	if($JobID  eq "") {			### check queue again, sometimes "qstat" fails.
		$JobID = checkQueueJob($loginname, $pbsname);
	}
	if($JobID  eq "") {			### check queue again, sometimes "qstat" fails.
		sleep(2);
		$JobID = checkQueueJob($loginname, $pbsname);
	}
	
	
	### A job is running (or in queue), just wait
	if($JobID ne "") {
		#print $JobID . "\n";
		print ".";
		sleep($sleeptime);
		$JobID = "";
		next;
	}
	
	print $lt = localtime;
	print "\nStart new job now ... ";
	startrun($pbsscript);
	sleep($sleeptime);
}
close(LOG);
exit;

#########################################
# get PBS Job name:
sub getPBSName($) {
	my ($pbsscript) = @_;
	my $name = "";
	open(FJ, "<$pbsscript") || die("getPBSJobNameL Cannot open $pbsscript for read.\n");
	while(<FJ>) {
		my $line = $_;
		chop($line);
		if($line =~ /#PBS\s+-N\s+(.*)$/) {
			$name = $1;
		}
	}
	close(FJ);
	if(length($name) > 10) {
		$name = substr($name, 0, 10);
	}
	return $name;
}

# if $keystring was found in $flag file, exit watchdog.
sub  checkFlagFile($flagfile, $keystring) {
	my ($flagfile, $keystring) = @_;
	return if($flagfile eq "");
	return if($keystring eq "");
	return if(!(-e $flagfile));
	open(FH, "<$flagfile");
	while(<FH>) {
		$line = $_;
		#chop($line);	# in case it contains no <RETURN>
		if($line =~ /$keystring/i) {
			print "\n\n";
			print $lt = localtime;
			print "\tFlagFile $flagfile contains\n$line\nwhich matches \"$keystring\", watchdog exit now.\n";
			exit;
		}
	}
	close(FH);
	return;
}

sub checkQueueJob($$) {
	my ($loginname, $pbsname) = @_;
	#print "Checking job $pbsname ... ";
	$randfile = $pbsname . "_" .  int(rand(10000));
	my $i = 0;
	while(-e $randfile) {
		$i ++;
		last if($i > 100);
		$randfile = $pbsname . "_" . int(rand(1000000));
	}
	$randfile = $home . "/scratch/log/" . $randfile;
	### sometimes "qstat" fails, need to call this subroutine at least twice.
	## sample of 
	# qstat -u zfsu79 |grep CCTM_DAILY
	#853400.abem5.ncsa.ui zfsu79   debug    CCTM_DAILY    --      2   1   10gb 00:30 Q   --
	system("qstat -u $loginname | grep $pbsname > $randfile");

	my $JobID = "";
	open(QS, "<$randfile");
	while(<QS>) {
		my $line = $_;
		chop($line);
		#Job ID               Username Queue    Jobname          SessID NDS   TSK Memory Time  S Time
		#-------------------- -------- -------- ---------------- ------ ----- --- ------ ----- - -----
		#6197435.nid00003     shenjian xfer     A1B2048           83138   --   --    --  00:30 C 00:00
		if($line =~ /^\s*(\d+)\.nid(\d+)\s+$loginname(.*)$pbsname(.*)\d{2}:\d{2}\s+(\S)\s+(.*)/i) {
			my $status = $5;
			$JobID .= $1 . ".nid" . $2 . ", " if($status !~ /C/i);
		}
	}
	close(QS);
	system("rm -f $randfile") if(-e $randfile);
	return $JobID;
}

sub checkRunningJob($$) {
	my ($pbsname, $pbsspool) = @_;
	### Main idea of this subroutine:
	### when a PBS job is running (not Q, but R), 2 files will be created in dir ~/.pbs_spool:
	###      858148.abem.OU, 858148.abem.ER
	### the OU file should contains a line like this:
	### "Job Name:         CCTM_DAILY"
	###
	my $JobID = 0;
	my $status = `grep "$pbsname" $pbsspool | grep "Job Name:"`;
	if($status =~ /$pbsspool\/(\d+)(\D+)\.OU(.*)$pbsname/i) {
		$JobID = $1;
	}
	return $JobID;
}

sub startrun($) {
	my($pbsscript) = @_;
	system("qsub $pbsscript");
	return 1;
}

