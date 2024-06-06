#!/usr/bin/perl

#
# script to upload files to MASSStorage
# Usage: upload2mss.pl local_Dir file_filter Mss_Dir 
#        file_filter: \*=all files, \*.nc=all nc files, ...
#        notice: has to use a "\" before *, or use "*" instead of *
#


$local_dir   = $ARGV[0];
$file_filter = $ARGV[1];
$mss_dir     = $ARGV[2];
$force       = $ARGV[3];
$file_filter =~s/\\//g;
$file_filter =~s/\"//g;
$file_filter =~s/\'//g;
$isforced = 0;
$isforced = 1 if(lc($force) eq "-f" || lc($force) eq "--force");

if($mss_dir eq "") {
	print "\nUsage $0 Local_Dir file_filter MSS_Dir [-f|--force]\n\n";
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
chdir($local_dir);
my %local_file_size;
$ls = `ls -1tr $file_filter`;
@files = split("\n", $ls);
$total = @files;
die("File $file_filter not found in local dir $local_dir\n") if(!$total);
foreach $file (sort @files) {
	next if($file =~ /^\./);
	$file_prefix = $1;
	@filestat = stat($file);
	$filesize = $filestat[7];
	#$lastmodifytime = $filestat[9];
	#next if($lastmodifytime >  time() - 60);
	$local_file_size{$file} = $filesize;
	print "Local file: $file, size=$filesize\n";
}
print "Total $total files found.\n\n";


%mss_file_size;
if($isforced == 0) {	# if forced upload, needn't to get file size from MSS
	### MSS
	print "Checking file size in MSS ... \n";
	$list = "";
	$list = `mssftp "cd $mss_dir; ls"`;
	die("Can't get remote file size") if(length($list) < 100);
	@lines = split("\n", $list);
	$total = @lines;
	for($i=0; $i<$total; $i++) {
		$line = $lines[$i];
		chop($line);
		if($line =~ /^(.{10})\s+\d+\s+\S+\s+\S+\s+\S+\s+\S+\s+(\d+)\s+\S+\s+\d+\s+\d{1,2}:\d{1,2}\s+(\S*)$/i) {
			$fn = $3; $fs = $2;
			next if($fn eq "." || $fn eq "..");
			$mss_file_size{$fn} = $fs;
		}
	}
}


$total = 0;
foreach $file (sort keys %local_file_size) {
	$realsize  = $local_file_size{$file};
	$msssize   = $mss_file_size{$file};
	if($msssize ne $realsize) {
		### we need to download it again
		$cmd = "mssftp \"lcd $local_dir; cd $mss_dir; bi; put $file;\"";
		print "Uploading file $file (local size=$realsize, remote size=$msssize)...\n";
		print "$cmd\n";
		system("$cmd > /dev/null");
		$total ++;
	}
}
print "Total $total files uploaded to MSS:$mss_dir.\n\n";

