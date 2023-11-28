#!/usr/bin/perl
use strict;
use warnings;

use lib '.';
use feature 'say';

use Modules::Day1 qw(part_one part_two);

my ($day, $part) = @ARGV;
usage() unless(defined $day and defined $part);

my $inputfile = "./inputdata/day$day.txt";
my $output;

open(my $file, "<", $inputfile) or die("unable to open file $inputfile");

if($part eq 1){
	$output = part_one($file);
}elsif($part eq 2){
	$output = part_two($file);
}else {
	usage();
}

say "Answer: $output";

close( $file);


sub usage {
	say "Advent of Code main.pl usage:";
	say "\tperl main.pl <number:day> <number:part>";
	say "";
	say "For eaxample: perl main.pl 1 2 would run day1 part_two routine";
	die;
}