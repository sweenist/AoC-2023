package Modules::Day5;
use strict;
use warnings;
use lib '.';

use Exporter qw( import );
our @ISA = qw( Exporter );
our @EXPORT_OK = qw( part_one part_two );

#---------------------------------------------------------------------------

use String::Util qw( trim );
use List::AllUtils qw (min);
use Modules::Constants qw (TRUE FALSE);
use POSIX;

use feature qw( say );
use bigint;

use constant SEED_TO_SOIL => 'seed-to-soil';
use constant SOIL_TO_FERTILIZER => 'soil-to-fertilizer';
use constant FERTILIZER_TO_WATER => 'fertilizer-to-water';
use constant WATER_TO_LIGHT => 'water-to-light';
use constant LIGHT_TO_TEMPERATURE => 'light-to-temperature';
use constant TEMPERATURE_TO_HUMIDITY => 'temperature-to-humidity';
use constant HUMIDITY_TO_LOCATION => 'humidity-to-location';

#---------------------------------------------------------------------------


sub part_one {
	my ($file) = @_;

	my $start_new = FALSE;
	my $recipe;
	my $recipe_ref;

	my @seeds;
	my @locations = [];

	my %seed_soil;
	my %soil_fertilizer;
	my %fertilizer_water;
	my %water_light;
	my %light_temperature;
	my %temperature_humidity;
	my %humidity_location;

	while(my $line = <$file>) {
		chomp($line);

		if(not @seeds){
			@seeds = get_seeds($line);
			next;
		}
		if(not $line) {
			$start_new = TRUE;
			next;
		}
		if($start_new) {
			$start_new = FALSE;
			$recipe = process_header($line);
			eval "\$recipe_ref = \\%$recipe;";
			next;
		}
		store_recipe(\%$recipe_ref, $line);
	}

	for(@seeds) {
		my $soil = sift($_, \%seed_soil, "soil");
		my $fertilizer = sift($soil, \%soil_fertilizer, "fert");
		my $water = sift($fertilizer, \%fertilizer_water, "water");
		my $light = sift($water, \%water_light, "light");
		my $temperature = sift($light, \%light_temperature, "temp");
		my $humidity = sift($temperature, \%temperature_humidity, "humid");
		my $location = sift($humidity, \%humidity_location, "loc");

		push @locations, $location;
	}
	my $return_value = min @locations;
	return "$return_value";
}

#---------------------------------------------------------------------------


sub part_two {
	my ($file) = @_;

	my $start_new = FALSE;
	my $recipe;
	my $recipe_ref;

	my @seeds;

	my %seed_soil;
	my %soil_fertilizer;
	my %fertilizer_water;
	my %water_light;
	my %light_temperature;
	my %temperature_humidity;
	my %humidity_location;

	while(my $line = <$file>) {
		chomp($line);

		if(not @seeds){
			@seeds = get_seed_ranges($line);
			next;
		}
		if(not $line) {
			$start_new = TRUE;
			next;
		}
		if($start_new) {
			$start_new = FALSE;
			$recipe = process_header($line);
			eval "\$recipe_ref = \\%$recipe;";
			next;
		}
		store_recipe(\%$recipe_ref, $line, TRUE);
	}

	my @soils = process_maps(\@seeds, \%seed_soil, "soil");
	my @ferts = process_maps(\@soils, \%soil_fertilizer, "fertilizer");
	my @water = process_maps(\@ferts, \%fertilizer_water, "water");
	my @light = process_maps(\@water, \%water_light, "light");
	my @temp = process_maps(\@light, \%light_temperature, "temperature");
	my @humid = process_maps(\@temp, \%temperature_humidity, "humidity");
	my @locations = process_maps(\@humid, \%humidity_location, "location");

	my @flat_locations = sort ( map {@$_} @locations);
	return min @flat_locations;
}

#---------------------------------------------------------------------------


sub process_header() {
	my ($line) = @_;
	my $hash_pattern = "(".SEED_TO_SOIL."|".SOIL_TO_FERTILIZER."|".FERTILIZER_TO_WATER."|".WATER_TO_LIGHT."|".LIGHT_TO_TEMPERATURE."|".TEMPERATURE_TO_HUMIDITY."|".HUMIDITY_TO_LOCATION.")";
	my $re_hash = qr/$hash_pattern/;

	if($line =~ m/$re_hash/) {
		my $header = $1;
		$header =~ s/-to-/_/g;
		return $header;
	}else {
		die("unexpected input: $line");
	}
}


sub get_seeds {
	my ($line) = shift;
	my $numbers = (split /:/, $line)[1];
	return split /\s+/, trim($numbers);
}


sub get_seed_ranges {
	my ($line) = shift;
	my $numbers = trim((split /:/, $line)[1]);
	my @return_array;

	while($numbers =~ m/(\d+)\s(\d+)/g) {
		my $upper = $1 + $2 -1;
		push @return_array, [$1, $upper];
	}

	return @return_array;
}


sub store_recipe() {
	my $recipe_ref = shift;
	my $data = shift;
	my $use_upper_bound = shift;
	my($destination, $source, $range) = split /\s+/, trim($data);

	my $value = defined $use_upper_bound ? $destination + $range - 1 : $range;
	$recipe_ref->{$source} = [$destination, $value];
}


