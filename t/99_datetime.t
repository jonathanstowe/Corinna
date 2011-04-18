use Test::More;

eval 
{
   require DateTime;
   require DateTime::Format::W3CDTF;
};
if ($@)
{
   plan skip_all => 'DateTime required for date tests';
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

my $class = Corinna::Test::Pastor::Meta->Model->xml_item_class('DateTest');

my $obj = $class->new();

my $date = DateTime->today();

eval 
{
   my $bd = Corinna::Builtin::date->from_date_time($date);
   $obj->date_test($bd);
};
if ($@)
{

   diag $@;
   # Can't locate object method "value" via package "XML::Pastor::Builtin::date"
   fail("setFromDateTime works");
}
else
{
   pass("setFromDateTime works");
}

1;
