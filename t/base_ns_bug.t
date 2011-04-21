use Test::More 'no_plan';


use_ok('Corinna');

my $pastor = Corinna->new();

my $verbose = 0;

eval
{
$pastor->generate(
                   mode         => 'eval',
                   schema       => ['./test/source/bugs/schema/base_ns_bug_default.xsd'],
                   class_prefix => "Base::Test::Default",
                   destination  => './test/out/lib/',
                   verbose      => $verbose 
);
};

if ( $@ )
{
   fail("resolve namespace of restriction base correctly with default NS");
}
else
{

   pass("resolve namespace of restriction base correctly with default NS");
}

eval
{
$pastor->generate(
                   mode         => 'eval',
                   schema       => ['./test/source/bugs/schema/base_ns_bug_default_reordered.xsd'],
                   class_prefix => "Base::Test::Default::Reordered",
                   destination  => './test/out/lib/',
                   verbose      => $verbose 
);
};

if ( $@ )
{
   fail("resolve namespace of restriction base correctly with default NS but NS declarations reordered");
}
else
{

   pass("resolve namespace of restriction base correctly with default NS but NS declarations reordered");
}


eval
{
$pastor->generate(
                   mode         => 'eval',
                   schema       => ['./test/source/bugs/schema/base_ns_bug_prefix.xsd'],
                   class_prefix => "Base::Test::Prefix",
                   destination  => './test/out/lib/',
                   verbose      => $verbose 
);
};

if ( $@ )
{
   fail("resolve namespace of restriction base correctly with explicit NS");
}
else
{
   pass("resolve namespace of restriction base correctly with explicit NS");
}
