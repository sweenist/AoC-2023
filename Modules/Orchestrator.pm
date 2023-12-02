package Modules::Orchestrator;
use strict;
use warnings;

use Exporter qw( import );
our @ISA = qw( Exporter );
our @EXPORT_OK = qw( solve );

use Modules::Day1;
use Modules::Day2;

use feature qw(say);

#---------------------------------------------------------------------------


sub solve {
	my ($day, $part, $file) = @_;

	my $command = "Modules::Day$day";
	my $sub = ($part eq 1) ? q"::part_one($file);" : q"::part_two($file);";

	$command = $command.$sub;
	say $command;

	return eval $command;
}

1;