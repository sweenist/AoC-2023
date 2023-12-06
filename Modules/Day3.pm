package Modules::Day3;
use strict;
use warnings;

use Exporter qw( import );
our @ISA = qw( Exporter );
our @EXPORT_OK = qw( part_one part_two );

#---------------------------------------------------------------------------

use constant LINE_LENGTH => 140;


sub part_one {
	my ($file) = @_;
	my $symbol_pattern = q"([^\.0-9])";
	my $re_symbol = qr/$symbol_pattern/;
	my @symbol_indices;
	my @lines;
	my $aggregate = 0;
	my $row_number = 0;

	while(my $line = <$file>) {
		chomp($line);
		push @lines, $line;

		while($line =~ m/$re_symbol/g) {
			push @symbol_indices, $-[0] + (LINE_LENGTH * $row_number);
		}

		$row_number++;
	}

	$row_number = 0; #reset the index for going back thru for number matches
	for(@lines) {
		while($_ =~ m/(\d+)/g) {
			my $first_index = $-[0] + (LINE_LENGTH * $row_number);
			my $last_index = $+[0]-1 + (LINE_LENGTH * $row_number);

			my @perimeter = get_surrounding_number_indices($first_index, $last_index);
			my $is_valid_engine = has_intersection(\@perimeter, \@symbol_indices);

			if ($is_valid_engine) {
				$aggregate += $1;
			}
		}
		$row_number++;
	}
	return $aggregate;
}

#---------------------------------------------------------------------------


sub part_two {
	my ($file) = @_;

	return "not implemented";
}

#---------------------------------------------------------------------------


sub get_surrounding_number_indices(){
	my ($low_num_index, $high_num_index) = @_;

	my $lower_mod = ($low_num_index % LINE_LENGTH);
	my $upper_mod = ($high_num_index % LINE_LENGTH);

	my $lower = $lower_mod == 0 ? $low_num_index : $low_num_index - 1;
	my $upper = $upper_mod == (LINE_LENGTH - 1) ? $high_num_index: $high_num_index + 1;

	my @upper_indices = ($lower - LINE_LENGTH)..($upper - LINE_LENGTH);
	my @lower_indices = ($lower + LINE_LENGTH)..($upper + LINE_LENGTH);

	return (@upper_indices, $lower, $upper, @lower_indices);
}


sub has_intersection(){
	my ($a, $b) = @_;
	my @first = @$a;
	my @second = @$b;
	my %intersect;

	++$intersect{$_} for @first;
	return grep {--$intersect{$_} >= 0} @second;
}

1;