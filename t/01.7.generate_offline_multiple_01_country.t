
use Test::Most tests => 3;

use File::Path;
use_ok('Corinna');

rmtree( ['./test/out/lib'] );

my $pastor = Corinna->new();

lives_ok {
$pastor->generate(
    mode         => 'offline',
    style        => 'multiple',
    schema       => ['./test/source/country/schema/country_schema1.xsd'],
    class_prefix => "Corinna::Test",
    destination  => './test/out/lib/',
    verbose      => 0
) } "offline on country_schema1.xsd OK";

lives_ok {
            use lib qw (./test/out/lib/); 
            require Corinna::Test;
         } "Generated usable module";

# be kind rewind
END
{
   rmtree( ['./test/out'] );
}

1;

