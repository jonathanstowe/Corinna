use strict;
use warnings;

use Test::Most 'no_plan';


use_ok('Corinna');

my $pastor = Corinna->new();

my $verbose = 0;

lives_ok
{
$pastor->generate(
                   mode         => 'eval',
                   schema       => ['./test/source/bugs/schema/local_complex_type.xsd'],
                   class_prefix => "Attribute::Test::Default",
                   destination  => './test/out/lib/',
                   verbose      => $verbose );
} "generate with XSD as default namespace and local complexType";


my $class = Attribute::Test::Default::Corinna::Meta->Model->xml_item_class('TestElement');

can_ok($class,'test_attribute');

