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
			say "Processing header: $line";
			$recipe = process_header($line);
			eval "\$recipe_ref = \\%$recipe;";
			next;
		}
		cascade_recipe(\%$recipe_ref, $line);
	}

	for(@seeds) {
		$seed_soil{$_} = $_ unless exists $seed_soil{$_};
		my $soil = $seed_soil{$_};

		$soil_fertilizer{$soil} = $soil unless exists $soil_fertilizer{$soil};
		my $fertilizer = $soil_fertilizer{$soil};

		$fertilizer_water{$fertilizer} = $fertilizer unless exists $fertilizer_water{$fertilizer};
		my $water = $fertilizer_water{$fertilizer};

		$water_light{$water} = $water unless exists $water_light{$water};
		my $light = $water_light{$water};

		$light_temperature{$light} = $light unless exists $light_temperature{$light};
		my $temperature = $light_temperature{$light};

		$temperature_humidity{$temperature} = $temperature unless exists $temperature_humidity{$temperature};
		my $humidity = $temperature_humidity{$temperature};

		$humidity_location{$humidity} = $humidity unless exists $humidity_location{$humidity};
		my $location = $humidity_location{$humidity};

		push @locations, $location;
	}
	my $return_value = min @locations;
	return "$return_value";
}

#---------------------------------------------------------------------------


sub part_two {
	my ($file) = @_;

	return "not implemented";
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


sub cascade_recipe() {
	my $recipe_ref = shift;
	my $data = shift;
	my %hash = %$recipe_ref;
	my($destination, $source, $range) = split /\s+/, trim($data);

	while($range) {
		$range--;
		my $key = $source + $range;
		my $value = $destination + $range;
		$recipe_ref->{$key} = $value;
	}
}

1;