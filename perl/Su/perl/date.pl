#!/usr/bin/perl
use Getopt::Long;
use Switch;

######################################################################
#
# This file is to calculate related datetime
#
# Usage:
#   $0 -o OPERATION [-y YEAR [-m MONTH [-d DAY]]] [-l Y]
#
# OPERATION="ISLEAPYEAR"  : to check whether YEAR is a leap year
#   sample: $0 -o ISLEAPYEAR -y 2002
#   return: 0 
#
# OPERATION="MONTHDAYS"   : to get how many days of YEAR-MONTH
#   sample: $0 -o MONTHDAYS -y 2004 -m 2
#   return: 29
#
# OPERATION="PREVIOUSDAY" : to get the previous day of given date
#   sample: $0 -o PREVIOUSDAY -y 2002 -m 1 -d 1
#   return: 2001 12 31
#
# OPERATION="NEXTDAY"     : to get the next day of given date
#   sample: $0 -o PREVIOUSDAY -y 2001 -m 12 -d 31
#   return: 2002 1 1
#
# OPERATION="DAYOFYEAR"   : to calculate the DayOfYear of given date
#   sample: $0 -o PREVIOUSDAY -y 2001 -m 2 -d 1
#   return: 32
#
# OPERATION="CHECKDATE"   : to check given date is valid or not
#   sample: $0 -o CHECKDATE -y 2001 -m 2 -d 29
#   return: 0
#
# OPERATION="MODELDATE"   : to get the model data of given date
#   sample: $0 -o MODELDATE -y 2002 -m 7 -d 1
#   return: 2002 6 30 181
#
# Author: zfsu.709@gmail.com, 2009-03-04
#
######################################################################

%MonthTotalDays = ( 1 => 31,
			        2 => 28,
			        3 => 31,
			        4 => 30,
			        5 => 31,
			        6 => 30,
			        7 => 31,
			        8 => 31,
			        9 => 30,
			       10 => 31,
			       11 => 30,
			       12 => 31);

GetOptions ("operation|o=s"   => \$operation,
            "year|y=i"        => \$year,
            "month|m=i"       => \$month,
            "day|d=i"         => \$day,
			"leadingzero|l=s" => \$leadingzero);

$zero = (uc($leadingzero) eq "Y") ? 1 : 0;

# Notice: from now on, $year, $month, $day $zero is global variables

### show help
sub help() {
	print << "__EOH__";

    Usage: $0 -o OPERATION [-y YEAR [-m MONTH [-d DAY]]] [-l Y]

    OPERATION:
        ISLEAPYEAR   : to check whether YEAR is a leap year
        MONTHDAYS    : to get how many days of YEAR-MONTH
        PREVIOUSDAY  : to get the previous day of given date
        NEXTDAY      : to get the next day of given date
        DAYOFYEAR    : to calculate the DayOfYear of given date
        CHECKDATE    : to check given date is valid or not
        MODELDATE    : to get the model data of given date

    -l Y             : with leading zero

__EOH__
	exit;
}


switch (uc($operation)) {
	case "ISLEAPYEAR"  { handle_isleapyear();  }
	case "MONTHDAYS"   { handle_monthdays();   }
	case "PREVIOUSDAY" { handle_previousday(); }
	case "NEXTDAY"     { handle_nextday();     }
	case "DAYOFYEAR"   { handle_dayofyear();   }
	case "CHECKDATE"   { handle_checkdate();   }
	case "MODELDATE"   { handle_modeldate();   }
	else               { help();               }
}

######################## handles ######################################

sub handle_isleapyear() {
	help() if (!$year);
	print isleap($year) . "\n";
}

sub handle_monthdays() {
	help() if (!$year || !$month);
	print monthdays() . "\n";
}

sub handle_previousday() {
	help() if (!$year || !$month || !$day);
	my %pd = previousday();
	print $pd{'year'} . " " . $pd{'month'} . " " . $pd{'day'} . "\n";
}

sub handle_nextday() {
	help() if (!$year || !$month || !$day);
	my %nd = nextday();
	print $nd{'year'} . " " . $nd{'month'} . " " . $nd{'day'} . "\n";
}

