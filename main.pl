#!/usr/bin/perl
use strict;
use warnings;

use lib '.';
use feature 'say';

use Modules::Orchestrator qw(solve);

my ($day, $part) = @ARGV;
usage("No args specified") unless(defined $day and defined $part);
usage("part can only be 1 or 2") unless($part eq 1 or $part eq 2);
usage("Choose a day between 1 and 25") unless($day ge 1 and $day le 25);

my $inputfile = "./inputdata/day$day.txt";
my $output;

open(my $file, "<", $inputfile) or die("unable to open file $inputfile");

$output = solve($day, $part, $file);

say "Answer: $output";

close( $file);


sub usage {
	my ($message) = @_;
	say $message unless not defined $message;
	say "" unless not defined $message;
	say "Advent of Code main.pl usage:";
	say "\tperl main.pl <number:day> <number:part>";
	say "";
	say "For eaxample: perl main.pl 1 2 would run day1 part_two routine";
	say "    day: a number in range 1..25";
	say "    part: either 1 or 2";
	die;
}