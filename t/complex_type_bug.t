use Test::Most 'no_plan';
use Corinna;

use File::Path;

my $verbose = 0;

rmtree( ['./test/out/lib'] );

my $pastor = Corinna->new();
lives_ok {
    $pastor->generate(
        mode  => 'offline',
        style => 'multiple',
        schema =>
          ['./test/source/bugs/schema/complex_type_from_simple_type.xsd'],
        class_prefix => "Corinna::Test",
        destination  => './test/out/lib/',
        verbose      => $verbose
    );
}
'Complex types which extend simple types should survive';

rmtree( ['./test/out/lib'] );

    lives_ok {
        $pastor->generate(
            mode  => 'eval',
            style => 'multiple',
            schema =>
              ['./test/source/bugs/schema/complex_type_from_simple_type.xsd'],
            class_prefix => "Corinna::Test",
            destination  => './test/out/lib/',
            verbose      => $verbose 
        );
    }
    'Complex types which extend simple types should survive when eval mode';
