use Test::Most 'no_plan';


use_ok('Corinna');

my $pastor = Corinna->new();

lives_ok
{
$pastor->generate(
                   mode         => 'eval',
                   schema       => ['./test/source/w3c/AnnotatedTSSchema.xsd'],
                   class_prefix => "W3C::Test",
                   destination  => './test/out/lib/',
                   verbose      => 0 
);
} "Can parse the W3C testSuite schema";

my $class = W3C::Test::Corinna::Meta->Model->xml_item_class('testSuite');

my $obj;

lives_ok
{
   $obj = $class->from_xml_file('./test/source/w3c/suite.xml');
} "resulting classes can parse example XML";

1;
