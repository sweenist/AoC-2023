package Modules::Day14;
use strict;
use warnings;

use Exporter qw( import );
our @ISA = qw( Exporter );
our @EXPORT_OK = qw( part_one part_two );

use feature qw( say );
use Modules::Utils qw( transpose flatten );
use Data::Dumper::Perltidy;

#---------------------------------------------------------------------------


sub part_one {
	my ($file) = @_;
	my @tilt_box = ();

	while(my $line = <$file>) {
		chomp($line);
		push @tilt_box, [split //, $line];
	}
	my @rearranged_rocks = tilt_north(\@tilt_box);
	my $weight = calculate_weight(\@rearranged_rocks);
	return $weight;
}

#---------------------------------------------------------------------------


sub part_two {
	my ($file) = @_;

	return "not implemented";
}

#---------------------------------------------------------------------------


sub tilt_north {
	my $array_ref = shift;

	my @shift_box = transpose($array_ref);
	my @top_rocks =();

	for(@{$shift_box[0]}) {
		my $line = flatten(\@$_);

		my @round_rocks;
		my @flat_rocks;
		while($line =~ m/O/g) { push @round_rocks, $-[0]; }
		while($line =~ m/#/g) { push @flat_rocks, $-[0]; }

		my @new_line = rearrange(\@$_, \@round_rocks, \@flat_rocks);
		push @top_rocks, @new_line;
	}
	return @top_rocks;
}


sub rearrange {
	my $line_ref = shift;
	my $rounds_ref = shift;
	my $flats_ref = shift;

	my $line_len = @$line_ref;
	my @rounds = @$rounds_ref;
	my @flats = @$flats_ref;

	my $round_index = shift @rounds;
	my $flat_index = shift @flats;
	my @return_line;
	my $return_len = 0;

	while($return_len != $line_len) {
		if(!(defined($flat_index) || defined($round_index))) {
			for($return_len..$line_len-1){
				push @return_line, '.';
			}
		} elsif(defined($flat_index) && defined($round_index)) {
			if($flat_index > $round_index) {
				push @return_line, 'O';
				$round_index = shift @rounds;
			} elsif($flat_index == $return_len) {
				push @return_line, "#";
				$flat_index = shift @flats;
			} else {
				for($return_len..$flat_index-1) {
					push @return_line, '.';
				}
			}
		} elsif(not defined $round_index) {
			for($return_len..$line_len-1) {
				push @return_line, '.';
			}
		} elsif(not defined $flat_index) {
			push @return_line, 'O';
			$round_index = shift @rounds;
		}

		$return_len = @return_line;
	}
	return [@return_line];
}


sub calculate_weight {
	my $array_ref = shift;
	my $length = @$array_ref;
	my $aggregate = 0;

	for(@$array_ref) {
		my $line = flatten(\@$_);
		while($line =~ m/O/g) {
			$aggregate += $length - $-[0];
		}
	}
	return $aggregate;
}

1;

__DATA__
O....#....
O.OO#....#
.....##...
OO.#O....O
.O.....O#.
O.#..O.#.#
..O..#O..O
.......O..
#....###..
#OO..#....