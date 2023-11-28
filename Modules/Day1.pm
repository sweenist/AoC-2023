package Modules::Day1;

use Exporter qw( import );
our @ISA = qw( Exporter );
our @EXPORT_OK = qw( part_one part_two );

my %number_strings = (
	'one'   => 1,
	'two'   => 2,
	'three' => 3,
	'four'  => 4,
	'five'  => 5,
	'six'   => 6,
	'seven' => 7,
	'eight' => 8,
	'nine'  => 9,
	'zero'  => 0
);

my $totalCalibration = 0;
my %reverse_number_strings = ();

foreach(keys %number_strings) {
	$reverse_number_strings{(reverse $_)} = $number_strings{$_};
}
my $pattern = q"(\d|" . (join '|', keys %number_strings) . ")";
my $reverse_pattern = q"(\d|" . (join '|', keys %reverse_number_strings) . ")";

my $re_first = qr/$pattern/;
my $re_last = qr/$reverse_pattern/;

#---------------------------------------------------------------------------


sub part_one {
	my ($file) = @_;

	while(my $line = <$file>) {
		my $calibration;
		if($line =~ m/(\d)/){
			$calibration = $1;
		}
		if ($line =~ m/(\d)\D*\z/) {
			$calibration = $calibration.$1;
		}
		$totalCalibration += $calibration;
	}

	return $totalCalibration;
}


#---------------------------------------------------------------------------


sub part_two {
	my ($file) = @_;
	my $totalCalibration = 0;

	while(my $line = <$file>) {
		my $calibration;

		if($line =~ $re_first){
			$calibration = get_digit($1);
		}

		if ((reverse $line) =~ $re_last) {
			my $last = get_digit($1, 1);
			$calibration = $calibration.$last;
		}
		$totalCalibration += $calibration;
	}

	return $totalCalibration;
}

#---------------------------------------------------------------------------


sub get_digit {
	my ($token, $reverse) = @_;

	# $reverse = 0 unless (defined $reverse);
	return (length $token eq 1) ? $token : (defined $reverse && $reverse) ? %reverse_number_strings{$token} : %number_strings{$token};
}

1;