sub sift() {
	my $item_number = shift;
	my $hash_ref = shift;
	my $debug = shift;

	my @hash_keys = sort {$a <=> $b } keys %{$hash_ref};
	my $candidate = get_match_or_lower($item_number, \@hash_keys, $debug);

	if ($candidate == -1) {

		# add target as key with range 0
		$hash_ref->{$item_number} = [$item_number, 0];
		$candidate = $item_number;
	}
	my $next_and_range = $hash_ref->{$candidate};

	my $augment = get_destination_increment($item_number, $candidate, $next_and_range->[1]);

	if ($augment == -1) {

		return $item_number;
	}
	my $result = $next_and_range->[0] + $augment;
	return $result;
}


sub process_maps() {
	my $input_ref = shift; # multi-dimensional array
	my $hash_ref = shift;  # hash of {source}->[destination_start, destination_end]
	my $debug = shift;
	my @source_keys = sort { $a <=> $b } keys %{$hash_ref};
	my @return_segments;
	say "---$debug---" if defined $debug;

	for(@$input_ref) {

		# print Dumper $_;
		my $map_low_index = get_match_or_lower($_->[0], \@source_keys, 1);
		my $map_hi_index = get_match_or_lower($_->[1], \@source_keys, 1);

		# say "inputs:\t (".$_->[0].", ".$_->[1].")";
		my $start = $_->[0];
		my $end = $_->[1];
		my $is_sifting = TRUE;
		$map_low_index = 0 if $map_low_index == -1;

		while($is_sifting) {
			my $source_start = $source_keys[$map_low_index];
			my $dest = $hash_ref->{$source_start};
			my $range = $dest->[1] - $dest->[0];
			my $source_end = $source_start + $range;

			# how does input range fit?
			my $map_shift = $dest->[0] - $source_start;
			my ($seg_start, $seg_end);

			if($start >= $source_start && $end <= $source_end) { #input range fits
				$seg_start = $start;
				$seg_end = $end;
				push @return_segments, [($seg_start + $map_shift, $seg_end + $map_shift)];
				$is_sifting = FALSE;
			} elsif ($start < $source_start) { #passthru condition
				 # say "\tpassthru: $start; $source_start";
				$seg_start = $start;
				$seg_end = $end >= $source_start ? $source_start - 1 : $end;
				$start = $source_start;
				push @return_segments, [($seg_start, $seg_end)];
				$is_sifting = $end >= $source_start;

				# say "\tinput range ($start, $end) fits $source_start to $source_end";
			} elsif ($start >= $source_end) { # input should passthru
				 # say "\tstart $start greater than source_end $source_end";
				$seg_start = $start;
				$seg_end = $end;
				push @return_segments, [($seg_start, $seg_end)];
				$start = $seg_end + 1;

				# say "$debug: start:$start, end:$end, index:$map_low_index, source:$source_start, $source_end";
				$map_low_index++;
			} elsif ($start >= $source_start && $end > $source_end) { # input range doesn't fit
				 # say "\tinput range ($start, $end) does not fit $source_start, $source_end";
				$seg_start = $start;
				$seg_end = $source_end;
				$start = $seg_end + 1;
				push @return_segments, [($seg_start + $map_shift, $seg_end + $map_shift)];
				$map_low_index++;

			} else {
				die("illegal case");
			}

			if($start > $end) { $is_sifting = FALSE; }
			if($map_low_index > $map_hi_index) { $is_sifting = FALSE; }
		}
	}
	return @return_segments;
}


sub filter_range() {
	my $input_ref = shift;

}

#Binary search
sub get_match_or_lower() {
	my $target = shift;
	my $v = shift;
	my $return_index = shift;

	my @values = @{$v};
	my $values_length = @values;

	return -1 if $target <= $values[0];
	if( $target >= $values[$values_length - 1]) {
		return defined $return_index ? $values_length - 1 : $values[$values_length - 1];
	}


	my $i = 0;
	my $j = $values_length;
	my $mid = 0;

	while($i < $j) {
		$mid = ($i + $j) / 2;
		$mid = int($mid);

		if ($values[$mid] == $target) {
			return defined $return_index ? $mid : $values[$mid];
		}
		if($target < $values[$mid]) {
			if($mid > 0 && $target > $values[$mid - 1])	{
				return defined $return_index ? $mid -1 : $values[$mid - 1];
			}
			$j = $mid;
		} else {
			if( $mid < ($values_length - 1) && $target < $values[$mid + 1]) {
				return defined $return_index ? $mid : $values[$mid];
			}

			$i = ($mid + 1);
		}
	}
	return defined $return_index ? $mid : $values[$mid];
}


sub get_destination_increment() {
	my $target = shift;
	my $base = shift;
	my $range = shift;

	my $difference = $target - $base;
	if($difference > $range) {
		return -1;
	}
	return $difference;
}


sub get_min() {
	my $left_ref = shift;
	my $right = shift;
	my $left = min @$left_ref;

	return $left if $right == 0;
	return min($left, $right);
}

1;