use Test::Most 'no_plan';


use_ok('Corinna');

my $pastor = Corinna->new();

my $verbose = 0;

lives_ok
{
$pastor->generate(
                   mode         => 'eval',
                   schema       => ['./test/source/bugs/schema/base_ns_bug_default.xsd'],
                   class_prefix => "Base::Test::Default",
                   destination  => './test/out/lib/',
                   verbose      => $verbose 
);
} "resolve namespace of restriction base correctly with default NS";

lives_ok
{
$pastor->generate(
                   mode         => 'eval',
                   schema       => ['./test/source/bugs/schema/base_ns_bug_default_reordered.xsd'],
                   class_prefix => "Base::Test::Default::Reordered",
                   destination  => './test/out/lib/',
                   verbose      => $verbose 
);
} "resolve namespace of restriction base correctly with default NS but NS declarations reordered";

lives_ok
{
$pastor->generate(
                   mode         => 'eval',
                   schema       => ['./test/source/bugs/schema/base_ns_bug_prefix.xsd'],
                   class_prefix => "Base::Test::Prefix",
                   destination  => './test/out/lib/',
                   verbose      => $verbose 
);
} "resolve namespace of restriction base correctly with explicit NS";

