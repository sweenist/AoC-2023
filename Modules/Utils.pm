package Modules::Utils;
use strict;
use warnings;

use Exporter qw( import );
our @ISA = qw( Exporter );
our @EXPORT_OK = qw( lcm );

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

1;