package Modules::Day4;
use strict;
use warnings;

use Exporter qw( import );
our @ISA = qw( Exporter );
our @EXPORT_OK = qw( part_one part_two );

#---------------------------------------------------------------------------
use String::Util qw( trim );
use List::AllUtils qw ( all sum );


sub part_one {
	my ($file) = @_;
	my $aggregate = 0;

	while(my $line = <$file>) {
		chomp($line);
		my $all_numbers = (split ":", $line)[1];
		my ($winning_numbers, $owned_numbers ) = split '\|', $all_numbers;
		my $matched_numbers = get_matching_numbers($winning_numbers, $owned_numbers);

		if($matched_numbers) { $aggregate += (2 **($matched_numbers -1));}

	}
	return $aggregate;
}

#---------------------------------------------------------------------------


sub part_two {
	my ($file) = @_;
	my $current_iteration = 0;
	my %card_iterations;
	for (1..190) { $card_iterations{$_} = 1;}

	while(my $line = <$file>) {
		chomp($line);
		$current_iteration++;

		my $all_numbers = (split ":", $line)[1];
		my ($winning_numbers, $owned_numbers ) = split '\|', $all_numbers;
		my $matched_numbers = get_matching_numbers($winning_numbers, $owned_numbers);

		if($matched_numbers){
			my $key = $current_iteration + 1;
			my $repeats = $card_iterations{ $current_iteration };

			for(1..$repeats) {
				for($key..($key + $matched_numbers - 1)) {
					$card_iterations{$_}++;
				}
			}
		}

	}
	return sum values %card_iterations;
}

#---------------------------------------------------------------------------


sub get_matching_numbers {
	my ($a, $b) = @_;
	my @first = split / +/, trim($a);
	my @second = split / +/, trim($b);
	my %intersect;

	++$intersect{$_} for @first;
	return grep {--$intersect{$_} >= 0} @second;
}
1;