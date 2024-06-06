#!/usr/bin/perl 
# vim: ts=4 syntax=on
################################################################################
# Script to check CWRF output using GrADS
# 
# Notice: some hardcoded, such as the project type, the lon-lat, ...
# Shenjian Su (zfsu79@illinois.edu), 2009-8-12
################################################################################

$ncdump     = "ncdump";
$grads      = "grads";		# on climate.sws.uiuc.edu, need to be changed to "gradsnc"
%ShowVar    = (				# set to 0 to hide some variables.
	"Times"					=> 0,
	"LU_INDEX"				=> 0,
	"ZNU"					=> 0,
	"ZNW"					=> 0,
	"ZS"					=> 0,
	"DZS"					=> 0,
	"U"						=> 1,
	"V"						=> 1,
	"W"						=> 1,
	"PH"					=> 1,
	"T"						=> 1,
	"MU"					=> 0,
	"MUB"					=> 0,
	"NEST_POS"				=> 0,
	"P"						=> 1,
	"PB"					=> 0,
	"FNM"					=> 0,
	"FNP"					=> 0,
	"RDNW"					=> 0,
	"RDN"					=> 0,
	"DNW"					=> 0,
	"DN"					=> 0,
	"CFN"					=> 0,
	"CFN1"					=> 0,
	"Q2M"					=> 1,
	"T2M"					=> 1,
	"TH2"					=> 1,
	"PSFC"					=> 1,
	"T2MIN"					=> 1,
	"T2MAX"					=> 1,
	"DT_DIAG_AVG"			=> 0,
	"AHFX"					=> 1,
	"ALFX"					=> 1,
	"AGFX"					=> 1,
	"AT2M"					=> 1,
	"ATSK"					=> 1,
	"AUQV"					=> 1,
	"AVQV"					=> 1,
	"DT_QFLX_AVG"			=> 0,
	"U10"					=> 1,
	"V10"					=> 1,
	"RDX"					=> 0,
	"RDY"					=> 0,
	"CF1"					=> 0,
	"CF2"					=> 0,
	"CF3"					=> 0,
	"ITIMESTEP"				=> 0,
	"XTIME"					=> 0,
	"QVAPOR"				=> 1,
	"QCLOUD"				=> 1,
	"QRAIN"					=> 1,
	"QICE"					=> 1,
	"QSNOW"					=> 1,
	"QGRAUP"				=> 1,
	"QNICE"					=> 1,
	"LANDMASK"				=> 1,
	"TSLB"					=> 0,
	"SMOIS"					=> 0,
	"SH2O"					=> 0,
	"SEAICE"				=> 0,
	"XICEM"					=> 0,
	"SFROFF"				=> 1,
	"UDROFF"				=> 1,
	"IVGTYP"				=> 1,
	"ISLTYP"				=> 1,
	"VEGFRA"				=> 1,
	"GRDFLX"				=> 1,
	"PORSL"					=> 1,
	"SNOPCX"				=> 1,
	"POTEVP"				=> 1,
	"SNOW"					=> 1,
	"SNOWH"					=> 1,
	"RHOSN"					=> 1,
	"CANWAT"				=> 1,
	"STEPRA"				=> 0,
	"STEPCL"				=> 0,
	"STEPBL"				=> 0,
	"STEPSF"				=> 0,
	"STEPCU"				=> 0,
	"XSWDEPTH"				=> 1,
	"XOUTFLOW"				=> 1,
	"XRTWS"					=> 1,
	"XTSS"					=> 1,
	"XWLIQ"					=> 1,
	"XWICE"					=> 1,
	"XZ"					=> 0,
	"XDZ"					=> 0,
	"XORO"					=> 1,
	"XTG"					=> 1,
	"XTLSUN"				=> 1,
	"XTLSHA"				=> 1,
	"XSAG"					=> 1,
	"XSIGF"					=> 1,
	"XLAI"					=> 1,
	"XSAI"					=> 1,
	"XSWI"					=> 1,
	"XALB"					=> 1,
	"XSSUN"					=> 1,
	"XSSHA"					=> 1,
	"XXERR"					=> 1,
	"XZERR"					=> 1,
	"XTAUX"					=> 1,
	"XTAUY"					=> 1,
	"XFSENL"				=> 1,
	"XFEVPL"				=> 1,
	"XETR"					=> 1,
	"XFSENG"				=> 1,
	"XFEVPG"				=> 1,
	"XSHFDT"				=> 1,
	"XOLRG"					=> 1,
	"XRSUR"					=> 1,
	"XRBAS"					=> 1,
	"XRDRN"					=> 1,
	"XRSAT"					=> 1,
	"XRNOF"					=> 1,
	"XQRCHRG"				=> 1,
	"XFCOV"					=> 1,
	"XZWT"					=> 1,
	"XSABG"					=> 1,
	"XSABVG"				=> 1,
	"XTSTAR"				=> 1,
	"XRST"					=> 1,
	"XASSIM"				=> 1,
	"XRESPC"				=> 1,
	"XPARSUN"				=> 1,
	"XPARSHA"				=> 1,
	"XSABVSUN"				=> 1,
	"XSABVSHA"				=> 1,
	"XALBG"					=> 1,
	"XALBV"					=> 1,
	"XSOTAUX"				=> 1,
	"XSOTAUY"				=> 1,
	"XMOTAUX"				=> 1,
	"XMOTAUY"				=> 1,
	"XFCOR"					=> 1,
	"TSK"					=> 1,
	"P_TOP"					=> 0,
	"MAX_MSTFX"				=> 0,
	"MAX_MSTFY"				=> 0,
	"RAINC"					=> 1,
	"RAINNC"				=> 1,
	"SNOWC"					=> 1,
	"SNOWNC"				=> 1,
	"GRAUPELNC"				=> 1,
	"RAINCV"				=> 1,
	"SNOWCV"				=> 1,
	"RAINNCV"				=> 1,
	"SNOWNCV"				=> 1,
	"GRAUPELNCV"			=> 1,
	"CAPE"					=> 1,
	"APR_GR"				=> 1,
	"APR_W"					=> 1,
	"APR_MC"				=> 1,
	"APR_ST"				=> 1,
	"APR_AS"				=> 1,
	"APR_CAPMA"				=> 1,
	"APR_CAPME"				=> 1,
	"APR_CAPMI"				=> 1,
	"DT_CUPR_AVG"			=> 0,
	"EDT_OUT"				=> 0,
	"CUGD_TTEN"				=> 0,
	"CUGD_QVTEN"			=> 0,
	"CUGD_TTENS"			=> 0,
	"CUGD_QVTENS"			=> 0,
	"CUGD_QCTEN"			=> 0,
	"XCLDFRA"				=> 0,
	"CLDFRA"				=> 1,
	"CLDCNV"				=> 1,
	"CWPC"					=> 1,
	"CWPI"					=> 1,
	"CWPR"					=> 1,
	"DT_CL_AVG"				=> 0,
	"ECCF"					=> 0,
	"COSZ"					=> 1,
	"GSW"					=> 1,
	"SWUPT"					=> 1,
	"SWDNT"					=> 1,
	"LWUPT"					=> 1,
	"LWDNT"					=> 1,
	"SWUPS"					=> 1,
	"SWDNS"					=> 1,
	"LWUPS"					=> 1,
	"LWDNS"					=> 1,
	"SWUPTC"				=> 1,
	"SWDNTC"				=> 1,
	"LWUPTC"				=> 1,
	"LWDNTC"				=> 1,
	"SWUPSC"				=> 1,
	"SWDNSC"				=> 1,
	"LWUPSC"				=> 1,
	"LWDNSC"				=> 1,
	"ASWUPT"				=> 1,
	"ASWDNT"				=> 1,
	"ALWUPT"				=> 1,
	"ALWDNT"				=> 1,
	"ASWUPS"				=> 1,
	"ASWDNS"				=> 1,
	"ALWUPS"				=> 1,
	"ALWDNS"				=> 1,
	"ASWUPTC"				=> 1,
	"ASWDNTC"				=> 1,
	"ALWUPTC"				=> 1,
	"ALWDNTC"				=> 1,
	"ASWUPSC"				=> 1,
	"ASWDNSC"				=> 1,
	"ALWUPSC"				=> 1,
	"ALWDNSC"				=> 1,
	"XLAT"					=> 0,
	"XLONG"					=> 0,
	"XLAT_U"				=> 0,
	"XLONG_U"				=> 0,
	"XLAT_V"				=> 0,
	"XLONG_V"				=> 0,
	"ALBEDO"				=> 1,
	"EMISS"					=> 1,
	"TMN"					=> 1,
	"XLAND"					=> 1,
	"QST"					=> 1,
	"UST"					=> 1,
	"PBLH"					=> 1,
	"TCPERT"				=> 1,
	"QCPERT"				=> 1,
	"WCSTAR"				=> 1,
	"HFX"					=> 1,
	"QFX"					=> 1,
	"LH"					=> 1,
	"SNOWF"					=> 1,
	"SAVE_TOPO_FROM_REAL"	=> 0,
);

