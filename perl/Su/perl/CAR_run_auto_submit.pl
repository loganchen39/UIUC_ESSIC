#!/usr/bin/perl
use Cwd;

#--------------------------------------------------------------------------------
# Script to generate combination based on given namelist and submit PBS job automatically.
#
# Designed to run CAR system automatically.
# Can be used to run any executable based on namelist, modification needed.
#
# Know problems: 
#    1. max 10 multi-choice-parameters allowed.
#    2. submit job regardless of supercomputer job policy.
#
# Shenjian Su (zfsu79@illinois.edu), 20100109
#--------------------------------------------------------------------------------


#--------------------------------------------------------------------------------
# SETTINGS begin here.


$LN        = "ln -sf";												# system command
$QSUB      = "qsub";

$RUNDIR    = "";													# leave it blank if running in current dir

$INITDIR   = "/scratch2/scratchdirs/zfsu79/CAR_RUN/CRM_RUN/Init";	# path of 'Init' dir, shoule be absolute path

$DATAPATH  = " /u0/z/zfsu79/CAR/Ini_data/";							# path of data files
@DATAFILES = ("AMINPUT_GLOBE_128x256_pa",							# some data files, will be ln to each dir
		     "CAM_ABS_DATA",
		     "CAM_AEROPT_DATA",
		     "O3INPUT_GLOBE_2x2_pa",
		     "RRTM_DATA",
		     "VMINPUT_GLOBE_64x1_L18",
		     "random-order_mos.1-15",
		     "tr49t67",
		     "tr49t85",
		     "tr67t85" );

$RADEXE    = "rad.exe";												# rad.exe, in same dir with this script

$ISTART    = 14401;													# \_ JJA
$IEND      = 23232;													# /

$JOBCARDDIR= "job";													# job cards will be generated in this dir
$JOBFILEPRE= "run.job.";											# prefix of job card filename
$PBSQUEUE  = "premium";												# PBS job queue
$PBSWALLT  = "24:00:00";											# PBS job walltime
$PBSNAMEPRE= "CAR_com";												# prefix of PBS job name
$TASKPERJOB= 10;													# Max task per job card
$SUBMITJOBCARD = 1;													# submit job card after created

$NMLFILE   = "namelist_car";										# to be generated in each dir, all content will be generated in lowercase

$MAX_COMBINATION_CNT = 1000;										# max combinations
$APPEND_FIXED_PARAMETERS_IN_DIRNAME = 0;							# whether put the fixed parameters in dirname

@COMBINATIONS = (
	{   "dirname" 		=> "ccs",
		"namelist"		=> "scheme_ccs",
		"values"		=> [1, 2],
	},
	{   "dirname"		=> "ccb",
		"namelist"		=> "scheme_ccb",
		"values"		=> [3, 5],
	},
	{   "dirname"		=> "cst",
		"namelist"		=> "scheme_cst",
		"values"		=> [1],
	},
	{   "dirname"		=> "cci",
		"namelist"		=> "scheme_cci",
		"values"		=> [2],
	},
	{ 	"dirname"		=> "lwl",
		"namelist"		=> "scheme_cl_lwl",
		"values"		=> [2],
	},
	{	"dirname"		=> "lwi",
		"namelist"		=> "scheme_cl_lwi",
		"values"		=> [106, 401, 402],
	},
	{	"dirname"		=> "swi",
		"namelist"		=> "scheme_cl_swi",
		"values"		=> [106, 2, 402],
	},
	{ 	"dirname"		=> "swl",
		"namelist"		=> "scheme_cl_swl",
		"values"		=> [6],
	},
	{ 	"dirname"		=> "rei",
		"namelist"		=> "scheme_rei",
		"values"		=> [1, 6, 7],
	},
	{ 	"dirname"		=> "rel",
		"namelist"		=> "scheme_rel",
		"values"		=> [1],
	},
	{ 	"dirname"		=> "cwp",
		"namelist"		=> "scheme_cwp",
		"values"		=> [0],
	},
	{ 	"dirname"		=> "fice",
		"namelist"		=> "scheme_fice",
		"values"		=> [3],
	},
	{ 	"dirname"		=> "rer",
		"namelist"		=> "scheme_rer",
		"values"		=> [1],
	},
	{ 	"dirname"		=> "lwsw",
		"namelist"		=> "lw_physics,sw_physics",
		"values"		=> [1, 2, 3, 4, 6],
	},
);	# end of @COMBINATIONS

