#!/usr/bin/perl
################################################################################
# To: 1. download data
#     2. convert format (GRIB2 -> GRIB1)
#     3. rename according to the date of the data
#     4. invoke 2 python scripts to prepare data for CWRF and to submit job.
#
# Know problem:
#     1. some hardcode in python scripts, make sure the directory is correct.
#
#  Su, 08/25/09
################################################################################
use Time::Local;
use Cwd;

$Me   = `whoami`; chop($Me);
$Home = $ENV{"HOME"};
$cwd = getcwd;

# Change the following directories to your own:
$BaseDir     = "/nas/lv10/xyuan/GFS/";
$DownloadDir = $BaseDir . "/download/";
$Grib1Dir    = $BaseDir . "/grib1/backup/";
$Grib1RunDir = $BaseDir . "/grib1/run/";
$DataBaseURL = "ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/";  #/gfs.2009082512/...
$wgrib       = "wgrib";		# where is the executable wgrib/...   with abs path
$cnvgrib     = "cnvgrib";
$wget        = "wget -c -t0";
$python      = "python";
$ln          = "ln -sf";
$rm          = "rm -rf";
$mkdir       = "mkdir";
$mv          = "mv -f";
# End of settings.

# Main program begins.
chdir($BaseDir);
$DateHr = ""; $StartYMDH = $EndYMDH = "";	# global vars
getDateHr();

# check
CheckDirs();

# get ready for new download
CleanDownloadDir();

# download data
DownloadData();

#grib2 to grib1
Grib2to1();

chdir($cwd);
# call prepare_GFS python script
$cmd = "$python prepare_GFS_2009 $StartYMDH $EndYMDH '$Grib1RunDir/$DateHr'";
print "Invoking python script: $cmd \n";
system($cmd);

# call run.GFS python script
$cmd = "$python run.GFS.2009 $StartYMDH $EndYMDH";
print "Invoking python script: $cmd \n";
system($cmd);
exit;
#end of main program

################################################################################
# subroutines:
sub CheckDirs() {
	# to check the directories before do anything
	foreach my $dir ($BaseDir, $DownloadDir, $Grib1Dir, $Grib1RunDir) {
		next if(-e $dir && -d $dir);
		die("FATAL: $dir is a file, not a directory.\n") if(-e $dir);
		system("$mkdir -p $dir");
		die("FATAL: Cannot create $dir.\n") if(!-e $dir);
	}
	return 1;
}

sub CleanDownloadDir() {
	system("$rm $DownloadDir/*");
	return 1;
}

sub getDateHr() {
	my (undef, undef, $h, $d, $m, $y, undef, undef, undef) =  localtime();
	my $cy, $cm, $cd, $ch;
	$y += 1900; $m ++;
	$cy = $y;
	$cm = sprintf("%02d", $m);
	$cd = sprintf("%02d", $d);
	$ch = ($h < 12) ? "00" : "12";
	$DateHr = $cy .$cm .$cd . $ch;
	return $DateHr;
}

sub DownloadData() {
	print "Tring to download data of $DateHr ... \n";
	my $url = $DataBaseURL . "/gfs." . $DateHr . "/";
	my $files1 = "gfs.t" . substr($DateHr, 8, 2) . "z.pgrbf*.grib2";
	my $files2 = "gfs.t" . substr($DateHr, 8, 2) . "z.sfluxgrbf*.grib2";
	$cmd = "$wget -q --directory-prefix=$DownloadDir $url/$files1 $url/$files2";
	system($cmd);

	my $filecount = 0;
	my @files = split("\n", `ls -1 $DownloadDir/`);
	$filecount = @files;
	print "Total $filecount files downloaded.\n";
	return $filecount;
}

