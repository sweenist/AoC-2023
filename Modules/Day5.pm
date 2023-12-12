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
	my ($line) = @_;
	my $numbers = (split /:/, $line)[1];
	return split /\s+/, trim($numbers);
}


sub get_seed_ranges {
	my ($line) = @_;
	my $numbers = (split /:/, $line)[1];
	my @s = split /\s+/, trim($numbers);
	my $pairs = @s;
	$pairs = ($pairs / 2) - 1;

	my @return_list = ();

	for(0..$pairs) {
		my $i = $_ * 2;
		my $j = $i + 1;
		my $base = $s[$i];
		my $range = $s[$j];
		my $top = $base + $range - 1;

		push @return_list, ($base..$top);
	}
	return @return_list;
}


sub store_recipe() {
	my $recipe_ref = shift;
	my $data = shift;
	my($destination, $source, $range) = split /\s+/, trim($data);

	my $key = $source;
	my $value = $destination;
	$recipe_ref->{$key} = [$value, $range];
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

	# say "sift $debug: $item_number -> candidate: $candidate; Dest base: ".$next_and_range->[0]." range: ".$next_and_range->[1];
	my $augment = get_destination_increment($item_number, $candidate, $next_and_range->[1]);

	# say " sift $debug: augment by: $augment";
	if ($augment == -1) {

		# add target as key with range 0
		$hash_ref->{$item_number} = [$item_number, 0];
		return $item_number;
	}
	my $result = $next_and_range->[0] + $augment;
	return $result;
}

#Binary search
sub get_match_or_lower() {
	my $target = shift;
	my $v = shift;
	my $debug = shift;

	my @values = @{$v};
	my $values_length = @values;

	return -1 if $target <= $values[0];
	return $values[$values_length - 1] if $target >= $values[$values_length - 1];

	my $i = 0;
	my $j = $values_length;
	my $mid = 0;

	while($i < $j) {
		$mid = ($i + $j) / 2;
		$mid = int($mid);

		# say "matching $debug";
		# say "\ti: $i, j: $j, mid: $mid; values:".join(',', @values);
		# say "\t$target -> ".$values[$mid];
		return $values[$mid] if $values[$mid] == $target;

		if($target < $values[$mid]) {
			if($mid > 0 && $target > $values[$mid - 1])	{
				return $values[$mid -1];
			}
			$j = $mid;
		} else {
			if( $mid < ($values_length - 1) && $target < $values[$mid + 1]) {
				return $values[$mid];
			}

			$i = ($mid + 1);
		}
	}

	return $values[$mid];
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

1;