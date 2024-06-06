#!/usr/bin/perl

$file = $ARGV[0];
$exp1 = $ARGV[1];
$exp2 = $ARGV[2];
$output_file = $ARGV[3];
if($output_file eq "") {
	print "\nUsage: $0 Data_File  Variable1  Variralb2  Output_File\n";
	print "\tVariables are some expression of the label (1st line of Data_File).\n";
	print "\tonly +-*/ operands supported in the expression.\n";
	print "\te.g: $0 Data_File 'WDEP_ASO4T+WDEP_SO2' Observation result_file\n";
	print "\t     to compute the Bias,NB,GE,NGE,RMSE,R of 'WDEP_ASO4T+WDEP_SO2' and 'Observation'.\n\n";
	exit;
}

%SubDomainName = (0=>"All", 1=>"NE", 2=>"MW", 3=>"CA", 4=>"TX", 5=>"SE");
my @domainid, @v1, @v2;
my %AllDomainID;
my %exp1ana, %exp2ana;
open(FH, "<$file") || die("Cannot optn $file for read.\n");
$j = 0;
$line_number = 0;
while(<FH>) {
	$line_number ++;
	$line = $_;
	chop($line);
	@items = split(",", $line);
	$columns = @items;
	if($line_number == 1) {
		$idxdomain = 0;
		%exp1ana = AnalysisExpression($exp1);
		%exp2ana = AnalysisExpression($exp2);
		for($i=0; $i<$columns; $i++) {
			$items[$i] =~s/\s//g;
			$idxdomain = $i if(lc($items[$i]) eq "subdomainid");

			foreach $e (sort keys %exp1ana) {
				if(lc($exp1ana{$e}{"type"}) eq "variable" && lc($items[$i]) eq lc($exp1ana{$e}{"value"})) {
					$exp1ana{$e}{"index"} = $i;
				}
			}
			foreach $e (sort keys %exp2ana) {
				if(lc($exp2ana{$e}{"type"}) eq "variable" && lc($items[$i]) eq lc($exp2ana{$e}{"value"})) {
					$exp2ana{$e}{"index"} = $i;
				}
			}
		}
		die("Column 'SubDomainID' not found in label of data file $file.\n") if($idxdomain == 0);
		foreach $e (sort keys %exp1ana) {
			if(lc($exp1ana{$e}{"type"}) eq "variable" && $exp1ana{$e}{"index"} == -1) {
				print "Variable " . $exp1ana{$e}{"value"} . " not found in label of data file $file.\n";
				exit;
			}
		}
		foreach $e (sort keys %exp2ana) {
			if(lc($exp2ana{$e}{"type"}) eq "variable" && $exp2ana{$e}{"index"} == -1) {
				print "Variable " . $exp2ana{$e}{"value"} . " not found in label of data file $file.\n";
				exit;
			}
		}

		print "Using '$exp1' and '$exp2' as the 2 data series for computing statistics, following are the 1st 10 records:\n";
		print "SubDomainID\t$exp1\t$exp2\n";
	}
	next if($items[$idxdomain] !~/\d/);

	$domainid[$j] = $items[$idxdomain];
	$domainid[$j] =~s/\s//g;
	$AllDomainID{$domainid[$j]} = 1;

# var2:
	$tempstr = "";
	foreach $e (sort keys %exp2ana) {
		if(lc($exp2ana{$e}{"type"}) eq "variable") {
			$tempstr .= $items[$exp2ana{$e}{"index"}];
		} else {
			$tempstr .= $exp2ana{$e}{"value"};
		}
	}
	if(eval($tempstr) == 0) {
		print "Warning: found $exp2 is 0.0 at line $line_number, skip.\n";
		next;
	}
	$v2[$j] = eval($tempstr);

#var1:
	$tempstr = "";
	foreach $e (sort keys %exp1ana) {
		if(lc($exp1ana{$e}{"type"}) eq "variable") {
			$tempstr .= $items[$exp1ana{$e}{"index"}];
		} else {
			$tempstr .= $exp1ana{$e}{"value"};
		}
	}
	$v1[$j] = eval($tempstr);

	print $domainid[$j] . "\t\t" . $v1[$j] . "\t\t" . $v2[$j] . "\n" if($j < 10);
	$j ++;
}
close(FH);
$AllDomainID{"0"} = 1;
$total_records = $j;

print "Computing Mean ... ";
my %cnt, %mean;
for($i=0; $i<$total_records; $i++) {
	$sdid = $domainid[$i];
	if($sdid > 0) {
		$cnt{$sdid} ++;
		$mean{"v1"}{$sdid} += $v1[$i];
		$mean{"v2"}{$sdid} += $v2[$i];
	}
	$cnt{"0"} ++;
	$mean{"v1"}{0} += $v1[$i];
	$mean{"v2"}{0} += $v2[$i];
}

foreach $sdid (sort keys %AllDomainID) {
	$mean{"v1"}{$sdid} /= $cnt{$sdid} if($cnt{$sdid});
	$mean{"v2"}{$sdid} /= $cnt{$sdid} if($cnt{$sdid});
}
print "OK, $exp1=" . $mean{"v1"}{0} . ", $exp2=" . $mean{"v2"}{0} . "\n\n";

