package Modules::Day8;
use strict;
use warnings;
use lib '.';

use Exporter qw( import );
our @ISA = qw( Exporter );
our @EXPORT_OK = qw( part_one part_two );

use Modules::Utils qw ( lcm );
use bigint;
use feature qw( say );

#---------------------------------------------------------------------------


sub part_one {
	my ($file) = @_;

	my $head = <$file>;
	my @laterals = parse_laterals($head);

	my %locations;
	while(my $line = <$file>) {
		chomp($line);
		next unless $line;

		my $components = $line =~ s/(\w{3})\s=\s\((\w{3}),\s(\w{3})\)/$1,$2,$3/gr;
		my ($k, $l, $r) = split ',', $components;
		$locations{$k} = [$l, $r];
	}

	return march(\@laterals, \%locations);
}

#---------------------------------------------------------------------------


sub part_two {
	my ($file) = @_;

	my $head = <$file>;
	my @laterals = parse_laterals($head);

	my %locations;
	while(my $line = <$file>) {
		chomp($line);
		next unless $line;

		my $components = $line =~ s/(\w{3})\s=\s\((\w{3}),\s(\w{3})\)/$1,$2,$3/gr;
		my ($k, $l, $r) = split ',', $components;
		$locations{$k} = [$l, $r];
	}

	return get_lcm_run(\@laterals, \%locations);
}

#---------------------------------------------------------------------------


sub parse_laterals() {
	my $line = shift;
	chomp($line);

	$line = $line =~ s/L/0/gr =~ s/R/1/gr;
	return split //, $line;
}


sub march() {
	my $ref_directions = shift;
	my @directions = @{$ref_directions};
	my $ref_locations = shift;
	my %locations = %{$ref_locations};

	my $current_key = "AAA";
	my $end_key = "ZZZ";
	my $steps = 0;

	my $direction_length = @directions;

	while($current_key ne $end_key) {
		my $index = $steps % $direction_length;
		my $dir_index = $ref_directions->[$index];

		my $next_key = $locations{$current_key}[$dir_index];
		$current_key = $next_key;

		$steps++;
	}
	return $steps;
}


sub get_lcm_run() {
	my $ref_directions = shift;
	my $ref_locations = shift;
	my %locations = %{$ref_locations};

	my @a = keys %locations;
	my @current_keys = grep(/A$/, @a);

	my @pathLengths;

	for(@current_keys) {
		my $len = get_run_length($_, $ref_directions, $ref_locations);
		say "Run for $_: $len";
		push @pathLengths, $len;
	}
	lcm(\@pathLengths, 1);
}


sub get_run_length() {
	my $key = shift;
	my $ref_dir = shift;
	my $hash_dir = shift;
	my %locations = %{$hash_dir};

	my $direction_length = @{$ref_dir};
	my $steps = 0;

	while(1) {
		my $index = $steps % $direction_length;
		my $dir_index = $ref_dir->[$index];
		$steps++;

		my $next_key = $locations{$key}[$dir_index];
		$key = $next_key;
		return $steps if $key =~ m/Z$/;
	}
}

1;