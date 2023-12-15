package Modules::Day9;
use strict;
use warnings;
use lib '.';

use Exporter qw( import );
our @ISA = qw( Exporter );
our @EXPORT_OK = qw( part_one part_two );

use List::AllUtils qw( pairwise all max );
use Modules::Utils qw ( get_upper_bound );
use Modules::Constants qw (TRUE FALSE);
use feature qw ( say );

#---------------------------------------------------------------------------


sub part_one {

	my ($file) = @_;
	my $aggregate = 0;

	while(my $line = <$file>) {
		chomp($line);
		my @oasis_report_base = split /\s+/, $line;
		my $report_bundle_ref = reduce_working_set(\@oasis_report_base);
		my $augend = increase_working_set($report_bundle_ref);
		$aggregate += $augend;
	}

	return $aggregate;
}

#---------------------------------------------------------------------------


sub part_two {
	my ($file) = @_;

	return "not implemented";
}

#---------------------------------------------------------------------------


sub reduce_working_set() {
	my $input_list = shift;
	my %working_sets = (0 => $input_list);
	my $is_processing = TRUE;
	my $set_index = 0;

	while($is_processing) {
		my @working_set = @{$working_sets{$set_index}};
		my $upper_bound = get_upper_bound(\@working_set);

		my @left = @working_set[0..($upper_bound-1)];
		my @right = @working_set[1..$upper_bound];

		my @next_set = pairwise {$b - $a} @left, @right;
		$set_index++;
		$working_sets{$set_index} = \@next_set;
		$is_processing = FALSE if all {$_ == 0} @next_set;
	}
	return \%working_sets;
}


sub increase_working_set() {
	my $hash_ref = shift;
	my %working_sets = %{$hash_ref};
	my @keys = sort { $b <=> $a } keys %working_sets;

	for(1..scalar(@keys)-1) {
		my $left_ref = $working_sets{$_ - 1};
		my $right_ref = $working_sets{$_};

		my $end = $$left_ref[-1] + $$right_ref[-1];
		push @$right_ref, $end;
	}

	my $max_key = max(keys %working_sets);
	return @{$working_sets{$max_key}}[-1];
}
1;

__DATA__
0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45