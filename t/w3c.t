use Test::More 'no_plan';


use_ok('Corinna');

my $pastor = Corinna->new();

$pastor->generate(
                   mode         => 'eval',
                   schema       => ['./test/source/w3c/AnnotatedTSSchema.xsd'],
                   class_prefix => "W3C::Test",
                   destination  => './test/out/lib/',
                   verbose      => 0 
);

__END__
my $class = W3C::Test::Pastor::Meta->Model->xml_item_class('testSuite');

my $obj;

eval
{
   $obj = $class->from_xml_file('./test/source/w3c/suite.xml');
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
