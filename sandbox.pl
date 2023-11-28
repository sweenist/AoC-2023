#!/usr/bin/perl -w
use strict;
use warnings;

use feature 'say';
use String::Util 'trim';
use List::Util qw(max sum tail);

my %number_strings = (
	'one'   => 1,
	'two'   => 2,
	'three' => 3,
	'four'  => 4,
	'five'  => 5,
	'six'   => 6,
	'seven' => 7,
	'eight' => 8,
	'nine'  => 9,
	'zero'  => 0
);

my $input = "esix1blahtwo5seven";
my %reverse_number_strings = ();

foreach(keys %number_strings) {
	$reverse_number_strings{(reverse $_)} = $number_strings{$_};
}

my $pattern = q"(\d|" . (join '|', keys %number_strings) . ")";
my $reverse_pattern = q"(\d|" . (join '|', keys %reverse_number_strings) . ")";

my $re_first = qr/$pattern/;
my $re_last = qr/$reverse_pattern/;

my $calibration;

if($input =~ $re_first){
	my $first = get_digit($1);
	say "first: $first";
	$calibration = $first;
}

if ((reverse $input) =~ $re_last) {
	my $last = get_digit($1, 1);
	say "last: $last";
	$calibration = $calibration.$last;
}

say "final:  $calibration";


sub get_digit {
	my ($token, $reverse) = @_;

	# $reverse = 0 unless (defined $reverse);
	return (length $token eq 1) ? $token : (defined $reverse && $reverse) ? %reverse_number_strings{$token} : %number_strings{$token};
}