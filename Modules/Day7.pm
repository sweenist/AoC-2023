package Modules::Day7;
use strict;
use warnings;

use Exporter qw( import );
our @ISA = qw( Exporter );
our @EXPORT_OK = qw( part_one part_two );

use feature qw( say );
use experimental qw( switch );
use List::AllUtils qw ( max );

#---------------------------------------------------------------------------


sub part_one {
	my ($file) = @_;
	my %hands;
	my $aggregate = 0;
	my (@fivek, @fourk, @fh, @threek, @twop, @onep, @def) = () x 7;

	while(my $line = <$file>) {
		chomp($line);
		my ($key, $value) = parse_pair($line);
		$hands{$key} = $value;
	}

	my @all_hands = keys %hands;
	my $total_hands = @all_hands;

	categorize(\@fivek, \@fourk, \@fh, \@threek, \@twop, \@onep, \@def, @all_hands);

	my @_5k = sort sort_hand @fivek;
	my @_4k = sort sort_hand @fourk;
	my @_fh = sort sort_hand @fh;
	my @_3k = sort sort_hand @threek;
	my @_2p = sort sort_hand @twop;
	my @_1p = sort sort_hand @onep;
	my @_lh = sort sort_hand @def;

	my @superset = ( @_lh, @_1p, @_2p, @_3k, @_fh, @_4k, @_5k );

	for(1..$total_hands) {
		my $index = $_ - 1;
		my $key = $superset[$index];
		my $value = $hands{$key};
		$aggregate += $_ * $value;
	}

	return $aggregate;
}

#---------------------------------------------------------------------------


sub part_two {
	my ($file) = @_;

	return "not implemented";
}

#---------------------------------------------------------------------------


sub parse_pair() {
	my $line = shift;
	my ($k, $v) = split /\s/, $line;

	$k = $k=~ s/A/14/gr =~ s/K/13/gr =~ s/Q/12/gr =~ s/J/11/gr =~ s/T/10/gr;

	my @return_list = ($k, $v);
	return @return_list;
}


sub categorize {
	my ($fivek, $fourk, $fh, $threek, $twop, $onep, $def, @hands) = @_;
	foreach my $hand (@hands) {
		my %counts;

		while ($hand =~ m/(1\d|[2-9])/g) {
			$counts{$1}++;
		}

		my $max_count = max values %counts;
		my $key_count = keys %counts;

		given($max_count) {
			when(5) { push @{$fivek}, $hand; }
			when(4) { push @{$fourk}, $hand; }

			when(3) {
				given($key_count) {
					when(2) { push @{$fh}, $hand }
					default { push @{$threek}, $hand }
				}
			}

			when(2) {
				given($key_count) {
					when(4) { push @{$onep}, $hand }
					when(3) { push @{$twop}, $hand }
				}
			}

			default { push @{$def}, $hand; }
		}
	}
}


sub sort_hand() {
	my @first = ();
	my @second = ();

	while ( $a =~ m/(1\d|[2-9])/g) { push @first, $1; }
	while ( $b =~ m/(1\d|[2-9])/g) { push @second, $1; }

	for(0..4) {
		if ($first[$_] == $second[$_]) { next; }
		return $first[$_] <=> $second[$_];
	}
	say "samesies $a and $b";
	return 0;
}

1;