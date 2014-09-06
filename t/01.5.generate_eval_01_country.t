
use Test::Most tests => 2;

use_ok('Corinna');

my $pastor = Corinna->new(verbose => 66);

lives_ok {
$pastor->generate(
    mode         => 'eval',
    schema       => ['./test/source/country/schema/country_schema1.xsd'],
    class_prefix => "Corinna::Test",
    destination  => './test/out/lib/',
    verbose      => 0
)
} "eval on country_schema1.xsd ok";


1;