################################################################################
# DO NOT MODIFY CODE BELOW
#
$time_v     = "Times";
$time_v_dim = "Time"; 	# default value, will get from NC head file automatically.

my %DimensionMapping = (
	"Time" 					=> 	"T",
	"west_east"				=>	"X",
	"south_north"			=>	"Y",
	"bottom_top"			=> 	"Z",
	"bottom_top_stag"		=>	"Z",
	"soil_layers_stag"		=>	"Z",
	"west_east_stag"		=>	"X",
	"south_north_stag"		=>	"Y",
	"sw_band_stag"			=>	"Z",
	"nl_soilpsnow_stag"		=>	"Z",
);

%MonthTotalDays = ( 1 		=> 31,
                    2 		=> 28,
                    3 		=> 31,
                    4 		=> 30,
                    5 		=> 31,
                    6 		=> 30,
                    7 		=> 31,
                    8 		=> 31,
                    9 		=> 30,
                   10 		=> 31,
                   11 		=> 30,
                   12 		=> 31);

CheckGrads();

$file = $ARGV[0];
if($file eq "") {
	print "\n\tUsage: $0 NetCDF_file\n";
	print "\t\tNetCDF_file: any NetCDF data format, with full path\n";
	print "\n\tTo check the result of CWRF output, based on GrADS.\n\n";
	exit;
}

