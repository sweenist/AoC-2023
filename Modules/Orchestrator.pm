package Modules::Orchestrator;
use strict;
use warnings;

use Exporter qw( import );
our @ISA = qw( Exporter );
our @EXPORT_OK = qw( solve );

use Modules::Day1;
use Modules::Day2;
use Modules::Day3;
use Modules::Day4;
use Modules::Day5;
use Modules::Day6;

# use Modules::Day7;
# use Modules::Day8;
# use Modules::Day9;
# use Modules::Day10;
# use Modules::Day11;
# use Modules::Day12;
# use Modules::Day13;
# use Modules::Day14;
# use Modules::Day15;
# use Modules::Day16;
# use Modules::Day17;
# use Modules::Day18;
# use Modules::Day19;
# use Modules::Day20;
# use Modules::Day21;
# use Modules::Day22;
# use Modules::Day23;
# use Modules::Day24;
# use Modules::Day25;

#---------------------------------------------------------------------------


sub solve {
	my ($day, $part, $file) = @_;

	my $command = "Modules::Day$day";
	my $sub = ($part eq 1) ? q"::part_one($file);" : q"::part_two($file);";

	$command = $command.$sub;

	return eval $command;
}

1;