sub handle_dayofyear() {
	help() if (!$year || !$month || !$day);
	print dayofyear($year, $month, $day) . "\n";
}

sub handle_checkdate() {
	help() if (!$year || !$month || !$day);
	print checkdate() . "\n";
}

sub handle_modeldate() {
	help() if (!$year || !$month || !$day);
	my %md = modeldate();
	print $md{'year'} . " " . $md{'month'} . " " . $md{'day'} . " " . $md{'days'} . "\n";
}

######################### subroutines #################################

### check leap year
sub isleap($) {
	my ($y) = @_;
    return 1 if (( $y % 400 ) == 0 ); # 400's are leap
    return 0 if (( $y % 100 ) == 0 ); # Other centuries are not
    return 1 if (( $y % 4 ) == 0 );   # All other 4's are leap
    return 0;                         # Everything else is not
}

### return the total days of every month:
sub monthdays() {
	return ($month == 2) ? $MonthTotalDays{$month} + isleap($year) : $MonthTotalDays{$month};
}

### previous day of given date
sub previousday() {
	my $year_p = $year;
	my $month_p = $month;
	my $day_p = $day;
	$day_p --;
	if($day_p == 0) {
		$month_p --;
		if($month_p == 0) {
			$year_p --;
			$month_p = 12;
		}
		if($month_p == 2) {
			$day_p = $MonthTotalDays{$month_p} + isleap($year_p);
		} else {
			$day_p = $MonthTotalDays{$month_p} ;
		}
	}
	$month_p = sprintf("%02d", $month_p) if($zero);
	$day_p   = sprintf("%02d", $day_p  ) if($zero);
	return ( 'year' => $year_p, 'month' => $month_p, 'day' => $day_p);
}

### next day of given date
sub nextday() {
	my $year_n = $year;
	my $month_n = $month;
	my $day_n = $day;
	my $tmp;
	if($month_n == 2) {
		$tmp =  $MonthTotalDays{$month_n} + isleap($year_n);
	} else {
		$tmp = $MonthTotalDays{$month_n};
	}
	$day_n ++;
	if($day_n > $tmp) {
		$month_n ++;
		if($month_n > 12) {
			$year_n ++;
			$month_n = 1;
		}
		$day_n = 1;
	}
	$month_n = sprintf("%02d", $month_n) if($zero);
	$day_n   = sprintf("%02d", $day_n  ) if($zero);
	return ('year' => $year_n, 'month' => $month_n, 'day' => $day_n);
}

### number of days in a year:
sub dayofyear($$$) {
	my ($year, $month, $day) = @_;
	my $m, $d, $days=0;
	for($m=1; $m<$month; $m++) {
		$days += $MonthTotalDays{$m};
	}
	$days += $day;
	$days += isleap($year) if ($month > 2);
	$days = sprintf("%03d", $days) if($zero);
	return $days;
}

sub checkdate() {
	return 0 if(length($year) != 4);
	return 0 if($month < 1 or $month > 12);
	return 0 if($day < 1 or $day > $MonthTotalDays{$month} + isleap($year) );
	return 1;
}

sub modeldate() {
	my $m = $month;
	my $d = $day;
	my $m_days = ($month - 1) * 30 + 1;
	for($m=1; $m<=12; $m++) {
		for($d=1; $d<=$MonthTotalDays{$month} + isleap($year); $d++) {
			if(dayofyear($year, $m, $d) == $m_days) {
				$m      = sprintf("%02d", $m     ) if($zero);
				$d      = sprintf("%02d", $d     ) if($zero);
				$m_days = sprintf("%03d", $m_days) if($zero);
				return ('year' => $year, 'month' => $m, 'day' => $d, 'days' => $m_days);
			}
		}
	}
	$m      = sprintf("%02d", $month ) if($zero);
	$d      = sprintf("%02d", $day   ) if($zero);
	$m_days = sprintf("%03d", $m_days) if($zero);
	return ('year' => $year, 'month' => $m, 'day' => $d, 'days' => $m_days);
}

1;