# end of SETTINGS.
#--------------------------------------------------------------------------------

$maindir = getcwd;
$RUNDIR = $maindir if($RUNDIR eq "" || $RUNDIR =~ /^\.(\/)?/i);
print "Running in $RUNDIR ...\n";

# %settings is a hash to save all sattings: $settings{'dirname'} = {'namelist1'=>value, 'namelist2'=>value, ...}
# data of %settings will be generated based on the array above.
%settings;
%namelist_names;
$fixed_dirname;		# the fixed parameters in dir name
generate_settings();

$dircount = 0;
chdir($RUNDIR);
print "2. Following directories will be generated in $RUNDIR: \n";
print "\t$JOBCARDDIR\n";
mkdir $JOBCARDDIR;
system("$LN $INITDIR ./Init");
foreach my $dir (sort keys %settings) {
	$dircount ++;
	chdir($RUNDIR);
	print sprintf("\t%4d, ", $dircount) . $dir . "\n";
	die("FATAL ERROR: $dir already exists.\n") if(-e "$dir");
#	foreach my $nml_name (sort keys %namelist_names) {
#		print  "\t\t$nml_name = " . $settings{$dir}{$nml_name} . "\n";
#	}

	mkdir $dir;
	build_environment($dir);
}
print "\n";

print "3. Generating job cards in $RUNDIR/$JOBCARDDIR: \n";
create_jobcard();

print "Done! Please check job status by yourself.\n\n";

