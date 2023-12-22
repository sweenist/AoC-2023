package Modules::Day10;
use strict;
use warnings;

use Exporter qw( import );
our @ISA = qw( Exporter );
our @EXPORT_OK = qw( part_one part_two );

use feature qw( say );
use experimental qw( switch );
use Modules::Constants qw( TRUE FALSE );

use constant NORTH => 0;
use constant EAST => 1;
use constant SOUTH => 2;
use constant WEST => 3;

my %memento;

#---------------------------------------------------------------------------


sub part_one {
	my ($file) = @_;
	my $y = 0;
	my @start;
	my @pipe_maze = ();
	while (my $line = <$file>) {
		chomp($line);
		if($line =~ m/(S)/i) {
			@start = ($-[0], $y);
		}

		push @pipe_maze, [ split //, $line ];
		$y++;
	}

	say "Start at ".$start[0].", ",$start[1];
	my $sample = $pipe_maze[$start[1]][$start[0]];
	say "Start char: $sample";
	my $complete = 0;
	my $steps = traverse(\@pipe_maze, \@start);

	for(@$steps) {
		say "steps: $_";
	}
	return "in progress";
}

#---------------------------------------------------------------------------


sub part_two {
	my ($file) = @_;

	return "not implemented";
}

#---------------------------------------------------------------------------


sub traverse {
	my $pipe_maze = shift;
	my $coords_ref = shift;
	my $from = shift;
	my $depth = shift;

	my $memory_key = get_memorandum($coords_ref);
	if(exists $memento{$memory_key}) {
		say "Key $memory_key already exists";
		return $depth;
	}
	$memento{$memory_key}++;

	if(not defined $from) {

		#start case
		my ($n_steps , $e_steps, $s_steps, $w_steps) = 0 x 4;
		my @north_coords = get_coords($coords_ref, NORTH);
		my @east_coords = get_coords($coords_ref, EAST);
		my @south_coords = get_coords($coords_ref, SOUTH);
		my @west_coords = get_coords($coords_ref, WEST);


		if (is_traversable(SOUTH, \@north_coords, $pipe_maze)) {
			say "going north: ".join ',', @north_coords;
			$n_steps = traverse($pipe_maze, \@north_coords, SOUTH, 0);
		}
		if (is_traversable(WEST, \@east_coords, $pipe_maze)) {
			say "going east: ".join ',', @east_coords;
			$e_steps = traverse($pipe_maze, \@east_coords, WEST, 0);
		}
		if (is_traversable(NORTH, \@south_coords, $pipe_maze)) {
			say "going south: ".join ',', @south_coords;
			$s_steps = traverse($pipe_maze, \@south_coords, NORTH, 0);
		}
		if (is_traversable(EAST, \@west_coords, $pipe_maze)) {
			say "going west: ".join ',', @west_coords;
			$w_steps = traverse($pipe_maze, \@west_coords, EAST, 0);
		}
		return ($n_steps, $e_steps, $s_steps, $w_steps);
	} else {
		my $came_from = $from == NORTH ? "north" : $from == SOUTH ? "south" : $from == EAST ? "east" : $from == WEST ? "west" : "nowhere fast";

		my $tile = get_segment($pipe_maze, $coords_ref);
		$depth += 1;
		say "$depth: coming from $came_from at ".join ',', @$coords_ref," on $tile";

		my @try_coords;
		given($from) {
			when(NORTH) {
				given($tile) {
					when('|') {
						@try_coords = get_coords($coords_ref, SOUTH);
						return traverse($pipe_maze, \@try_coords, NORTH, $depth);
					}
					when('L') {
						@try_coords = get_coords($coords_ref, EAST);
						return traverse($pipe_maze, \@try_coords, WEST, $depth);
					}
					when('J') {
						@try_coords = get_coords($coords_ref, WEST);
						return traverse($pipe_maze, \@try_coords, EAST, $depth);
					}
					default { say "Illegal move from $came_from given $tile"; }
				}
			}
			when(EAST) {
				given($tile) {
					when('F') {
						@try_coords = get_coords($coords_ref, SOUTH);
						return traverse($pipe_maze, \@try_coords, NORTH, $depth);
					}
					when('L') {
						@try_coords = get_coords($coords_ref, NORTH);
						return traverse($pipe_maze, \@try_coords, SOUTH, $depth);
					}
					when('-') {
						@try_coords = get_coords($coords_ref, WEST);
						return traverse($pipe_maze, \@try_coords, EAST, $depth);
					}
					default { say "Illegal move from $came_from given $tile"; }
				}
			}
			when(SOUTH) {
				given($tile) {
					when('F') {
						@try_coords = get_coords($coords_ref, EAST);
						return traverse($pipe_maze, \@try_coords, WEST, $depth);
					}
					when('7') {
						@try_coords = get_coords($coords_ref, WEST);
						return traverse($pipe_maze, \@try_coords, EAST, $depth);
					}
					when('|') {
						@try_coords = get_coords($coords_ref, NORTH);
						return traverse($pipe_maze, \@try_coords, SOUTH, $depth);
					}
					default { say "Illegal move from $came_from given $tile"; }
				}
			}
			when(WEST) {
				given($tile) {
					when('-') {
						@try_coords = get_coords($coords_ref, EAST);
						return traverse($pipe_maze, \@try_coords, WEST, $depth);
					}
					when('7') {
						@try_coords = get_coords($coords_ref, SOUTH);
						return traverse($pipe_maze, \@try_coords, NORTH, $depth);
					}
					when('J') {
						@try_coords = get_coords($coords_ref, NORTH);
						return traverse($pipe_maze, \@try_coords, SOUTH, $depth);
					}
					default { say "Illegal move from $came_from given $tile"; }
				}
			}
			default { say "no more grains in sand"; }
		}
	}
}


sub get_memorandum() {
	my $coords = shift;
	my $x = $coords->[0];
	my $y = $coords->[1];
	return $x."x".$y."y";
}


sub get_coords() {
	my $array_ref = shift;
	my $to = shift;

	my $updown = $to == NORTH ? -1 : $to == SOUTH ? 1 : 0;
	my $leftright = $to == WEST ? -1 : $to == EAST ? 1 : 0;

	return ($array_ref->[0] + $leftright, $array_ref->[1] + $updown);
}


sub is_traversable() {
	my $from = shift;
	my $target = shift;
	my $pipes_ref = shift;


	# | - N, S
	# - - E, W
	# 7 - W, S
	# J - W, N
	# L - N, E
	# F - E, S
	# . - nothing
	my $tile = get_segment($pipes_ref, $target);
	say "\ttarget $tile at ".join ',', @$target;

	given($from) {
		when(NORTH) {
			given($tile) {
				when('|') { return TRUE; }
				when('J') { return TRUE; }
				when('L') { return TRUE; }
				default { return FALSE; }
			}
		}
		when(EAST) {
			given($tile) {
				when('-') { return TRUE; }
				when('L') { return TRUE; }
				when('F') { return TRUE; }
				default { return FALSE; }
			}
		}
		when(SOUTH) {
			given($tile) {
				when('|') { return TRUE; }
				when('7') { return TRUE; }
				when('F') { return TRUE; }
				default { return FALSE; }
			}
		}
		when(WEST) {
			given($tile) {
				when('-') { return TRUE; }
				when('7') { return TRUE; }
				when('J') { return TRUE; }
				default { return FALSE; }
			}
		}
		default {say "illegal case for direction";}
	}
}


sub get_segment() {
	my $pipes_ref = shift;
	my $coords_ref = shift;

	return $pipes_ref->[$coords_ref->[1]][$coords_ref->[0]];
}

1;

__DATA__
-L|F7
7S-7|
L|7||
-L-J|
L|-JF