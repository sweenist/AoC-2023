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
	my %hands;
	my $aggregate = 0;
	my (@fivek, @fourk, @fh, @threek, @twop, @onep, @def) = () x 7;

	while(my $line = <$file>) {
		chomp($line);
		my ($key, $value) = parse_pair_with_wild($line);
		$hands{$key} = $value;
	}

	my @all_hands = keys %hands;
	my $total_hands = @all_hands;

	categorize_wildcards(\@fivek, \@fourk, \@fh, \@threek, \@twop, \@onep, \@def, @all_hands);

	my @_5k = sort sort_hand @fivek;
	my @_4k = sort sort_hand @fourk;
	my @_fh = sort sort_hand @fh;
	my @_3k = sort sort_hand @threek;
	my @_2p = sort sort_hand @twop;
	my @_1p = sort sort_hand @onep;
	my @_lh = sort sort_hand @def;

	say "5 of a kind";
	for(@_5k) {say "\t$_";}

	say "4 of a kind";
	for(@_4k) {say "\t$_";}

	say "Full house";
	for(@_fh) {say "\t$_";}

	say "3 of a kind";
	for(@_3k) {say "\t$_";}

	say "2 pair";
	for(@_2p) {say "\t$_";}

	say "1 pair";
	for(@_1p) {say "\t$_";}

	say "low";
	for(@_lh) {say "\t$_";}

	my @superset = ( @_lh, @_1p, @_2p, @_3k, @_fh, @_4k, @_5k );

	for(1..$total_hands) {
		my $index = $_ - 1;
		my $key = $superset[$index];
		my $value = $hands{$key};

		# say "$_: key: $key value: $value";
		$aggregate += $_ * $value;
	}
	return $aggregate;
}

#---------------------------------------------------------------------------


sub parse_pair() {
	my $line = shift;
	my ($k, $v) = split /\s/, $line;

	$k = $k=~ s/A/14/gr =~ s/K/13/gr =~ s/Q/12/gr =~ s/J/11/gr =~ s/T/10/gr;

	my @return_list = ($k, $v);
	return @return_list;
}


sub parse_pair_with_wild() {
	my $line = shift;
	my ($k, $v) = split /\s/, $line;

	$k = $k=~ s/A/14/gr =~ s/K/13/gr =~ s/Q/12/gr =~ s/J/0/gr =~ s/T/11/gr;

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


sub categorize_wildcards {
	my ($fivek, $fourk, $fh, $threek, $twop, $onep, $def, @hands) = @_;
	foreach my $hand (@hands) {
		my %counts;
		my $wild_count = 0;

		while ($hand =~ m/(1\d|[2-9])/g) {
			$counts{$1}++;
		}
		while ($hand =~ m/(0)/g) {
			$wild_count++;
		}

		my $max_count = max values %counts;
		my $key_count = keys %counts;

		given($max_count) {
			when(5) { push @{$fivek}, $hand; }
			when(4) {
				given($wild_count) {
					when(1) { push @{$fivek}, $hand; }
					default { push @{$fourk}, $hand; }
				}
			}
			when(3) {
				given($key_count) {
					when(3) { push @{$threek}, $hand; }
					when(2) {
						if($wild_count) { push @{$fourk}, $hand; }
						else { push @{$fh}, $hand; }
					}
					when(1) {
						if($wild_count)  { push @{$fivek}, $hand; }
						else { die("$hand illegal. m:$max_count; k:$key_count; w:$wild_count"); }
					}
				}
			}

			when(2) {
				given($key_count) {
					when(4) { push @{$onep}, $hand; }
					when(3) {
						if($wild_count) { push @{$threek}, $hand; }
						else { push @{$twop}, $hand; }
					}
					when(2) {
						given($wild_count) {
							when(2) { push @{$fourk}, $hand; }
							when(1) { push @{$fh}, $hand; }
							default { die("$hand illegal. m:$max_count; k:$key_count; w:$wild_count"); }
						}
					}
					when(1) {
						if($wild_count == 3) { push @{$fivek}, $hand; }
						else { die("$hand illegal. m:$max_count; k:$key_count; w:$wild_count"); }
					}
				}
			}
			when(1) {
				given($key_count) {
					when(1) { push @{$fivek}, $hand; }
					when(2) { push @{$fourk}, $hand; }
					when(3) { push @{$threek}, $hand; }
					when(4) { push @{$onep}, $hand; }
					default	{ push @{$def}, $hand; }
				}
			}

			default { push @{$fivek}, $hand; } #has to be 5 wilds
		}
	}
}


sub sort_hand() {
	my @first = ();
	my @second = ();

	while ( $a =~ m/(1\d|[0,2-9])/g) { push @first, $1; }
	while ( $b =~ m/(1\d|[0,2-9])/g) { push @second, $1; }

	for(0..4) {
		if ($first[$_] == $second[$_]) { next; }
		return $first[$_] <=> $second[$_];
	}
	say "samesies $a and $b";
	return 0;
}

1;