#================================================================================
# subroutines:
sub generate_settings() {
	my %namelist;
	my @multichoiceparameters;
	my $parameter_cnt = 0;
	my $combination_cnt = 1;
	my $parameter_cnt = @COMBINATIONS;
	my $subcnt;
	print "1. Combinations:\n";
	foreach my $parameter (sort @COMBINATIONS) {
		print "\t" . $parameter->{'namelist'} . ": ";
		$subcnt = 0;
		my $v;
		my @tmparray = @{$parameter->{'values'}};
		foreach $v (@tmparray) {
			print $v . ", ";
			$subcnt ++;
		}
		$namelist_names{$parameter->{'namelist'}} = 1;
		if($subcnt  == 1) {	# only-1-choice parameter ('fixed' parameters): set it in dir name
			$fixed_dirname .= $parameter->{'dirname'} . $tmparray[0] . "_";
			$namelist{$parameter->{'namelist'}} = $tmparray[0];
		} else {			# multi-choice parameters only:
			$multi_choice_parameter_cnt ++;
			$tmp = "parameter_array_" . $multi_choice_parameter_cnt;
			@$tmp = @tmparray;
			$multichoiceparameters[$multi_choice_parameter_cnt] = {'dirname'=>$parameter->{'dirname'}, 'namelist'=>$parameter->{'namelist'}};
		}
		print "\n";
		$combination_cnt *= $subcnt;
	}
	chop($fixed_dirname);	# remove the tail "_"
	print "\tTotal $parameter_cnt parameters, $multi_choice_parameter_cnt of them have multi choices, total $combination_cnt combinations.\n\n";
	
	# 10 multi-choice parameters will generate at least 1024 combinations, that's huge.
	die("Too many combinations, are you crazy?!\n") if($combination_cnt > $MAX_COMBINATION_CNT || $multi_choice_parameter_cnt > 10);
	
	P1: foreach my $p1 (sort @parameter_array_1) {
		last P1 if($multi_choice_parameter_cnt < 1);
		$namelist{$multichoiceparameters[1]->{'namelist'}} = $p1;
		my $dn1 = $multichoiceparameters[1]->{'dirname'} . $p1 . "_";
	#	print $dn1 . "----1\n" if($multi_choice_parameter_cnt == 1);
		set_settings($dn1, %namelist) if($multi_choice_parameter_cnt == 1);
		P2: foreach my $p2 (sort @parameter_array_2) {
			last P2 if($multi_choice_parameter_cnt < 2);
			$namelist{$multichoiceparameters[2]->{'namelist'}} = $p2;
			my $dn2 = $multichoiceparameters[2]->{'dirname'} . $p2 . "_";
	#		print $dn1.$dn2. "----2\n" if($multi_choice_parameter_cnt == 2);
			set_settings($dn1.$dn2, %namelist) if($multi_choice_parameter_cnt == 2);
			P3: foreach my $p3 (sort @parameter_array_3) {
				last P3 if($multi_choice_parameter_cnt < 3);
				$namelist{$multichoiceparameters[3]->{'namelist'}} = $p3;
				my $dn3 = $multichoiceparameters[3]->{'dirname'} . $p3 . "_";
	#			print $dn1.$dn2.$dn3 . "----3\n" if($multi_choice_parameter_cnt == 3);
				set_settings($dn1.$dn2.$dn3, %namelist) if($multi_choice_parameter_cnt == 3);
				P4: foreach my $p4 (sort @parameter_array_4) {
					last P4 if($multi_choice_parameter_cnt < 4);
					$namelist{$multichoiceparameters[4]->{'namelist'}} = $p4;
					my $dn4 = $multichoiceparameters[4]->{'dirname'} . $p4 . "_";
	#				print $dn1.$dn2.$dn3.$dn4 . "----4\n" if($multi_choice_parameter_cnt == 4);
					set_settings($dn1.$dn2.$dn3.$dn4, %namelist) if($multi_choice_parameter_cnt == 4);
					P5: foreach my $p5 (sort @parameter_array_5) {
						last P5 if($multi_choice_parameter_cnt < 5);
						$namelist{$multichoiceparameters[5]->{'namelist'}} = $p5;
						my $dn5 = $multichoiceparameters[5]->{'dirname'} . $p5 . "_";
	#					print $dn1.$dn2.$dn3.$dn4.$dn5 . "----5\n" if($multi_choice_parameter_cnt == 5);
						set_settings($dn1.$dn2.$dn3.$dn4.$dn5, %namelist) if($multi_choice_parameter_cnt == 5);
						P6: foreach my $p6 (sort @parameter_array_6) {
							last P6 if($multi_choice_parameter_cnt < 6);
							$namelist{$multichoiceparameters[6]->{'namelist'}} = $p6;
							my $dn6 = $multichoiceparameters[6]->{'dirname'} . $p6 . "_";
	#						print $dn1.$dn2.$dn3.$dn4.$dn5.$dn6 . "----6\n" if($multi_choice_parameter_cnt == 6);
							set_settings($dn1.$dn2.$dn3.$dn4.$dn5.$dn6, %namelist )if($multi_choice_parameter_cnt == 6);
							P7: foreach my $p7 (sort @parameter_array_7) {
								last P7 if($multi_choice_parameter_cnt < 7);
								$namelist{$multichoiceparameters[7]->{'namelist'}} = $p7;
								my $dn7 = $multichoiceparameters[7]->{'dirname'} . $p7 . "_";
	#							print $dn1.$dn2.$dn3.$dn4.$dn5.$dn6.$dn7 . "----7\n" if($multi_choice_parameter_cnt == 7);
								set_settings($dn1.$dn2.$dn3.$dn4.$dn5.$dn6.$dn7, %namelist) if($multi_choice_parameter_cnt == 7);
								P8: foreach my $p8 (sort @parameter_array_8) {
									last P8 if($multi_choice_parameter_cnt < 8);
									$namelist{$multichoiceparameters[8]->{'namelist'}} = $p8;
									my $dn8 = $multichoiceparameters[8]->{'dirname'} . $p8 . "_";
	#								print $dn1.$dn2.$dn3.$dn4.$dn5.$dn6.$dn7.$dn8 . "----8\n" if($multi_choice_parameter_cnt == 8);
									set_settings($dn1.$dn2.$dn3.$dn4.$dn5.$dn6.$dn7.$dn8, %namelist) if($multi_choice_parameter_cnt == 8);
									P9: foreach my $p9 (sort @parameter_array_9) {
										last P9 if($multi_choice_parameter_cnt < 9);
										$namelist{$multichoiceparameters[9]->{'namelist'}} = $p9;
										my $dn9 = $multichoiceparameters[9]->{'dirname'} . $p9 . "_";
	#									print $dn1.$dn2.$dn3.$dn4.$dn5.$dn6.$dn7.$dn8.$dn9 . "----9\n" if($multi_choice_parameter_cnt == 9);
										set_settings($dn1.$dn2.$dn3.$dn4.$dn5.$dn6.$dn7.$dn8.$dn9, %namelist) if($multi_choice_parameter_cnt == 9);
										P10: foreach my $p10 (sort @parameter_array_10) {
											last P10 if($multi_choice_parameter_cnt < 10);
											$namelist{$multichoiceparameters[10]->{'namelist'}} = $p10;
											my $dn10 = $multichoiceparameters[10]->{'dirname'} . $p10 . "_";
	#										print $dn1.$dn2.$dn3.$dn4.$dn5.$dn6.$dn7.$dn8.$dn9.$dn10 . "----10\n" if($multi_choice_parameter_cnt == 10);
											set_settings($dn1.$dn2.$dn3.$dn4.$dn5.$dn6.$dn7.$dn8.$dn9.$dn10, %namelist) if($multi_choice_parameter_cnt == 10);
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
}

sub set_settings($%) {
	my ($dn, %nml) = @_;
	if($APPEND_FIXED_PARAMETERS_IN_DIRNAME) {
		$dn .= $fixed_dirname;
	} else {
		chop($dn);	# remove the tail "_"
	}
	foreach my $nml_name (sort keys %namelist_names) {
		$settings{$dn}{$nml_name} = $nml{$nml_name};
	}
	return 1;
}


sub build_environment($) {
	my ($dir) = @_;
	chdir($RUNDIR . "/" . $dir);

	# data files needed:
	foreach my $file (@DATAFILES) {
		system("$LN $DATAPATH/$file .");
	}	

	# exe:
	system("$LN $maindir/$RADEXE .");

	# namelist:
	create_namelist($dir);
	return 1;
}

sub create_namelist($) {
	my ($dir) = @_;
	my $file = $RUNDIR . "/" . $dir . "/" . $NMLFILE;
	open (NML, ">$file") || die("Cannot open file $file for write.\n");
	open (SAMPLE, "<$maindir/$NMLFILE") || die("Cannot open $maindir/$NMLFILE for read.\n");
	while(<SAMPLE>) {
		my $line = $_;
		chop($line);
		my $found = 0;
		foreach my $nml_name (sort keys %namelist_names) {
			my @parameters = split(",", $nml_name);
			foreach my $par (@parameters) {
				if($line =~ /\s*$par\s*=/i) {
					print NML "$par = " . $settings{$dir}{$nml_name} . "\n";
					$found = 1;
				}
			}
		}
		print NML $line . "\n" if(!$found);
	}
	close(SAMPLE);
	close(NML);
	return 1;
}

sub create_jobcard() {
	my $index = 1; 				# auto increasement, in job card file name and job name
	my $count = 0;
	my $file;
	my $mppwidth = $TASKPERJOB * 4;	# on franklin, 4core/node
	foreach my $dir (sort keys %settings) {
		if($count == 0) {
			$file = $JOBFILEPRE . $index;
			open(JOB, ">$RUNDIR/$JOBCARDDIR/$file") || die("Cannot open $file for write.\n");
			print JOB << "__PBSjobcardhead";
#PBS -N $PBSNAMEPRE$index
#PBS -q $PBSQUEUE
#PBS -l walltime=$PBSWALLT
#PBS -l mppwidth=$mppwidth
#PBS -V
#PBS -m n
#PBS -j eo

set TIME = `date +\%Y\%m\%d\%H\%M\%S`
set LOGFILE = "log.car.$index."\${TIME}

umask 022
unlimit

__PBSjobcardhead
		}

		print JOB << "__EachTask";
cd $RUNDIR/$dir/
aprun -n 1 ./$RADEXE $ISTART $IEND  >&! \${LOGFILE} &

__EachTask

		$count ++;

		if($count == $TASKPERJOB) {
			print JOB "\nwait\n";
			close(JOB);
			$index ++;
			$count = 0;
			if($SUBMITJOBCARD) {
				system("$QSUB $RUNDIR/$JOBCARDDIR/$file");
				print "\tJob card $file generated and submitted.\n";
			} else {
				print "\tJob card $file generated.\n";
			}
		}
	}
	if($count > 0 && $count < $TASKPERJOB) {	# the last file may contains less records
		print JOB "\nwait\n";
		close(JOB);
		if($SUBMITJOBCARD) {
			system("$QSUB $RUNDIR/$JOBCARDDIR/$file");
			print "\tJob card $file generated and submitted.\n";
		} else {
			print "\tJob card $file generated.\n";
		}
	} elsif($count == 0) {
		$index --;
	}

	print "\tTotal $index job card generated in dir $RUNDIR/$JOBCARDDIR/\n\n";
	return 1;
}
