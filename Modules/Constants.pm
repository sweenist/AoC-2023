package Modules::Constants;
use strict;
use warnings;

use Exporter qw( import );
our @ISA = qw( Exporter );
our @EXPORT_OK = qw( TRUE FALSE );

#---------------------------------------------------------------------------
use constant TRUE => 1;
use constant FALSE => 0;

1;