
use Test::Most tests => 2;

use_ok('Corinna');

my $pastor = Corinna->new();

lives_ok {
$pastor->generate(
    mode         => 'eval',
    schema       => ['./test/source/mathworks/schema/product.xsd'],
    class_prefix => "Corinna::Test::MathWorks::",
    destination  => './test/out/lib/',
    verbose      => 0
)
} "eval on product.xsd ok";


1;

