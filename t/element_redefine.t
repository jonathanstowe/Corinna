use strict;
use warnings;

use Test::Most 'no_plan';


use_ok('Corinna');

my $pastor = Corinna->new();

my $verbose = 10;

TODO:
{
   local $TODO = "redefine doesn't appear to work at present";
lives_ok
{
$pastor->generate(
                   mode         => 'eval',
                   schema       => ['./test/source/elements/schema/redefine_2.xsd'],
                   class_prefix => "Attribute::Test::Default",
                   destination  => './test/out/lib/',
                   verbose      => $verbose );
} "generate with redefine";


my $class;
lives_ok { $class = Attribute::Test::Default::Pastor::Meta->Model->xml_item_class('author')} "got class of element";

can_ok($class,'country');
}
