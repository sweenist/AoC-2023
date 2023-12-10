package Modules::Day6;
use strict;
use warnings;

use Exporter qw( import );
our @ISA = qw( Exporter );
our @EXPORT_OK = qw( part_one part_two );

use String::Util qw( trim );
use POSIX;

#---------------------------------------------------------------------------


sub part_one {
	my ($file) = @_;

	my $time = <$file>;
	my $distance = <$file>;
	my %races = get_results($time, $distance);
	my $product = 1;

	for(keys %races){
		my $tolerance_count = quadrify($_, $races{$_});
		$product *= $tolerance_count;
	}
	return $product;
}

#---------------------------------------------------------------------------


sub part_two {
	my ($file) = @_;
	my $time = <$file>;
	my $distance = <$file>;
	$time = get_kern_values($time);
	$distance = get_kern_values($distance);

	my $tolerance_count = quadrify($time, $distance);
	return $tolerance_count;
}

#---------------------------------------------------------------------------


sub get_results {
	my @times = get_values(shift);
	my @distances = get_values(shift);

	my %results;
	my $array_len = @times;
	for(1..$array_len){
		my $index = $_ - 1;
		$results{$times[$index]} = $distances[$index];
	}
	return %results;
}


sub get_values {
	my $input = shift;
	my $values = (split /:/, $input)[1];
	return split /\s+/, trim($values);
}


sub get_kern_values {
	my $input = shift;
	my $values = (split /:/, $input)[1];
	$values =~ s/\s+//g;
	return $values;
}


sub quadrify {

	# -b +/- sqrt(discriminant()) / 2a
	my $b = shift;
	my $y_limit = shift;
	my $disc = discriminant($b, -$y_limit);

	my $root = sqrt($disc);
	my $lower_bound = ceil((-$b + $root)/-2);
	my $upper_bound = floor((-$b - $root)/-2);

	my $modifier = is_perfect_square($root) ? -1 : 1;

	# include first number, much like pages read unless the discriminant is a perfect square, the subtract (cheating)
	return $upper_bound - $lower_bound + $modifier;
}


sub is_perfect_square {
	my $root = shift;
	my $c = ceil($root);
	my $f = floor($root);

	return $c == $f;
}


sub discriminant {

	# b^2 - 4ac
	my $b = shift;
	my $c = shift;

	return $b**2 + 4*$c;
}

1;