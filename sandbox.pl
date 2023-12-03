#!/usr/bin/perl -w
use strict;
use warnings;

use feature 'say';
use List::SomeUtils qw( any all );


my $inputfile = "./inputdata/day2.txt";

open(my $file, "<", $inputfile) or die("unable to open file $inputfile");
part_one($file);

close($file);

#---------------------------------------------------------------------------


sub part_one {
	my ($file) = @_;
	my $aggregate = 0;
	my $outer_pattern = q"^Game (\d+):\s(.*)";
	my $re_outer = qr/$outer_pattern/;
	while(my $line = <$file>){
		if($line =~ m/$re_outer/){
			my $game_index = $1;
			my @sets = split ';', $2;
			say "checking $2 for $game_index";
			next unless all {validate_possible_game($_)} @sets;
			say "Valid line $line";
			$aggregate += $game_index;
		}
	}

	say $aggregate;
}

#---------------------------------------------------------------------------


sub validate_possible_game {
	my ($set) = @_;
	my $max_red = 12;
	my $max_green = 13;
	my $max_blue = 14;

	my $set_red = 0;
	my $set_green = 0;
	my $set_blue = 0;

	if($set =~ m/(\d+) red/){
		$set_red = $1;
	}
	if($set =~ m/(\d+) green/){
		$set_green = $1;
	}
	if($set =~ m/(\d+) blue/){
		$set_blue = $1;
	}
	say "is red valid? ";
	say $set_red <= $max_red;
	say "encountered red: $set_red, green: $set_green, blue: $set_blue";
	return ($set_red <= $max_red and $set_green <= $max_green and $set_blue <= $max_blue);
}
