use Test::Most;

eval 
{
   require DateTime;
   require DateTime::Format::W3CDTF;
};
if ($@)
{
   plan skip_all => 'DateTime and DateTime::Format::W3CDTF required for date tests';
}
else
{
   plan 'no_plan';
}

use_ok('Corinna');

my $pastor = Corinna->new();

$pastor->generate(
                   mode         => 'eval',
                   schema       => ['./test/source/bugs/schema/DateTest.xsd'],
                   class_prefix => "Corinna::Test",
                   destination  => './test/out/lib/',
                   verbose      => 0
);

my $class = Corinna::Test::Corinna::Meta->Model->xml_item_class('DateTest');

my $obj = $class->new();

my $date = DateTime->today();

my $item_class = $obj->xml_field_class('date_test');

eval 
{
   my $bd = $item_class->from_date_time($date);
   isa_ok($bd, $item_class) ; # actual real bug there
   $obj->date_test($bd);
   isa_ok($bd->to_date_time(),"DateTime");
};
if ($@)
{

   diag $@;
   # Can't locate object method "value" via package "Corinna::Builtin::date"
   fail("setFromDateTime works");
}
else
{
   pass("setFromDateTime works");
}

ok($obj->date_test()->xml_validate_further(), "xml_validate_further ok");

eval
{
   $obj->date_test('20-13-2012');
   $obj->date_test->to_date_time();
};

if ($@ )
{
   pass("to_date_time() on invalid date croaks");
}
else
{
   fail("to_date_time() on invalid date croaks");

}

ok(!$obj->date_test()->xml_validate_further(), "xml_validate_further bad");

1;
