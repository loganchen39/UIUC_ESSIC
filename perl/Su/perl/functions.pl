#!/usr/bin/perl

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


### check leap year
sub isleap($) {
	my ($y) = @_;
    return 1 if (( $y % 400 ) == 0 ); # 400's are leap
    return 0 if (( $y % 100 ) == 0 ); # Other centuries are not
    return 1 if (( $y % 4 ) == 0 );   # All other 4's are leap
    return 0;                         # Everything else is not
}

### return the total days of every month:
sub monthdays($$) {
	my ($year, $month) = @_;
	if ($month =~ /^0(\d)$/) { $month = $1; }
	return ($month == 2) ? $MonthTotalDays{$month} + isleap($year) : $MonthTotalDays{$month};
}

sub yyyymmdd($$$) {
	my ($y, $m, $d) = @_;
	my $r = $y;
	$r .= sprintf("%02d", $m);
	$r .= sprintf("%02d", $d);
	return $r;
}

### previous day of given date
sub previousday($$$$) {
	my ($year, $month, $day, $zero) = @_;
	if ($month =~ /^0(\d)$/) { $month = $1; }
	if ($day   =~ /^0(\d)$/) { $day   = $1; }
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
	return ( 'year' => $year_p, 'month' => $month_p, 'day' => $day_p, 'yyyymmdd' => $year_p.$month_p.$day_p);
}

### next day of given date
sub nextday($$$$) {
	my ($year, $month, $day, $zero) = @_;
	if ($month =~ /^0(\d)$/) { $month = $1; }
	if ($day   =~ /^0(\d)$/) { $day   = $1; }
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
	return ('year' => $year_n, 'month' => $month_n, 'day' => $day_n, 'yyyymmdd' => $year_n.$month_n.$day_n);
}

### number of days in a year:
sub dayofyear($$$$) {
	my ($year, $month, $day, $zero) = @_;
	if ($month =~ /^0(\d)$/) { $month = $1; }
	if ($day   =~ /^0(\d)$/) { $day   = $1; }
	my $m, $d, $days=0;
	for($m=1; $m<$month; $m++) {
		$days += $MonthTotalDays{$m};
	}
	$days += $day;
	$days += isleap($year) if ($month > 2);
	$days = sprintf("%03d", $days) if($zero);
	return $days;
}

# translate 1-365 to YYYYMMDD
sub doy2date($$) {
	my($y, $n) = @_;
	for(my $m=1; $m<=12; $m++) {
		for(my $d=1; $d<=monthdays($y,$m); $d++) {
			if(dayofyear($y, $m, $d, 0) == $n) {
				return my %r = (
					'year'	=> $y,
					'month' => $m,
					'day'	=> $d,
				);
			}
		}
	}
}

sub checkdate($$$) {
	my ($year, $month, $day) = @_;
	if ($month =~ /^0(\d)$/) { $month = $1; }
	if ($day   =~ /^0(\d)$/) { $day   = $1; }
	return 0 if(length($year) != 4);
	return 0 if($month < 1 or $month > 12);
	return 0 if($day < 1 or $day > $MonthTotalDays{$month} + isleap($year) );
	return 1;
}

sub modeldate($$$$) {
	my ($year, $month, $day, $zero) = @_;
	if ($month =~ /^0(\d)$/) { $month = $1; }
	if ($day   =~ /^0(\d)$/) { $day   = $1; }
	my $m = $month;
	my $d = $day;
	my $m_days = ($month - 1) * 30 + 1;
	for($m=1; $m<=12; $m++) {
		for($d=1; $d<=$MonthTotalDays{$month} + isleap($year); $d++) {
			if(dayofyear($year, $m, $d, 0) == $m_days) {
				$m      = sprintf("%02d", $m     ) if($zero);
				$d      = sprintf("%02d", $d     ) if($zero);
				$m_days = sprintf("%03d", $m_days) if($zero);
				return ('year' => $year, 'month' => $m, 'day' => $d, 'yyyymmdd' => $year.$m.$d, 'days' => $m_days);
			}
		}
	}
	$m      = sprintf("%02d", $month ) if($zero);
	$d      = sprintf("%02d", $day   ) if($zero);
	$m_days = sprintf("%03d", $m_days) if($zero);
	return ('year' => $year, 'month' => $m, 'day' => $d, 'yyyymmdd' => $year.$m.$d, 'days' => $m_days);
}

sub date_between($$$$$$) {
	my($sy, $sm, $sd, $ey, $em, $ed) = @_;
	my $minus = dayofyear($sy, $sm, $sd, 0) - 1;
	my $count = 0;
	for(my $y = $sy; $y < $ey; $y ++) {
		$count += dayofyear($y, 12, 31, 0);
	}
	$count += dayofyear($ey, $em, $ed, 0);
	$count -= $minus;
	return $count;
}

sub getCurrentTime($) {
	my ($zero) = @_;
	my ($sec,$min,$hour,$day,$mon,$year,undef,undef,undef) = localtime(time);
	my $yyyymmdd = "";
	my $hhmmss = "";
	$year += 1900;
	$mon ++;
	if($zero) {
		$mon = sprintf("%02d", $mon);
		$day = sprintf("%02d", $day);
		$hour= sprintf("%02d", $hour);
		$min = sprintf("%02d", $min);
		$sec = sprintf("%02d", $sec);
	}
	$yyyymmdd  = $year;
	$yyyymmdd .= sprintf("%02d", $mon);
	$yyyymmdd .= sprintf("%02d", $day);
	$hhmmss    = sprintf("%02d", $hour);
	$hhmmss   .= sprintf("%02d", $min);
	$hhmmss   .= sprintf("%02d", $sec);
	return (
		'year' 		=> 	$year,
		'month'		=>	$mon,
		'day'		=>	$day,
		'hour'		=>	$hour,
		'minute'	=>	$min,
		'second'	=>	$sec,
		'yyyymmdd'	=>	$yyyymmdd,
		'hhmmss'	=>	$hhmmss
	);
}

sub setenv($$) {
	my ($var, $val) = @_;
	$ENV{$var} = $val;
	return;
}

sub getenv($) {
	my ($var) = @_;
	return $ENV{$var};
}

sub showenv() {
	system("env");
	return;
}

1;
