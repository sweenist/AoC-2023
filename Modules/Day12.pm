package Modules::Day12;
use strict;
use warnings;

use Exporter qw( import );
our @ISA = qw( Exporter );
our @EXPORT_OK = qw( part_one part_two );

use feature qw( say );
use List::AllUtils qw( sum );
use Data::Dumper::Perltidy;

#---------------------------------------------------------------------------


sub part_one {
	my ($file) = @_;
	my $aggregate = 0;

	while(my $line = <$file>) {
		chomp($line);
		my ($pattern, $csv) = split / /, $line;
		my @counts = split /,/, $csv;
		my $validation_regex = get_validation(\@counts);
		my @pattern_shards = ($pattern);
		my @bloated = bloatify(\@pattern_shards);
		my $bloat_ref = \@{$bloated[0]};

		$aggregate += scalar validate_pattern($bloat_ref, $validation_regex);
	}

	return $aggregate;
}

#---------------------------------------------------------------------------


sub part_two {
	my ($file) = @_;

	return "not implemented";
}

#---------------------------------------------------------------------------


sub get_validation() {
	my $count_ref = shift;

	my $return = '^\.*';
	for(0..$#$count_ref) {
		my $v = $count_ref->[$_];
		$return = $return."(#{$v})";
		$return = $return.q/\.+/ unless $_ == $#$count_ref;
	}
	$return = $return.'\.*$';
	return qr /$return/;
}


sub bloatify {
	my $char_ref = shift;

	my @new = ();

	foreach my $line (@$char_ref){
		if($line =~ m/\?/) {
			for(('#','.')) {
				substr($line, $-[0], 1) = $_;
				push @new, $line;
			}
		} else {
			return \@$char_ref;
		}
	}
	return bloatify(\@new);
}


sub validate_pattern {
	my $possible_ref = shift;
	my $reg_pattern = shift;

	my @results;
	for(@$possible_ref) {
		if($_ =~ m/$reg_pattern/) {
			push @results, $_;
		}
	}
	return @results;
}

1;

__DATA__
???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1