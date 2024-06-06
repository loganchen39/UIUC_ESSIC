#!/usr/bin/perl
#################################################################################
# Script to generate NetCDF data file based on GrADS files (data & CTL)
#
# Based on: date (*nix shell command), NCL
#
# Known problems:
#   1. Can handle "1 timestep / binary file" only, if a binary file contains more 
#      than 1 timestep, need to change this script. (NCL was generaged incorrectly)
#   2. NCL error not detected, if error occurs when running NCL, user have to check
#      NCL output directly.
#   3. NC file not tested, may add ncdump to test it later.
#
# Shenjian Su (zfsu79@illinois.edu), 20091230
#################################################################################
use Getopt::Std;

getopts('c:ndfo:h', \%opts);
$ctl     = $opts{"c"};
$nclonly = $opts{"n"};
$delncl  = $opts{"d"};
$overwr  = $opts{"f"};
$help    = $opts{"h"};
$output  = $opts{"o"};
undef(%opts);

if($ctl eq "" || $help) {
	print "\nUsage: $0 [OPTIONS] -c CTL_file\n";
	print "\tConvert GrADS data to NetCDF format.\n";
	print "\tNCL and *nix command 'date' are needed.\n\n";
	print "\tCTL_file: .ctl for GrADS.\n";
	print "\tOPTIONS :\n";
	print "\t    -h  : show this help\n";
	print "\t    -n  : generate ncl only, do not generate NC file\n";
	print "\t    -d  : remove NCL if NC file generated successfully\n";
	print "\t    -f  : overwrite NCL script and NC files if exists\n";
	print "\t    -o  : output NCL/NC file name\n\n";
	print "\tIMPORTANT NOTICE:\n";
	print "\t - In CTL file, following conponents are essential:\n";
	print "\t\tDSET, TITLE, UNDEF, XDEF, YDEF, ZDEF, ZDEF, VARS\n";
	print "\t\tWhile following definitions are optional: OPTIONS BIG_ENDIAN, PDEF, EDEF\n";
	print "\t - In variable description, unit are written in [], e.g: [g/m2]\n\n";
	exit;
}

die("CTL file $ctl not exists, or not a file.\n") if((!-e $ctl) || (-d $file) || (-z $file));

if($ctl =~ /^(.*)\/([^\/])*/) {
	$ctlpath = $1;
}

if($output) {
	$nc = $output . ".nc";
	$ncl = $output . ".ncl";
} else {
	$nc = $ctl;
	$nc =~s/\.ctl//ig;
	$nc =~s/\//_/g;
	$nc =~s/\.//g;
	$nc =~s/^_//g;
	$nc.=".nc";
	$ncl = $ctl;
	$ncl =~s/\.ctl/\.ncl/ig;
	$ncl =~s/.*\///g;
}

#init:
$FILE, @FILES,
$TITLE,
$MISSING,
$BIG_ENDIAN, $TEMPLATE,
$NX, $NY, $NZ,
$NV, %VARS, $VARID;
$TSETP, $TSTEPUNIT, %TSTART, %TIMES; # template file name

$isvar = 0;
print "Parsing GrADS ctl file $ctl ... \n\n";
open(CTL, "<$ctl") || die("Cannot open CTL file $ctl for read.\n");
while(<CTL>) {
	chomp;
	$line = $_;
	next if($line =~ /^\*/);	#comments
	DSET($line)    if($line =~ /^dset\s+/i);
	TITLE($line)   if($line =~ /^title\s+/i);
 	MISSING($line) if($line =~ /^undef\s+/i);
	OPTIONS($line) if($line =~ /^options\s+/i);
	DEF($line)     if($line =~ /^[x,y,z,t,p]def\s+/i);
	
	if($line =~ /^vars\s+(\d+)/i) {
		$NV = $1;
		$isvar = 1;
		$VARID = 0;
		next;
	} elsif($line =~ /^endvars/i) {
		$isvar = 0;
	}

	ParseVar($line) if($isvar);
}
close(CTL);

Check();
WriteNCL();
ExeNCL() if(!$nclonly);