sub Grib2to1() {
	print "Converting GRIB2 to GRIB1 ... \n";
	system("$mkdir -p $Grib1Dir/$DateHr"   ) if(!-e "$Grib1Dir/$DateHr");
	system("$mkdir -p $Grib1RunDir/$DateHr") if(!-e "$Grib1RunDir/$DateHr");
	chdir($DownloadDir);
	my $ls = `ls -1`;
	my @files = split("\n", $ls);
	my $filecount = 0;
	foreach $file (@files) {
		print "Processing file $file ... ";
		my $valid = 0;
		$valid = 1 if($file =~ /gfs.t(\d{1,2})z.pgrbf(\d{1,4}).grib2/i);
		$valid = 1 if($file =~ /gfs.t(\d{1,2})z.sfluxgrbf(\d{1,4}).grib2/i);
		if($valid == 0) {
			system("$rm $file");
			print "Useless file, deleted.\n";
			next;
		}
		my $grib1name = $file;
		$grib1name =~s/grib2/grib/i;
		system("$rm $grib1name") if(-e $grib1name);
		my $cmd = "$cnvgrib -g21 $file $grib1name";
		system($cmd);
		die("Cannot create $grib1name based on $file.\n") if(!-e $grib1name);
		$filecount ++;
		RenameGrib1($grib1name);
		system("$rm $file");
	}
	print "Total $filecount files converted.\n";
}

sub RenameGrib1($) {
	my ($file) = @_;
	my $isflux = ($file =~/flux/i) ? 1 : 0;
	my $prefix = ($isflux) ? "GFSflux" : "GFS";
	my $wgribout = `$wgrib -v $file`;
	my $out = "";
	my @wgrib_out = split("\n", $wgribout);
	for(my $i=0; $i<@wgrib_out; $i++) {
		if($wgrib_out[$i] =~ /:D=(\d{10}):/i) {
			$out = $wgrib_out[$i];
			last;
		}
	}
	die("Cannot wgrib file $file, is it in wgrib1 format?\n") if($out eq "");
	
	my $dh, $hr;
	if($out =~ /:D=(\d{10}):.*:(\d+)-(\d+)hr\s+fcst:/i) {
		$dh = $1; $hr = $3;
	} elsif($out =~ /:D=(\d{10}):.*:(\d+)-(\d+)hr\s+ave:/i) {
		$dh = $1; $hr = $3;
	} elsif($out =~ /:D=(\d{10}):.*:(\d+)hr fcst:/i) {
		$dh = $1; $hr = $2;
	} elsif($out =~ /:D=(\d{10}):/i) {
		$dh = $1; $hr = 0;
	}
	my $newname = AdjustTime($dh, $hr);
	my $h = substr($newname, 8, 2);
	$StartYMDH = $newname if($StartYMDH eq "");
	$EndYMDH   = $newname if($EndYMDH eq "");
	$StartYMDH = ($StartYMDH < $newname) ? $StartYMDH : $newname;
	$EndYMDH   = ($EndYMDH   > $newname) ? $EndYMDH   : $newname;
	$newname   = $prefix . $newname;
	system("$mv $DownloadDir/$file $Grib1Dir/$DateHr/$newname");
	system("$ln $Grib1Dir/$DateHr/$newname $Grib1RunDir/$DateHr/$newname") if(($h == 0 || $h == 12) && ($isflux == 0));
	print "File $newname generated.\n";
}

sub AdjustTime($$) {
	my ($dh, $hr) = @_;
	return $dh if($hr == 0);
	my $y, $m, $d, $h;
	if($dh =~ /(\d{4})(\d{2})(\d{2})(\d{2})/) {
		$y = $1; $m = $2; $d = $3; $h = $4;
	} else {
		die("Unknow date format: $date\n")
	}
	$y -= 1900; $m --;
	my $g = timegm(0, 0, $h, $d, $m, $y);
	$g += $hr * 3600;
	(undef, undef, $h, $d, $m, $y, undef, undef, undef) =  gmtime($g);
	$y += 1900;
	$m ++;
	$m = sprintf("%02d", $m);
	$d = sprintf("%02d", $d);
	$h = sprintf("%02d", $h);
	return $y . $m . $d . $h;
}
