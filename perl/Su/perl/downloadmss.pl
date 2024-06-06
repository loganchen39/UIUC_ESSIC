#!/usr/bin/perl

#
# script to download files from MASSStorage
# Usage: upload2mss.pl MSS_Dir file_filter Local_Dir 
#        file_filter: \*=all files, \*.nc=all nc files, ...
#        notice: has to use a "\" before *, or use "*" instead of *
#


$mss_dir     = $ARGV[0];
$file_filter = $ARGV[1];
$local_dir   = $ARGV[2];
$force       = $ARGV[3];
$file_filter =~s/\\//g;
$file_filter =~s/\"//g;
$file_filter =~s/\'//g;
$isforced = 0;
$isforced = 1 if(lc($force) eq "-f" || lc($force) eq "--force");

if($local_dir eq "") {
	print "\nUsage $0 MSS_Dir file_filter Local_Dir [-f|--force]\n\n";
	print "    file_filter: \"*\": all files, \"*.nc\": all nc files, ...\n";
	print "                 the \" is always needed.\n";
	print "    -f|--force:  force upload, even the file size matches.\n\n";
	print "    Will upload files to specified MSS dir. Only files with different size (or missing in MSS) will be uploaded, unless -f is specifies.\n\n";
	exit;
}

$HOME = $ENV{'HOME'};
$whoami = `whoami`; chop($whoami);

# Local:
die("Local dir $local_dir does not exists or not a directory.\n") if((!-e $local_dir) || (!-d $local_dir));

%mss_file_size;
### MSS
print "Checking file size in MSS ... \n";
$list = "";
$list = `mssftp "cd $mss_dir; ls $file_filter"`;
@lines = split("\n", $list);
$total = @lines;
$count = 0;
for($i=0; $i<$total; $i++) {
	$line = $lines[$i];
              #-rwxr-xr-x  xueyuan  ac        DK  common      250657608  Feb 12 23:11  METDOT3D_20480506
	if($line =~ /^(.{10})\s+\S+\s+\S+\s+\S+\s+\S+\s+(\d+)\s+\S+\s+\d+\s+\d{1,2}:\d{1,2}\s+(\S*)$/i) {
		$fn = $3; $fs = $2;
		next if($fn eq "." || $fn eq "..");
		$mss_file_size{$fn} = $fs;
		print "MSS file: $fn, size=$fs\n";
		$count ++;
	}
}
print "Total $count files found in MSS:$mss_dir.\n\n";


%local_file_size;
if($isforced == 0) {	# if forced upload, needn't to get file size from MSS
	chdir($local_dir);
	$ls = `ls -1tr $file_filter`;
	@files = split("\n", $ls);
	$total = @files;
	foreach $file (sort @files) {
		next if($file =~ /^\./);
		@filestat = stat($file);
		$filesize = $filestat[7];
		#$lastmodifytime = $filestat[9];
		#next if($lastmodifytime >  time() - 60);
		$local_file_size{$file} = $filesize;
		print "Local file: $file, size=$filesize\n";
	}
	print "Total $total files found in local:$local_dir.\n\n";
}

$total = 0;
foreach $file (sort keys %mss_file_size) {
	$localsize  = $local_file_size{$file};
	$msssize   = $mss_file_size{$file};
	if($msssize ne $localsize) {
		### we need to download it again
		$cmd = "mssftp \"lcd $local_dir; cd $mss_dir; bi; wait; get $file;\"";
		print "Downloading file $file (local size=$localsize, remote size=$msssize)...\n";
		print "$cmd\n";
		system("$cmd > /dev/null");
		$total ++;
	}
}
print "Total $total files downloaded from MSS:$mss_dir to Local:$local_dir.\n\n";

