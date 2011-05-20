use Test::Most qw(no_plan);

use_ok('Corinna');

my $pastor = Corinna->new();

$pastor->generate(
                   mode         => 'eval',
                   schema       => ['./test/source/builtins/list/list.xsd'],
                   class_prefix => "Corinna::Test",
                   destination  => './test/out/lib/',
                   verbose      => 0
);

my $class = Corinna::Test::Corinna::Meta->Model->xml_item_class('ListTest');

my $obj = $class->from_xml_file('./test/source/builtins/list/list.xml');

my $list = $obj->intvalues()->[0];

ok(my @list = $list->to_list(), "to_list");
is(@list, 5, "got the right number");

ok(my $sc_list = $list->to_list(), "to_list (scalar)");
is(@$sc_list, 5, "got the right number");

foreach my $item (qw(100 34 56 -23 1567))
{
   ok($item ~~ @list,"got item $item");
}

my $item_class = $obj->xml_field_class('intvalues');

ok(my $new_list = $item_class->from_list(qw(1 2 3 4 5 6 7)),"from_list");

isa_ok($new_list, $item_class, "BUG: it's return the value not the object");

ok($new_list->xml_validate(),"xml_validate");

ok(my $bad_list = $item_class->from_list(qw(A B C D E F G)),"from_list (non int)");

TODO:
{
   local $TODO = "Doesn't seem to be validating";
   ok(!$bad_list->xml_validate(),"xml_validate (non int)");
}

1;
