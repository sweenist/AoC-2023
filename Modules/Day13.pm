package Modules::Day13;
use strict;
use warnings;
use lib '.';

use Exporter qw( import );
our @ISA = qw( Exporter );
our @EXPORT_OK = qw( part_one part_two );

use feature qw( say );
use Modules::Utils qw( duplicates );
use Modules::Constants qw( TRUE FALSE );
use List::AllUtils qw( first_index last_index max min mesh );

#---------------------------------------------------------------------------


sub part_one {
	my $file = shift;
	my @lava_maps = ();
	my $aggregate = 0;
	my $d = 0;

	while(my $line = <DATA>) {
		chomp($line);
		if($line) {

			# say "$d: $line";
			my @num_rep = split(//, ($line =~ s/#/2/gr =~ s/\./1/gr));
			push @lava_maps, [@num_rep];
		} else {
			$d++;
			say "$d map";
			$aggregate += process_matrix(\@lava_maps);
			@lava_maps = ();

		}
	}
	$aggregate += process_matrix(\@lava_maps);

	return $aggregate;
}

#---------------------------------------------------------------------------


sub part_two {
	my ($file) = @_;

	return "not implemented";
}

#---------------------------------------------------------------------------


sub process_matrix() {
	my $matrix_ref = shift;

	my @rows = @{$matrix_ref};
	my $height = @rows;

	@rows = flatten(\@rows);
	my @columns = get_columns($matrix_ref);
	my $width = @columns;

	comparator(\@columns);

	my $row_mirror = symmetrize(\@rows, "row");
	my $column_mirror = symmetrize(\@columns, "column");

	# say "w x h: $width x $height";
	say "  row sym: $row_mirror; col_sym: $column_mirror\n";

	if($row_mirror > $column_mirror) {return $row_mirror * 100; }
	else { return $column_mirror; }
}


sub get_columns() {

	# Takes an Array of arrays and returns its rotational transform (fakely)
	# A,B,C,D
	# becomes
	# A
	# B
	# C
	# D

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

	return flatten(\@return);
}


sub flatten() {
	my $matrix_ref = shift;

	my @return = ();
	for(@$matrix_ref) {
		my $row = join '',  @$_;
		push @return, $row;
	}
	return @return;
}


sub comparator() {
	my $array_ref = shift;

	my $length = @$array_ref;
	my @lava_map = @$array_ref;

	for(1..$length -2) {
		my @top = reverse @lava_map[0..$_];
		my @bottom = @lava_map[(-$length + $_)..-1];

		my $m_len = min (scalar(@top), scalar(@bottom));
		my $m_count = 0;
		for my $t (0..$m_len - 1) {

			if($top[$t] == $bottom[$t]) {
				say "min: $m_len";
				say "huh: $m_len :".$top[$t]."b: ".$bottom[$t];
				$m_count++;
			}
		}

		# say "top matches $m_count:\n".join "\n", @top if $m_count;
		# say "\nbottom matches $m_count:\n".join "\n", @bottom if $m_count;
	}
}


sub symmetrize() {
	my $array_ref = shift;
	my $debug = shift;
	my @candidates = ();

	my $length = @$array_ref;
	my $index = 0;

	while($index != $length - 1) {
		$index++;
		if(@$array_ref[$index] == @$array_ref[$index-1]) {
			say "reflection at $debug ".($index - 1).", $index" if defined $debug;
			push @candidates, $index-1;
		}
	}
	my $return_value = 0;
	for(@candidates) {
		my $c = count_reflections($array_ref, $_, $length);
		$return_value = $return_value > $c ? $return_value : $c;
	}
	return $return_value;
}


sub count_reflections() {
	my $array_ref = shift;
	my $index = shift;
	my $length = shift;
	my $count = 1;
	my $offset = 1;
	my $is_running = TRUE;

	while($is_running) {
		$index--;
		$offset += 2;

		if($index + $offset >= $length) {
			$is_running = FALSE;

			# say "COunt: $count, index: $index";
			return $count + $index + 1;
		} elsif (@$array_ref[$index] == @$array_ref[$index + $offset]) {

			# say "$index,".($index + $offset)." is @$array_ref[$index]";
			$count++;
		} elsif ($index == -1) {
			$is_running = FALSE;
		} else {

			# say "i: $index, l: $length, c: $count p: @$array_ref[$index]";
			$is_running = FALSE;
		}
	}
	return $count;
}


sub adjust_reflection() {
	my $length = shift;
	my $reflection = shift;
	if($reflection < $length / 2)  { return 0; }
	return $reflection - ($length - $reflection);
}

1;


__DATA__
##..##.######
.####.#######
.####.##.##.#
.#..#..#.##.#
######.#....#
......#..##..
######.##..##
.#..#...###..
#....#.......
#######.#..#.
..##....#..#.
#....###....#
########.##.#