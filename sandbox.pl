#!/usr/bin/perl -w
use strict;
use warnings;

use feature 'say';
use List::SomeUtils qw( any all );

use constant LINE_LENGTH => 140;

my $testline = "...13..*33..@";
my $symbol_pattern = q"([^\.0-9])";
my $re_sym = qr/$symbol_pattern/;

my @alist = (1,0,9,5);
my @blist = (1, 5,6,9);

my $a = @alist;
my $b = @blist;

if($a) {say "A";}
if($b) {say "B";}
if(@alist) {say "A list";}
if(@blist) {say "B list";}

my @rersult = has_intersection(\@alist, \@blist);
say "blah @rersult";

# part_one();

#---------------------------------------------------------------------------


sub part_one {
	my @lines = ("...............307............130..................969...601...186.........................................312....628..........878..........","......479#../..*..............................#.....*......*............../309.....484........................*......-..........+.....89....","...........726..352...461..69..............435.....390...625....................................459.........152...-....580............*.....");
	my $symbol_pattern = q"(^\d|^\.|)+";
	my $re_symbol = qr/$symbol_pattern/;
	my @symbol_indices;
	my @values;
	my $aggregate = 0;

	foreach(@lines){
		my $row_number = 1;
		push @values, $_;

		while($_ =~ m/$re_symbol/g){
			push @symbol_indices, $-[0] * $row_number;
		}

		$row_number++;
	}

	foreach (@values){
		my $line_number = 1;
		while($_ =~ m/(\d+)/g){
			my $found_lower = $-[0] * $line_number;
			my $found_upper = ($+[0] -1) * $line_number;
			my $upper_row_symdex = ""; #fix
		}
		$line_number++;
	}

	say "";
}

#---------------------------------------------------------------------------


sub get_surrounding_number_indices(){
	my ($low_num_index, $high_num_index) = @_;
	my $a = $low_num_index - 1;
	my $b = $high_num_index + 1;

	my @upper_indices = ($a - LINE_LENGTH)..($b - LINE_LENGTH);
	my @lower_indices = ($a + LINE_LENGTH)..($b + LINE_LENGTH);

	return (@upper_indices, $a, $b, @lower_indices);
}


sub has_intersection(){
	my ($a, $b) = @_;
	my @first = @$a;
	my @second = @$b;
	my %intersect;

	++$intersect{$_} for @first;
	return grep {--$intersect{$_} >= 0} @second;
}