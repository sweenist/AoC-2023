package Modules::Day11;
use strict;
use warnings;

use Exporter qw( import );
our @ISA = qw( Exporter );
our @EXPORT_OK = qw( part_one part_two );

use feature qw( say );
use List::AllUtils qw( all );
use Data::Dumper::Perltidy;

#---------------------------------------------------------------------------


sub part_one {
	my ($file) = @_;
	my @galaxy;

	while(my $line = <$file>) {
		chomp($line);
		push @galaxy, [split //, $line];
	}
	supernova_expansion_jutsu(\@galaxy);
	my %star_positions = star_sight(\@galaxy);
	my $star_summation = handshake(\%star_positions);

	return $star_summation;
}

#---------------------------------------------------------------------------


sub part_two {
	my ($file) = @_;
	my @galaxy;

	while(my $line = <$file>) {
		chomp($line);
		push @galaxy, [split //, $line];
	}
	my $starships = warp_drive(\@galaxy, 1000000);
	my %star_positions = star_flight(\@galaxy, $starships);
	my $star_summation = handshake(\%star_positions);

	return $star_summation;
}

#---------------------------------------------------------------------------


sub supernova_expansion_jutsu() {
	my $galaxy_ref = shift;

	#expand columns
	my $width = @{@$galaxy_ref[0]};

	while($width) {
		--$width;
		if(all {@{$_}[$width] eq "."} @$galaxy_ref){
			for(@$galaxy_ref) {
				splice @$_, $width, 0, '.';
			}
		}
	}
	my $new_width = @{@$galaxy_ref[0]};

	#expand rows
	my $height = @$galaxy_ref;
	while($height) {
		--$height;
		my $row = @$galaxy_ref[$height];
		if(all {$_ eq "."} @$row) {
			splice @$galaxy_ref, $height, 0, [('.') x $new_width];
		}
	}

	return $galaxy_ref;
}


sub warp_drive() {
	my $galaxy_ref = shift;
	my $wormhole_size = shift;

	$wormhole_size--; #gross
	my %escape_pod;
	my $wormhole_x = $wormhole_size;
	my $wormhole_y = $wormhole_size;

	#identify columns
	my $dimension = @{@$galaxy_ref[0]};

	#check length of first row against the count of rows for squareness
	die("Not a square dataset") if $dimension != scalar(@$galaxy_ref);

	for my $dim (0..$dimension-1) {
		if(all {@{$_}[$dim] eq "."} @$galaxy_ref) {
			$escape_pod{$dim."x"} = $wormhole_x;
			$wormhole_x += $wormhole_size;
		}
		if(all {$_ eq "."} @{@$galaxy_ref[$dim]}) {
			$escape_pod{$dim."y"} = $wormhole_y;
			$wormhole_y += $wormhole_size;
		}
	}

	return \%escape_pod;
}


sub star_sight() {
	my $galaxy_ref = shift;
	my %return_hash;

	my $width = @{@$galaxy_ref[0]};
	my $height = @$galaxy_ref;
	my $star_number = 1;

	for(my $y = 0; $y < $height; $y++) {
		my @row = @{@$galaxy_ref[$y]};
		for(my $x = 0; $x < $width; $x++) {
			if($row[$x] eq "#") {
				$return_hash{$star_number} = [$x, $y];
				$star_number++;
			}
		}
	}

	return %return_hash;
}


sub star_flight() {
	my $galaxy_ref = shift;
	my $hyperdrive_ref = shift;

	my $keyring = join "", keys %$hyperdrive_ref;
	my @x_keys = ($keyring =~ m/(\d+)x/g);
	my @y_keys = ($keyring =~ m/(\d+)y/g);

	my %return_hash;
	my $dimension = @$galaxy_ref;
	my $x_mod = 0;
	my $y_mod = 0;
	my $star_number = 1;

	for(my $y = 0; $y < $dimension; $y++) {
		my @row = @{@$galaxy_ref[$y]};
		$x_mod = 0; #reset per row
		if(grep /^$y$/, @y_keys) { $y_mod = $hyperdrive_ref->{$y."y"}; }

		for(my $x = 0; $x < $dimension; $x++) {
			if(grep /^$x$/, @x_keys) { $x_mod = $hyperdrive_ref->{$x."x"}; }
			if($row[$x] eq "#") {
				$return_hash{$star_number} = [$x + $x_mod, $y + $y_mod];
				$star_number++;
			}
		}
	}

	return %return_hash;
}


sub handshake() {
	my $coordinates_hashref = shift;

	my @keys = sort (keys %$coordinates_hashref);
	my $star_count = @keys;
	my $star_summation = 0;

	for(my $i = 1; $i <= $star_count; $i++) {
		for(my $j = $i + 1; $j <= $star_count; $j++) {
			$star_summation += get_star_distance(\@{%$coordinates_hashref{$i}}, \@{%$coordinates_hashref{$j}});
		}
	}

	return $star_summation;
}


sub get_star_distance() {
	my $start_star = shift;
	my $target_star = shift;

	my $delta_x = abs($start_star->[0] - $target_star->[0]);
	my $delta_y = abs($start_star->[1] - $target_star->[1]);


	return $delta_x + $delta_y;
}

1;

__DATA__
...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#.....