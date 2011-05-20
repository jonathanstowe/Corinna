use Test::Most 'no_plan';


use_ok('Corinna');

my $pastor = Corinna->new();

# The <xs:documentation /> element is anyType - the xml namespaces
# schema for instance contains xhtml - we don't want to cark it
# when we encounter this.

lives_ok
{
$pastor->generate(
                   mode         => 'eval',
                   schema       => ['./test/source/w3c/xml.xsd'],
                   class_prefix => "W3C::Test",
                   destination  => './test/out/lib/',
                   verbose      => 0 
);
} "can parse schema with non-XSD namespace in documentation";

1;