print "Computing StdErr ... ";
my %stderr;
for($i=0; $i<$total_records; $i++) {
	$sdid = $domainid[$i];
	if($sdid > 0) {
		$stderr{"v1"}{$sdid} += ($v1[$i] - $mean{"v1"}{$sdid}) ** 2;
		$stderr{"v2"}{$sdid} += ($v2[$i] - $mean{"v2"}{$sdid}) ** 2;
	}
	$stderr{"v1"}{0} += ($v1[$i] - $mean{"v1"}{0}) ** 2;
	$stderr{"v2"}{0} += ($v2[$i] - $mean{"v2"}{0}) ** 2;
}

foreach $sdid (sort keys %AllDomainID) {
	$stderr{"v1"}{$sdid} = sqrt($stderr{"v1"}{$sdid} / $cnt{$sdid}) if($cnt{$sdid});
	$stderr{"v2"}{$sdid} = sqrt($stderr{"v2"}{$sdid} / $cnt{$sdid}) if($cnt{$sdid});
}
print "OK, $exp1=" . $stderr{"v1"}{0} . ", $exp2=" . $stderr{"v2"}{0} . "\n\n";

print "Computing Bias, NBias, GE, NGE, RMSE, and R ... ";
my %statis;
for($i=0; $i<$total_records; $i++) {
	$sdid = $domainid[$i];
	if($sdid > 0) {
		$statis{$sdid}{"bias"}  +=     $v1[$i] - $v2[$i];
		$statis{$sdid}{"nbias"} +=    ($v1[$i] - $v2[$i]) / $v2[$i];
		$statis{$sdid}{"ge"}    += abs($v1[$i] - $v2[$i]);
		$statis{$sdid}{"nge"}   += abs($v1[$i] - $v2[$i]) / $v2[$i];
		$statis{$sdid}{"rmse"}  +=    ($v1[$i] - $v2[$i]) ** 2;
		$statis{$sdid}{"r"}     +=   (($v1[$i] - $mean{"v1"}{$sdid}) / $stderr{"v1"}{$sdid})
		                         *   (($v2[$i] - $mean{"v2"}{$sdid}) / $stderr{"v2"}{$sdid});
	}
	$statis{0}{"bias"}  +=     $v1[$i] - $v2[$i];
	$statis{0}{"nbias"} +=    ($v1[$i] - $v2[$i]) / $v2[$i];
	$statis{0}{"ge"}    += abs($v1[$i] - $v2[$i]);
	$statis{0}{"nge"}   += abs($v1[$i] - $v2[$i]) / $v2[$i];
	$statis{0}{"rmse"}  +=    ($v1[$i] - $v2[$i]) ** 2;
	$statis{0}{"r"}     +=   (($v1[$i] - $mean{"v1"}{0}) / $stderr{"v1"}{0})
	                     *   (($v2[$i] - $mean{"v2"}{0}) / $stderr{"v2"}{0});
}

foreach $sdid (sort keys %AllDomainID) {
	$statis{$sdid}{"bias"}  /= $cnt{$sdid} if($cnt{$sdid});
	$statis{$sdid}{"nbias"} /= $cnt{$sdid} if($cnt{$sdid});
	$statis{$sdid}{"ge"}    /= $cnt{$sdid} if($cnt{$sdid});
	$statis{$sdid}{"nge"}   /= $cnt{$sdid} if($cnt{$sdid});
	$statis{$sdid}{"rmse"}  /= $cnt{$sdid} if($cnt{$sdid});
	$statis{$sdid}{"r"}     /= $cnt{$sdid} if($cnt{$sdid});
	$statis{$sdid}{"rmse"}   = sqrt($statis{$sdid}{"rmse"});
}
print "OK\n\n";

print "Generating output file $output_file ... ";
open(FO, ">>$output_file") || die("Cannot open $output_file for write.\n");
print FO "Var1=$exp1 and Var2=$exp2 of file $file:\n";
foreach $sdid (sort keys %AllDomainID) {
	print FO "Domain= " . $SubDomainName{$sdid} . ", Bias, NBias, GE, NGE, RMSE and R =\n";
	print FO $statis{$sdid}{"bias"}  . "\n"; 
	print FO $statis{$sdid}{"nbias"} . "\n"; 
	print FO $statis{$sdid}{"ge"}    . "\n"; 
	print FO $statis{$sdid}{"nge"}   . "\n"; 
	print FO $statis{$sdid}{"rmse"}  . "\n"; 
	print FO $statis{$sdid}{"r"}     . "\n\n"; 
}
print FO "\n\n\n";
close(FO);
print "OK.\n\n";

sub AnalysisExpression($) {
	my($exp) = @_;
	my @items;
	$exp =~s/\s//g;
	$exp =~s/\+/ \+ /g;
	$exp =~s/\-/ \- /g;
	$exp =~s/\*/ \* /g;
	$exp =~s/\// \/ /g;
	my @items = split(/\ /g, $exp);
	my $i = 0;
	my $item;
	my %ret;
	foreach $item (@items) {
		$i ++;
		if($item =~ /^[\+,\-,\*,\/]$/) {
			$ret{$i}{"value"} = $item;
			$ret{$i}{"type"}  = "operand";
			$ret{$i}{"index"} = -1;
		} elsif($item=~/^([\d,\.]+)$/) {
			$ret{$i}{"value"} = $item;
			$ret{$i}{"type"}  = "number";
			$ret{$i}{"index"} = -1;
		} else {
			$ret{$i}{"value"} = $item;
			$ret{$i}{"type"}  = "variable";
			$ret{$i}{"index"} = -1;
		}
	}
# for debug:
#	foreach $i (sort keys %ret) {
#		print $ret{$i}{"value"} . "-----" . $ret{$i}{"type"} . "\n";
#	}
	return %ret;
}