die("Data file $file not exists.\n") if(!-e $file);
print "Processing file $file ... \n";
my %Dimensions, %Variables, %time_data, %VarList, @Time, $Tstep, %CTLinfo, $MaxVarLen, $MaxCtlIdx;
my $varperline = 8;

# temporary files:
$rand     = int(rand(10000));
$headfile = "./.$rand.info";  	# ncdump -h
$ctl_pfx  = "./.$rand";   		# prefix of ctl files for GrADS
$gs_file  = "./.$rand.gs";  		# gs file for GrADS
CleanTmpFiles();

system("$ncdump -v $time_v $file > $headfile");
if(-z $headfile || !-e $headfile) {
	CleanTmpFiles();
	die("Fatal error: either NCDUMP not found, or file $file is not a NetCDF file.\n");
}

ParseNChead();
DisplayInfo();
GenerateCTLfile();
GenerateGSfile();
RunGrADS();
CleanTmpFiles();
exit;

#================================================================================
sub CleanTmpFiles() {
	system("rm -f $headfile") if(-e $headfile);
	system("rm -f $ctl_pfx.*.ctl");
	system("rm -f $gs_file")  if(-e $gs_file);
	return;
}

sub ParseNChead() {
	my $section = 0;  # section: 1=dimension, 2=variables, 3=global attributes; 4=data
	my $data_start = 0, $data_line_no = 0; # temp vars for getting Data
	my $lineno = 0;
	open(HEAD, "<$headfile") || die("Cannot open head file $f for read.\n");
	while(<HEAD>) {
		$lineno ++;
		$line = $_;
		chop($line);
		if($lineno == 1) {
			die("Fatal error: either NCDUMP not found, or file $file is not a NetCDF file.\n") if($line !~ /^netcdf/i);
		}
		if($line =~ /^dimensions:/) {
			$section = 1;
		} elsif($line =~ /^variables:/) {
			$section = 2;
		} elsif($line =~ /^\/\/\s*global attribute/) {
			$section = 3;
		} elsif($line =~ /^data:/) {
			$section = 4;
		}

		if($section == 1) {		# dimension definition
			if($line =~ /\s*(\S*)\s*=\s*UNLIMITED\s*;\s*\/\/\s*\(\s*(\d+)\s*currently\s*\)/) {
				$Dimensions{$1} = $2;
			} elsif($line =~ /\s*(\S*)\s*=\s*(\d+)\s*;/) {
				$Dimensions{$1} = $2;
			}
		}

		elsif($section == 2) {	# variables definition
			#print $line . "\n";
			if($line =~ /^\s*(\S*)\s*(\S*)\((.*)\)\s*;\s*$/i) {
				my $var_type = $1;
				my $varname = $2;
				my $dim_string = $3;
				if($varname eq $time_v) {
					my @dim_array = split(",", $dim_string);
					$time_v_dim = $dim_array[0];
					next;
				}
				next if($ShowVar{$varname} == 0);	# skip some vars
				$MaxVarLen = length($varname) if($MaxVarLen < length($varname)); # get max length of varname
				$dim_string =~s/ //g;
				$VarList{$dim_string} .= $varname . "," if($var_type =~/float/);
			}
		}

		elsif($section == 3) {	# global attributes
			# nothing to do, because we don't need any data from this section
		}

		elsif($section == 4) {	# data of $time_v
			if($line =~/^\}/) {
				$section = 0;
				next;
			}
			$data_line_no ++ if($data_start);
			if($line =~ /\s*$time_v\s*=/i) {
				$data_start = 1;
			}
			if($data_line_no > 0 && $data_line_no <= $Dimensions{$time_v_dim}) {
				$Time[$data_line_no] = GradsFormatTime($line);
				# use first 2 to compute TSTEP
				$Tline[$data_line_no] = $line if($data_line_no > 0 && $data_line_no <= 2);
			}
		}
	}
	close(HEAD);
	# sort var by name
	foreach my $k (keys %VarList) {
		my $tmp = "";
		foreach my $v (sort split(",", $VarList{$k})) {
			$tmp .= $v . ",";
		}
		chop($tmp);
		$VarList{$k} = $tmp;
	}
	return;
}

