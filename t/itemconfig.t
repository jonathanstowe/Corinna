use Test::Most 'no_plan';


use_ok('Corinna');

my $pastor = Corinna->new();

my $VERBOSITY = 0;

lives_ok
{
$pastor->generate(
                   mode         => 'eval',
                   schema       => ['./test/source/itemconfig/schema/ItemConfig.xsd'],
                   class_prefix => "ItemConfig",
                   destination  => './test/out/lib/',
                   verbose      => $VERBOSITY 
);
} "Can parse the W3C testSuite schema";

my $class = ItemConfig::Corinna::Meta->Model->xml_item_class('ItemConfig');

my $obj;


1;
