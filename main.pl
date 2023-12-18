#!/usr/bin/perl
use strict;
use warnings;

use lib '.';
use feature 'say';
use Benchmark;

use Modules::Orchestrator qw(solve);

my ($day, $part, $benchmark) = @ARGV;
usage("No args specified") unless(defined $day and defined $part);
usage("part can only be 1 or 2") unless($part == 1 or $part == 2);
usage("Choose a day between 1 and 25") unless($day >= 1 and $day <= 25);

my $inputfile = "./inputdata/day$day.txt";
my $output;
my $start_time = defined $benchmark ? Benchmark->new : 0;
open(my $file, "<", $inputfile) or die("unable to open file $inputfile");

$output = solve($day, $part, $file);
my $end_time = defined $benchmark ? Benchmark->new : 0;
print_time($start_time, $end_time, $benchmark) if defined $benchmark;
say "Answer: $output";

close( $file);


sub usage {
	my ($message) = @_;
	say $message unless not defined $message;
	say "" unless not defined $message;
	say "Advent of Code main.pl usage:";
	say "\tperl main.pl <number:day> <number:part> <bool:benchmarking>";
	say "";
	say "For eaxample: `perl main.pl 1 2` would run day1 part_two routine";
	say "    day: a number in range 1..25";
	say "    part: either 1 or 2";
	say "    benchmarking: any non-zero value. 1 gives user time. >1 gives full message";
	die;
}


sub print_time {
	my $t0 = shift;
	my $t1 = shift;
	my $bench = shift;

	my $delta = timediff($t1, $t0);

	my $blah = timestr($delta, 'all', '5.3f');
	if(defined $bench && $bench > 1) {
		say $blah;
		return;
	}
	my $usecs = (split / /, $blah)[4];
	$usecs =~ s/\(//g;
	say "Run time: $usecs secs";
}