#================================================================================
#parse DSET in ctl, "options template" and "TDEF" may affect the result.
sub DSET($) {
	my($line) = @_;
	$line=~s/^dset\s+//gi;
	$line=~s/^\^//;
	if($line !~ /\// && $ctlpath ne "") { $FILE = $ctlpath . "/" . $line; }
	else { $FILE = $line; }
	return;
}

# parse TITLE in ctl
sub TITLE($) {
	my($line) = @_;
	$line=~s/^title\s+//gi;
	$TITLE = $line;
	return;
}

sub MISSING($) {
	my($line) = @_;
	$line=~s/^undef\s+//ig;
	$MISSING = $line;
	return;
}

sub OPTIONS($) {
	my($line) = @_;
	$TEMPLATE = 0;
	$BIG_ENDIAN = 0;
	$TEMPLATE = 1 if($line =~/template/i);
	$BIG_ENDIAN = 1 if($line =~/big_endian/i);
	return;
}

sub DEF($) {
	my($line) = @_;
	if($line =~ /^([x,y,z,t])def\s+(\d+)\s+/i) {
		my $dim = uc($1);
		my $val = $2;
		my $vv  = "N" . $dim;
		$$vv = $2;

		if($dim eq "T" && $TEMPLATE == 1) {
			# handle template in data file name
			if($line =~ /^tdef\s+\d+\s+linear\s+(\S+)\s+(\d+)(\D+)/i) {
				$TSTART    = ParseTime($1);
				$TSTEP     = $2;
				$TSTEPUNIT = $3;
				GenerateTimeList();
				GenerateFileList();
			} else {
				print "Unknow how to parse TDEF, STOP.\n";
				print "$line\n";
				exit;
			}
		}
	}
	return;
}

sub ParseVar($) {
	my($line) = @_;
	if($line =~ /^(\S+)\s+(\d+)\s+(\d+)\s+(.*)$/) {
		my $vname = uc($1);
		my $level = $3;
		$level = 1 if($NZ == 1);
		my $desc  = $4;
		my $units = "-";
		if($desc =~ /\[(.*)\]/) {
			$units = $1;
			$desc =~s/\[.*\]//g;
		}
		my $fmt = "%0" . (length($NV) + 1) . "d";
		my $vid = sprintf($fmt, $VARID);		# for variable order
		$VARS{$vid}{"name"}  = $vname;
		$VARS{$vid}{"level"} = $level;
		$VARS{$vid}{"units"} = $units;
		$VARS{$vid}{"lname"} = $desc;
		$VARID ++;
	}
	return;
}

sub ParseTime($) {
	my($t) = @_;
	my %M3 = ( "JAN"=>1, "FEB"=>2, "MAR"=>3, "APR"=>4, "MAY"=>5, "JUN"=>6,
			   "JUL"=>7, "AUG"=>8, "SEP"=>9, "OCT"=>10,"NOV"=>11,"DEC"=>12 );
	my $year, $month, $day, $hour, $minute, $cmonth;
	if($t=~/(\d{1,2}):(\d{1,2})Z(\d{1,2})(\D{3})(\d{2,4})/i) {
		$hour   = $1;
		$minute = $2;
		$day    = $3;
		$cmonth = $4;
		$year   = $5;
	} elsif($t=~/(\d{1,2})Z(\d{1,2})(\D{3})(\d{2,4})/i) {
		$hour   = $1;
		$minute = 0;
		$day    = $2;
		$cmonth = $3;
		$year   = $4;
	} elsif($t=~/(\d{1,2})(\D{3})(\d{2,4})/i) {
		$hour   = 0;
		$minute = 0;
		$day    = $1;
		$cmonth = $2;
		$year   = $3;
	} else {
		print "Unknow format of TDEF, STOP.\n";
		print $t . "\n";
		exit;
	}

	$year += 1900 if($year <= 50);					# 2 digit year means 1950-2049
	$year += 2000 if($year > 50 && $year < 100);	# 2 digit year means 1950-2049
	$month = $M3{uc($cmonth)};

	$year  = sprintf("%04d", $year  );
	$month = sprintf("%02d", $month );
	$day   = sprintf("%02d", $day   );
	$hour  = sprintf("%02d", $hour  );
	$minute= sprintf("%02d", $minute);

	$TSTART{"year"}   = $year;
	$TSTART{"cmonth"} = uc($cmonth);
	$TSTART{"month"}  = $month;
	$TSTART{"day"}    = $day;
	$TSTART{"hour"}   = $hour;
	$TSTART{"minute"} = $minute;
	return;
}

sub GenerateTimeList() {
	my $i=0;
	for($i=0; $i<$NT; $i++) {
		AdjustTime($i);
	}
}

sub AdjustTime($) {
	my ($n) = @_;
	my %M3 = ( 1=>"JAN", 2=>"FEB", 3=>"MAR", 4=>"APR", 5=>"MAY", 6=>"JUN",
			   7=>"JUL", 8=>"AUG", 9=>"SEP",10=>"OCT",11=>"NOV",12=>"DEC" );
	my $y, $m, $cm, $d, $h, $mi, %t, $str, $nt, $unit;
	if($TSTEPUNIT =~ /mn/i) {
		$unit = "minute";
	}elsif($TSTEPUNIT =~ /hr/i) {
		$unit = "hour";
	}elsif($TSTEPUNIT =~ /dy/i) {
		$unit = "day";
	}elsif($TSTEPUNIT =~ /mo/i) {
		$unit = "month";
	}elsif($TSTEPUNIT =~ /yr/i) {
		$unit = "year";
	} else {
		print "Unknow $TSTEPUNIT in TDEF. STOP.\n";
		exit;
	}
	$nt = $n * $TSTEP;
	$y  = $TSTART{"year"};
	$cm = $TSTART{"cmonth"};
	$d  = $TSTART{"day"};
	$h  = $TSTART{"hour"};
	$mi = $TSTART{"minute"};
	$str = $h . ":" . $mi . " " . $d . $cm . $y . "+" . $nt . $unit;	# 18:35 09Jul2009+17day
	my $cmd = "date --date='$str' +'%Y%m%d %H:%M'";
	my $newtime = `$cmd`;
	if($newtime =~ /^(\d{4})(\d{2})(\d{2}) (\d{2}):(\d{2})/) {
		$y = $1;
		$m = $2;
		$d = $3;
		$h = $4;
		$mi=$5;
		$cm=$M3{int($m)};
	} else {
		print "Unknow how to get date using command: $cmd. STOP.\n";
		exit;
	}

	$TIMES{$n}{"year"}   = $y;
	$TIMES{$n}{"cmonth"} = $cm;
	$TIMES{$n}{"month"}  = $m;
	$TIMES{$n}{"day"}    = $d;
	$TIMES{$n}{"hour"}   = $h;
	$TIMES{$n}{"minute"} = $mi;
	return;
}

sub GenerateFileList() {
	@FILES = ();
	my $i = 0;
	for($i=0; $i<$NT; $i++) {
		my $file = $FILE;
		#only these supportted now, may add more later. see http://www.iges.org/GRADS/GADOC/templates.html
		my $y2, $y4, $m1, $m2, $mc, $d1, $d2, $h1, $h2, $n2;
		$y4 = $TIMES{$i}{"year"};
		$y2 = substr($y4, 2, 2);
		$m2 = $TIMES{$i}{"month"};
		$m1 = int($m2);
		$mc = $TIMES{$i}{"cmonth"};
		$d2 = $TIMES{$i}{"day"};
		$d1 = int($d2);
		$h2 = $TIMES{$i}{"hour"};
		$h1 = int($h2);
		$n2 = $TIMES{$i}{"minute"};
		$file =~s/\%y2/$y2/ig;
		$file =~s/\%y4/$y4/ig;
		$file =~s/\%m1/$m1/ig;
		$file =~s/\%m2/$m2/ig;
		$file =~s/\%mc/$mc/ig;
		$file =~s/\%d1/$d1/ig;
		$file =~s/\%d2/$d2/ig;
		$file =~s/\%h1/$h1/ig;
		$file =~s/\%h2/$h2/ig;
		$file =~s/\%n2/$n2/ig;
		$FILES[$i] = $file;
	}
}

sub Check() {
	$MISSING = "1.e20" if(!$MISSING);
	print "Data files: $FILE (@FILES)\n";
	print "Title     : $TITLE\n";
	print "UNDEF     : $MISSING\n";
	print "OPTIONS   : TEMPLATE:$TEMPLATE, BIG_ENDIAN:$BIG_ENDIAN\n";
	print "XDEF      : $NX\n";
	print "YDEF      : $NY\n";
	print "ZDEF      : $NZ\n";
	print "TDEF      : $NT\n";
	print "VARS      : $NV\n";
	my $c = 0;
  foreach my $v (sort keys %VARS) {
	$c ++;
	print  "    ";
	printf ("%3d", $c);
	print  ": ";
	printf ("%-10s", $VARS{$v}{"name"});
	print  " (";
	printf ("%3d", $VARS{$v}{"level"});
	print  "levels), Unit: ";
	printf ("%-10s",  $VARS{$v}{"units"});
	print  "Desc: " . $VARS{$v}{"lname"} . "\n";
  }
	print "\n\n\n";
}

sub WriteNCL() {

	system("rm -f $ncl") if($overwr && -e $ncl);
	die ("\n\nTarget $ncl exists!!! STOP.\n\n") if(-e $ncl && (!-z $ncl));
	
	my $filestr = "";
	foreach my $f (@FILES) {
		$filestr .= "\"$f\", ";
	}
	chop($filestr); chop($filestr);
	$filestr2 = $filestr; $filestr2 =~s/\"//g;
	
	my $varname  = "";
	my $varlname = "";
	my $varunit  = "";
	foreach my $v (sort keys %VARS) {
		$varname  .= "\"" . $VARS{$v}{"name"}  . "\", ";
		$varlname .= "\"" . $VARS{$v}{"lname"} . "\", ";
		$varunit  .= "\"" . $VARS{$v}{"units"} . "\", ";
	}
	chop($varname);  chop($varname);
	chop($varlname); chop($varlname);
	chop($varunit);  chop($varunit);
	
	my $endian = ($BIG_ENDIAN) ? "BigEndian" : "LittleEndian";
	
	print "Generating NCL $ncl ... ";
	open(NCL, ">$ncl") || die("Cannot open $ncl for write.\n");
	print NCL << "EOF_NCL__";
; script to convert binary file to netcdf format
; NOTICE: This script is generated by $0, modification may be overwritten.
; Shenjian Su @ 20091230

load "\$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "\$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "\$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
   NCDF_FILE = "./$nc"  ; to be generated
   OBS_FILES = (/ $filestr /)
   NX=$NX
   NY=$NY
   NZ=$NZ
   NT=$NT
   NV=$NV
   V_NAMES = (/ $varname /)
   V_LNAME = (/ $varlname /)
   V_UNITS = (/ $varunit /)
   data = new ((/ NV, NT, NZ, NY, NX /), "float")
   data\@missingvalue=$MISSING
   data\@_FillValue=$MISSING
   setfileoption("bin", "ReadByteOrder", "$endian")
   ; read binary data
   do m=0,NT-1
      tmp=fbindirread(OBS_FILES(m),  0, (/NV,NZ,NY,NX/), "float")
      do v=0,NV-1
         data(v,m,:,:,:) = tmp(v,:,:,:)
      end do
   end do
   ; create netcdf file
   ncdf = addfile(NCDF_FILE ,"c")
   setfileoption(ncdf,"DefineMode",True)
   fAtt               = True            ; assign file attributes
   fAtt\@CREATION_DATE = systemfunc ("date")        
   fAtt\@DECODE_BY     = "Dr. Feng Zhang, SWS, UIUC. (217)244-4354, zfsu\@illinois.edu"
   fAtt\@SOURCE_FILE   = "$filestr2"
   fAtt\@CEN_LAT       = 37.5
   fAtt\@CEN_LON       = -95.5
   fAtt\@TITLE         = "$TITLE"
   fileattdef( ncdf, fAtt )            ; copy file attributes 
   ; define dimension
   dimNames = (/"time", "lev", "lat", "lon" /)  
   dimSizes = (/ -1   ,  NZ,   NY  ,  NX   /) 
   dimUnlim = (/ True , False, False, False /)   
   filedimdef(ncdf,dimNames,dimSizes,dimUnlim)
   ; output variables
   do i=0,NV-1
      filevardef(ncdf, V_NAMES(i), "float", (/ "time", "lev", "lat", "lon" /) )
      undef("tvar")
      tvar               = new ((/ NT, NZ, NY, NX /), "float")
      tvar\@long_name     = V_LNAME(i)
      tvar\@units         = V_UNITS(i)
      tvar(:, :, :, :)   = data(i, :, :, :, :)
      ncdf->\$V_NAMES(i)\$ = tvar
   end do
end
EOF_NCL__

	close(NCL);
	print "OK\n";
	return;
}

sub ExeNCL() {
	return if($nclonly);
	die("NCL script $ncl not exists or invalid.\n") if((!-e $ncl) || -z $ncl);
	system("rm -f $nc") if($overwr && -e $nc);
	print "Executing NCL...\n";
	system("ncl $ncl");
	print "\nSee NCL output above for detailed information. Better use ncdump to check again.\n\n";
	system("rm -f $ncl") if($delncl);
	return;
}
