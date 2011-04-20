use Test::More 'no_plan';


use_ok('Corinna');

my $pastor = Corinna->new();

$pastor->generate(
                   mode         => 'eval',
                   schema       => ['./test/source/bugs/schema/no_type.xsd'],
                   class_prefix => "Corinna::Test",
                   destination  => './test/out/lib/',
                   verbose      => 0
);

my $class = Corinna::Test::Pastor::Meta->Model->xml_item_class('Test');

my $obj;

eval
{
   $obj = $class->from_xml_file('./test/source/bugs/xml/no_type.xml');
};
if ($@)
{
   fail("doesn't croak with an implicit anyType");
   diag $@;
}
else
{
   pass("doesn't croak with an implicit anyType");
}

1;
