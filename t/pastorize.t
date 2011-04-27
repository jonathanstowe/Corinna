
use Test::Most qw(no_plan);


use_ok('Corinna::Pastorize');

ok(my $obj = Corinna::Pastorize->new(),"new");

isa_ok($obj, 'Corinna::Pastorize');

lives_ok { $obj->run() } "run inncomplete args";



