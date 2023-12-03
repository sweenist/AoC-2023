package Modules::Day2;

use Exporter qw( import );
our @ISA = qw( Exporter );
our @EXPORT_OK = qw( part_one part_two );

use List::AllUtils qw( any all max );

#---------------------------------------------------------------------------


sub part_one {
	my ($file) = @_;
	my $aggregate = 0;
	my $outer_pattern = q"^Game (\d+):\s(.*)";
	my $re_outer = qr/$outer_pattern/;

	while(my $line = <$file>){
		if($line =~ m/$outer_pattern/){
			my $game_index = $1;
			my @sets = split ';', $2;

			next unless all {validate_possible_game($_)} @sets;
			$aggregate += $game_index;
		}
	}

	return $aggregate;
}

#---------------------------------------------------------------------------


sub part_two {
	my ($file) = @_;
	my $aggregate = 0;
	my $outer_pattern = q"^Game (\d+):\s(.*)";
	my $re_outer = qr/$outer_pattern/;

	while(my $line = <$file>){
		if($line =~ m/$outer_pattern/){
			my @sets = split ';', $2;

			my $max_red = max (map {get_max_color($_, "red")} @sets);
			my $max_green = max (map {get_max_color($_, "green")} @sets);
			my $max_blue = max (map {get_max_color($_, "blue")} @sets);

			$aggregate += ($max_red * $max_green * $max_blue);
		}
	}
	return $aggregate;
}

#---------------------------------------------------------------------------


sub validate_possible_game() {
	my ($set) = @_;
	my $max_red = 12;
	my $max_green = 13;
	my $max_blue = 14;

	my $set_red = 0;
	my $set_green = 0;
	my $set_blue = 0;

	if($set =~ /(\d+) red/){
		$set_red = $1;
	}
	if($set =~ /(\d+) green/){
		$set_green = $1;
	}
	if($set =~ /(\d+) blue/){
		$set_blue = $1;
	}

	return ($set_red <= $max_red and $set_green <= $max_green and $set_blue <= $max_blue);
}


sub get_max_color{
	my($value, $color) = @_;
	if($value =~ m/(\d+) $color/){
		return $1;
	}
	return 0;
}
1;