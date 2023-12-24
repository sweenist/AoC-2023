package Modules::Utils;
use strict;
use warnings;

use Exporter qw( import );
our @ISA = qw( Exporter );
our @EXPORT_OK = qw( lcm get_upper_bound intersect transpose );

use List::AllUtils qw( product any uniq );
use feature qw( say );

#---------------------------------------------------------------------------


sub lcm {
	my $ref_members = shift;
	my $debug = shift;
	my @members = sort { $b <=> $a } @{$ref_members};
	@members = uniq @members;
	my @factors;

	my $prime = 2;
	my $member_count = @members;
	$member_count--; #index is 0 based
	if($debug) { say "\tmembers ".join ',', @members; }

	while(any {$_ > 1} @members) {
		my $found_factor = 0;
		for(0..$member_count) {
			if (not $members[$_] % $prime) { # confusing, but 0 is falsy and if mod $prime is 0, do stuff
				$found_factor = 1;
				$members[$_] /= $prime;
			}
		}

		push @factors, $prime if $found_factor;
		$prime = next_prime($prime) unless $found_factor;
		if($debug && $found_factor){
			say "factors ".join ',', @factors;
			say "\tmembers ".join ',', @members;
		}
	}

	return product @factors;
}


sub next_prime() {
	my $current = shift;
	die ("undefined arg \$current") unless $current;

	return 3 if $current == 2;
	return $current + 2;
}

#---------------------------------------------------------------------------


sub get_upper_bound {
	my $array_ref = shift;
	my $debug = shift;

	my $array_length = @{$array_ref};
	if($debug) {
		say "Array ref $array_ref";
		say "array length = $array_length";
	}
	return $array_length - 1;
}

#---------------------------------------------------------------------------


sub intersect {
	my $array_ref1 = shift;
	my $array_ref2 = shift;

	my @first = @$array_ref1;
	my @second = @$array_ref2;
	my %intersect;

	++$intersect{$_} for @first;
	return grep {--$intersect{$_} >= 0} @second;
}

#---------------------------------------------------------------------------


sub transpose() {

	# Takes an Array of arrays and returns its rotational transform (fakely)
	# akin to zip in python. zip in AllUtils doesn't quite do it

	my $matrix_ref = shift;

	my @return = ();

	#seed the return
	my @top_row = @{@$matrix_ref[0]};
	for (@top_row) {
		push @return, [ $_ ];
	}

	my $height = @{$matrix_ref};

	for(1..$height - 1) {
		my @row = @{@$matrix_ref[$_]};
		my $i = 0;
		for my $v (@row) {
			push @{$return[$i]}, $v;
			$i++;
		}
	}

	return \@return;
}

1;