sub DisplayInfo() {
	# Dimension:
	print "Dimension:\n";
	foreach my $k (keys %Dimensions) {
		print "\t$k = " . $Dimensions{$k} . "\n";
	}
	# Variables:
	print "\nVariables (some variables are filtered out in the head part of $0):\n";
	foreach my $k (keys %VarList) {
		print "\t" . TranslateDimension($k) . ": " . $VarList{$k} . "\n";
	}
	# Data:
	print "\nVar '$time_v':\n";
	foreach my $k (@Time) {
		print "\t$k\n" if($k);
	}
	return;
}

sub GradsFormatTime($) {
	my ($str) = @_;
	my $r;
	my @months = ("", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec");
	if($str =~ /(\d{4})-(\d{2})-(\d{2})_(\d{2}):(\d{2}):(\d{2})/) {
		$r = $4 . "Z" . $3 . $months[$2] . $1;
	}
	return $r;
}

sub getTstep() {
	return "3hr" if($Tline[1] ne "" && $Tline[2] eq "");	# only 1 TSTEP, return any valid string will be ok
	if($Tline[1] eq "" && $Tline[2] eq "") {
		print "Warning: Cannot get TSTEP, set default: 3hr\n";
		return "3hr";
	}
	my $y1, $m1, $d1, $h1, $mi1, $s1, $y2, $m2, $d2, $h2, $mi2, $s2;
	my $diff_sec, $v, $unit;
	if($Tline[1] =~ /(\d{4})-(\d{2})-(\d{2})_(\d{2}):(\d{2}):(\d{2})/) {
		$y1 = $1; $m1 = $2; $d1 = $3; $h1 = $4; $mi1 = $5; $s1 = $6;
	}
	if($Tline[2] =~ /(\d{4})-(\d{2})-(\d{2})_(\d{2}):(\d{2}):(\d{2})/) {
		$y2 = $1; $m2 = $2; $d2 = $3; $h2 = $4; $mi2 = $5; $s2 = $6;
	}
	my $diff_sec = (dayofyear($y2, $m2, $d2) - dayofyear($y1, $m1, $d1)) * 24 * 3600 + ($h2 - $h1) * 3600 + ($mi2 - $mi1) * 60 + ($s2 - $s1);
	if($diff_sec % 86400 == 0) {
		$v = $diff_sec / 86400;
		return $v."dy";
	} elsif($diff_sec % 3600 == 0) {
		$v = $diff_sec / 3600;
		return $v."hr";
	} elsif($diff_sec % 60 == 0) {
		$v = $diff_sec / 60;
		return $v."mi";
	} else {
#		return "3hr";		# uncomment this line to return default "3hr"
		return $diff_sec . "ss";
	}
}

sub GenerateCTLfile() {
	my $idx = 0;
	print "\nGenerating GrADS CTL file ...\n";
	foreach $dim_string (keys %VarList) {
		my $ctl_file = $ctl_pfx . "." . $idx . ".ctl";
		$CTLinfo{$idx}{"file"} = $ctl_file;
		$CTLinfo{$idx}{"dims"} = $dim_string;
		$CTLinfo{$idx}{"vars"} = $VarList{$dim_string};
		open(CTL, ">$ctl_file") || die("Cannot write CTL file $ctl_file\n");
		print CTL "DSET $file\n";
		print CTL "DTYPE netcdf\n";
		print CTL "TITLE CWRF OUTPUT FILE\n";
		print CTL "UNDEF 1.e20\n";
		print CTL "pdef 195 138 lcc 49.08019 -52.10626 195 138 30 60 -95.5 30000 30000\n";
		undef(my @dim_array);
		@dim_array = split(",", $dim_string);
		$CTLinfo{$idx}{"X"} = $CTLinfo{$idx}{"Y"} = $CTLinfo{$idx}{"Z"} = $CTLinfo{$idx}{"T"} = 0;
		my $tzyx = "";
		foreach my $dim_name (@dim_array) {
			next if($DimensionMapping{$dim_name} eq "");
			if($DimensionMapping{$dim_name} eq "X") {
				print CTL "XDEF " . $Dimensions{$dim_name} . " linear -135 0.4\n";
				$CTLinfo{$idx}{"X"} = $Dimensions{$dim_name};
				$tzyx .= "x,";
			} elsif($DimensionMapping{$dim_name} eq "Y") {
				print CTL "YDEF " . $Dimensions{$dim_name} . " linear 15 0.3\n";
				$CTLinfo{$idx}{"Y"} = $Dimensions{$dim_name};
				$tzyx .= "y,";
			} elsif($DimensionMapping{$dim_name} eq "Z") {
				print CTL "ZDEF " . $Dimensions{$dim_name} . " linear 1 1\n";
				$CTLinfo{$idx}{"Z"} = $Dimensions{$dim_name};
				$tzyx .= "z,";
			} elsif($DimensionMapping{$dim_name} eq "T") {
				print CTL "TDEF " . $Dimensions{$dim_name} . " Linear " . $Time[1] . " " . getTstep() . "\n";
				$CTLinfo{$idx}{"T"} = $Dimensions{$dim_name};
				$tzyx .= "t,";
			}
		}
		chop($tzyx);
		print CTL "XDEF 1 linear 1 1\n" if(!$CTLinfo{$idx}{"X"});
		print CTL "YDEF 1 linear 1 1\n" if(!$CTLinfo{$idx}{"Y"});
		print CTL "ZDEF 1 linear 1 1\n" if(!$CTLinfo{$idx}{"Z"});
		print CTL "TDEF 1 linear 1 1\n" if(!$CTLinfo{$idx}{"T"});

		my @vars = split(",", $VarList{$dim_string});
		print CTL "VARS " . @vars . "\n"; 
		foreach my $v (sort @vars) {
			print CTL $v . "=>" . $v . "\t" . $CTLinfo{$idx}{"Z"} . " " . $tzyx . "     Variable $v\n";
		}
		print CTL "ENDVARS\n";
		close(CTL);
		print "\tCTL file $ctl_file written.\n";

		$idx ++; # next CTL file
	}
	$MaxCtlIdx = $idx - 1;
}

sub GenerateGSfile() {
	print "\nGenerating GrADS GS file ... \n";
	open(GS, ">$gs_file") || die("Cannot generating GS file $gs_file.\n");

	my %VarFileIdx;
	print GS "'reinit'\n";
	foreach my $idx (sort keys %CTLinfo) {
		print GS "'open " . $CTLinfo{$idx}{"file"} . "'\n";
	}

	foreach my $idx (sort keys %CTLinfo) {
		foreach my $v (split(",", $CTLinfo{$idx}{"vars"})) {
			$VarFileIdx{$v} = $idx;	# remember which var is in which ctl file.
		}
	}

	$MaxVarLen += 2;
	print GS "while(1)\n";
	print GS "say '"; for(my $j=0; $j< $MaxVarLen * $varperline; $j++) { print GS "-"; } print GS "'\n";
	print GS "say 'Please choose vairable name from below or 0-$MaxCtlIdx by dimension:'\n";
	print GS "say '"; for(my $j=0; $j< $MaxVarLen * $varperline; $j++) { print GS "-"; } print GS "'\n";
	# var list 1 by 1:
	my $i = 0;
	foreach my $v (sort keys %VarFileIdx) {
		print GS "say '" if($i % $varperline == 0);
		print GS sprintf("%-".$MaxVarLen."s", $v);
		$i ++;
		print GS "'\n" if($i % $varperline == 0);
	}
	print GS "'\n" if($i % $varperline != 0);
	# choose vars by dimension:
	print GS "say '"; for(my $j=0; $j< $MaxVarLen * $varperline; $j++) { print GS "-"; } print GS "'\n";
	my $idx = 0;
	foreach $dim_string (keys %VarList) {
		print GS "say '$idx. " . TranslateDimension($dim_string) . " vars:'\n";
		print GS "say '\t" . $VarList{$dim_string} . "'\n";
		$idx ++;
	}
	print GS "say '"; for(my $j=0; $j< $MaxVarLen * $varperline; $j++) { print GS "-"; } print GS "'\n";
	print GS "say 'A: check all variables above, I: GrADS commandline, Q: quit'\n";
	print GS "say '"; for(my $j=0; $j< $MaxVarLen * $varperline; $j++) { print GS "-"; } print GS "'\n";
	print GS << "__GSMAIN1__";
pull v
idx=0
if(v = '')
else
  if(v = 'q' | v = 'Q')
    'quit'
  endif
  if(v = 'i' | v = 'I')
    break
    return
  endif
  if(v >= 0 & v <= $MaxCtlIdx)
__GSMAIN1__
	$idx = 0;
	foreach $dim_string (keys %VarList) {
		print GS "    if (v = $idx) \n";
		foreach my $v (sort split(",", $VarList{$dim_string})) {
			if(lc($v) ne lc($time_v)) {
				print GS "      if(loop('$v', 1) = 0); continue; endif\n";
			}
		}
		print GS "    endif\n";
		$idx ++;
	}
	print GS << "__GSMAIN2__";
  else
    if(v != 'a' & v != 'A')
      idx = CheckFileIdx(v)
      if(idx = 0) 
        say 'Variable 'v' not found.'
      else
        loop(v, 0)
      endif
    else
__GSMAIN2__
	foreach my $v (sort keys %VarFileIdx) {
		if(lc($v) ne lc($time_v)) {
			print GS "    if(loop('$v', 1) = 0); continue; endif\n";
		}
	}

	print GS << "__GSMAIN3__";
    endif
  endif
endif
endwhile

function loop(v, flag)
idx = CheckFileIdx(v)
maxZ = CheckFileMaxZ(v)
maxT = CheckFileMaxT(v)
t=1
while(t<=maxT)
  z=1
  while(z<=maxZ)
    'set t 't
    'set z 'z
    'c'
    'set grads off'
    'set map 0 1 12'
    say v' (Z='z', T='t')'
    'set gxout shaded'
    'd 'v'.'idx
    'draw title 'v' (Z='z', T='t')'
    'set gxout contour'
    'd 'v'.'idx
    if(flag = 0)
      say 'Press Enter to continue, Q to back to main menu'
    else
      say 'Press Enter to continue, Q to back to main menu, N to next var'
    endif
    pull vv
    if ((vv = 'q' | vv = 'Q') & flag = 0)
      return 1
    endif
    if ((vv = 'n' | vv = 'N') & flag = 1)
      return 1
    endif
    if ((vv = 'q' | vv = 'Q') & flag = 1)
      return 0
    endif
    z=z+1
  endwhile
  t=t+1
endwhile
return 1

__GSMAIN3__

	print GS "\nfunction CheckFileIdx(v)\nr=0\n";
	foreach my $idx (sort keys %CTLinfo) {
		foreach my $v (split(",", $CTLinfo{$idx}{"vars"})) {
			print GS "if (v = '" . $v . "' | v = '" . lc($v) . "') ; ";
			print GS "r=" . ($idx + 1) . " ; ";
			print GS "endif\n";
		}
	}
	print GS "return r\n\n\n";

	print GS "\nfunction CheckFileMaxZ(v)\n";
	foreach my $idx (sort keys %CTLinfo) {
		foreach my $v (split(",", $CTLinfo{$idx}{"vars"})) {
			print GS "if (v = '" . $v . "' | v = '" . lc($v) . "') ; ";
			my $maxZ = ($CTLinfo{$idx}{"Z"} > 0) ? $CTLinfo{$idx}{"Z"} : 1;
			print GS "r=" . $maxZ . " ; ";
			print GS "endif\n";
		}
	}
	print GS "return r\n\n\n";

	print GS "\nfunction CheckFileMaxT(v)\n";
	foreach my $idx (sort keys %CTLinfo) {
		foreach my $v (split(",", $CTLinfo{$idx}{"vars"})) {
			print GS "if (v = '" . $v . "' | v = '" . lc($v) . "') ; ";
			my $maxT = ($CTLinfo{$idx}{"T"} > 0) ? $CTLinfo{$idx}{"T"} : 1;
			print GS "r=" . $maxT . " ; ";
			print GS "endif\n";
		}
	}
	print GS "return r\n\n\n";

	close(GS);
	print "\tFile $gs_file generated.\n";
}

sub TranslateDimension($) {
	my($dim_str) = @_;
	$dim_str =~s/ //g;
	my @dim_arr = split(",", $dim_str);
	my $s = "", $s1 = "";
	while(my $d = pop @dim_arr) {
		$s  .= $Dimensions{$d} . "*";
		$s1 .= $d . ",";
	}
	chop($s); chop($s1);
	return "$s($s1)";
}

sub CheckGrads() {
	print "Checking GrADS  ... ";
	my $ver = "";
	open(HH, "$grads -help |") || die("Cannot run $grads -help.\n");
	while(<HH>) {
		if($_=~/GrADS Version\s*(\S*)\s*/i) {
			$ver = $1;
		}
	}
	close(HH);
	die("Executable '$grads' not found, please specify.\n") if($ver eq "");
	print "Ver $ver\n";
	return;
}

sub RunGrADS() {
	system("$grads -lc 'run $gs_file'");
}

sub dayofyear($$$) {
	my ($year, $month, $day) = @_;
	my $m, $d, $days=0;
	for($m=1; $m<$month; $m++) {
		$days += $MonthTotalDays{$m};
	}
	$days += $day;
	$days += isleap($year) if ($month > 2);
	return $days;
}

sub isleap($) {
	my ($y) = @_;
	return 1 if (( $y % 400 ) == 0 );
	return 0 if (( $y % 100 ) == 0 );
	return 1 if (( $y % 4 ) == 0 );
	return 0;
}

