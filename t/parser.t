
use strict;
use warnings;


use Test::Most qw(no_plan);

use_ok('Corinna::Schema::Parser');

# tests to improve the coverage on the Parser piece

ok(my $parser = Corinna::Schema::Parser->new(),"new()");

