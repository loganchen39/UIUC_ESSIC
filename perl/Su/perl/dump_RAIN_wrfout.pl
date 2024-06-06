#!/usr/bin/perl
use Cwd;
use Getopt::Std;

getopts('d:t:o:fh', \%opts);
$VERSION    = "1.1.0";
$WRFOUT_DIR = $opts{"d"};
$TIMELINE   = $opts{"t"};
$OUTPUT_FILE= $opts{"o"};
$FORCE_OW   = $opts{"f"};
$SHOWHELP   = $opts{"h"};
undef(%opts);
$VARS       ="Times,T2M,RAINC,RAINNC";  # which vars need to be saved
$VARS       =~s/\s//g; #remove space
print "$0 version $VERSION, to dump variables from wrfout to a NetCDF file. '$0 -h' for help page.\n";

$WRFOUT_DIR = "./" if($WRFOUT_DIR eq "");
&HELP_MESSAGE() if($SHOWHELP);

$SY,$SM,$SD,$EY,$EM,$ED;
%time;
if($TIMELINE eq "" || $TIMELINE =~/all/i) {
	$time{"start"}{"year"}  = 0;
	$time{"start"}{"month"} = 0;
	$time{"start"}{"day"}   = 0;
	$time{"end"}{"year"}    = 0;
	$time{"end"}{"month"}   = 0;
	$time{"end"}{"day"}     = 0;
	#print "processing all wrfout files if found.\n";
} elsif($TIMELINE =~ /(\d{4})(\d{2})(\d{2})\-(\d{4})(\d{2})(\d{2})/) {
	$time{"start"}{"year"}  = $1;
	$time{"start"}{"month"} = $2;
	$time{"start"}{"day"}   = $3;
	$time{"end"}{"year"}    = $4;
	$time{"end"}{"month"}   = $5;
	$time{"end"}{"day"}     = $6;
	#print "Processing wrfout files from $1-$2-$3 to $4-$5-$6 if found.\n";
} elsif($TIMELINE =~ /(\d{4})(\d{2})(\d{2})/) {
	$time{"start"}{"year"}  = $1;
	$time{"start"}{"month"} = $2;
	$time{"start"}{"day"}   = $3;
	$time{"end"}{"year"}    = 0;
	$time{"end"}{"month"}   = 0;
	$time{"end"}{"day"}     = 0;
	#print "Processing all wrfout files from $1-$2-$3 if found.\n";
} else {
	HELP_MESSAGE();
}
print "This may take some time (even hours), depending on how much file need to be processed.\n";

opendir(my $dh, $WRFOUT_DIR) || die "can't opendir $WRFOUT_DIR: $!";
@all_files = grep { /wrfout/ && -f "$WRFOUT_DIR/$_" } sort readdir($dh);
closedir($dh);

$cmd = "ncrcat -p $WRFOUT_DIR/ -v $VARS -O ";
$idx = 0;
foreach $file (sort @all_files) {
	if($file =~ /^wrfout_d(\d{1,3})_(\d{4})-(\d{2})-(\d{2})_(\d{2}):(\d{2}):(\d{2})$/) {
		$ty = $2; $tm = $3; $td = $4;
 		$valid = CheckTimeLine(int($ty), int($tm), int($td));
		if($valid) {
			$idx ++;
			if($idx == 1) {
				$SY = $ty; $SM = $tm; $SD = $td;
			}
			$EY = $ty; $EM = $tm; $ED = $td;
			$cmd .= " $file ";
		}
	}
}

die("No wrfout found in $WRFOUT_DIR.\n") if($idx == 0);
print "From $SY-$SM-$SD to $EY-$EM-$ED, total $idx files need to be processed.\n";

$SY = sprintf("%04d", $SY);
$SM = sprintf("%02d", $SM);
$SD = sprintf("%02d", $SD);
$EY = sprintf("%04d", $EY);
$EM = sprintf("%02d", $EM);
$ED = sprintf("%02d", $ED);
if($OUTPUT_FILE eq "") {
	if($SY == $EY && $SM == $EM && $SD == $ED) {
		$OUTPUT_FILE = "wrfout_VARS_" . $SY . "_" . $SM . "_" . $SD . ".nc";
	} else {
		$OUTPUT_FILE = "wrfout_VARS_" . $SY . "_" . $SM . "_" . $SD . "_" . $EY . "_" . $EM . "_" . $ED . ".nc";
	}
}

$cmd .= " -o $OUTPUT_FILE ";

die("Destination file $OUTPUT_FILE exists, specify '-f' to overwrite it or change OUTPUT_FILE using -o.\n") if(-e $OUTPUT_FILE && !$FORCE_OW);
system($cmd);
die("Failed!!!, plese check NCO:ncrcat and command:\n$cmd\n\n") if((!-e $OUTPUT_FILE) || (-z $OUTPUT_FILE));


######################################################################
# Subroutines

sub HELP_MESSAGE() {	# compatible with getopt
	print "\nDump RAINC, RAINNC from wrfout, write to a NetCDF file (using CDO)\n";
	print "\nUsage: $0 [-d wrfout_dir] [-t YYYYMMDD[-YYYY]] [-o /path/to/output_file] [-f] [-h]\n";
	print "\t-d wrfout_dir           : dir of wrfout, default is ./.\n";
	print "\t-t YYYYMMDD[-YYYYMMDD]  : timeline, from YYYYMMDD to YYYYMMDD.\n";
	print "\t-o /path/to/output_file : output file, default dir is ./, default filename will be generated based on the timeline of wrfout.\n";
	print "\t-f                      : force to overwrite output file if exists.\n";
	print "\t-h                      : show this help.\n\n";
	exit;
}

sub VERSION_MESSAGE() {	# compatible with getopt
	HELP_MESSAGE();
}

sub CheckTimeLine($$$) {
	my ($y, $m, $d) = @_;
	return 1 if($time{"start"}{"year"} == 0 && $time{"end"}{"year"} == 0);

	my $r;
	$r = 1;
	if($time{"start"}{"year"} != 0) {
		$r = 0 if($y <  $time{"start"}{"year"});
		$r = 0 if($y == $time{"start"}{"year"} && $m <  $time{"start"}{"month"});
		$r = 0 if($y == $time{"start"}{"year"} && $m == $time{"start"}{"month"} && $d < $time{"start"}{"day"});
	}
	if($time{"end"}{"year"} != 0) {
		$r = 0 if($y >  $time{"end"}{"year"});
		$r = 0 if($y == $time{"end"}{"year"}   && $m >  $time{"end"}{"month"});
		$r = 0 if($y == $time{"end"}{"year"}   && $m == $time{"end"}{"month"}   && $d > $time{"end"}{"day"});
	}
	return $r;
}
