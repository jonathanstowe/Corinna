
use strict;
use warnings;

use Test::More qw(no_plan);

# tests for Corinna::Util

use_ok('Corinna::Util');

# quick wins on the rejects;

ok(!Corinna::Util::get_attribute_hash(),"get_attribute_hash() - no args");
ok(!Corinna::Util::get_attribute_hash(bless {},"foo"),"get_attribute_hash() - random args");

ok(!Corinna::Util::get_children_hash_dom(),"get_children_hash_dom() - no args");
ok(!Corinna::Util::get_children_hash_dom(bless {},"foo"),"get_children_hash_dom() - random args");


# XMLy things

use XML::LibXML;

my $doc = XML::LibXML::Document->createDocument();
my $root = $doc->createElement('TestElement');
$doc->setDocumentElement($root);
my $child = $doc->createElement('TestChild');
$root->addChild($child);
my $child_attr1 = $doc->createAttribute("attr1","foo");
$child->addChild($child_attr1);
my $child_attr2 = $doc->createAttribute("attr2");
$child->addChild($child_attr1);

ok(Corinna::Util::sprint_xml_doc($doc),"sprint_xml_doc");

# consider replacing with File::Slurp

eval 
{
   Corinna::Util::slurp_file("/some/file/that/better/not/exist$$");
};
if ( $@ )
{
   pass("slurp_file dies if it can't open the file");
}
else
{
   fail("slurp_file dies if it can't open the file");
}

ok(Corinna::Util::slurp_file($0),"slurp_file");

eval
{
   Corinna::Util::module_path();
};

if ($@ )
{
   pass("module_path() dies without a module name");
}
else
{
   fail("module_path() dies without a module name");
}

is(Corinna::Util::module_path(module => 'Foo::Bar'),'/tmp/lib/perl/Foo/Bar.pm',"module_path - no destination");
is(Corinna::Util::module_path(module => 'Foo::Bar::'),'/tmp/lib/perl/Foo/Bar.pm',"module_path - no destination - trailing colons");
is(Corinna::Util::module_path(module => 'Foo::Bar', destination => '/tmp/lib/perl'),'/tmp/lib/perl/Foo/Bar.pm',"module_path - with destination");

# datey things

ok(!Corinna::Util::validate_date(-25,1,1),"invalid year -ve");
ok(!Corinna::Util::validate_date(2.5,1,1),"invalid year not integer");
ok(Corinna::Util::validate_date(25,1,1),"valid year");
ok(!Corinna::Util::validate_date(25,0,1),"invalid month 0");
ok(!Corinna::Util::validate_date(25,13,1),"invalid month 13");

my $mon = 1;
foreach my $days ( ( 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31) )
{
   ok(Corinna::Util::validate_date(25,$mon,$days),"valid days $days month $mon");
   ok(!Corinna::Util::validate_date(25,$mon,0),"invalid days 0 month $mon");
   ok(!Corinna::Util::validate_date(25,$mon,$days + 6),"invalid days month $mon");
   $mon++;

}

my %leap_test = (
   1700     => 0,
   1800     => 0,
   1900     => 0,
   1980     => 1,
   1984     => 1,
   1999     => 0,
   2000     => 1,
   2003     => 0,
   2004     => 1,
   2005     => 0,
   2012     => 1,
   2020     => 1,
);

foreach my $year ( keys %leap_test )
{
   is(Corinna::Util::_leap_year($year), $leap_test{$year},"_leap_year($year) is correct");
}


ok(Corinna::Util::validate_time(0,0,0),"validate_time() - valid (0,0,0) ");
ok(!Corinna::Util::validate_time(-1,0,0),"validate_time() - invalid hour -ve");
ok(!Corinna::Util::validate_time(1.5,0,0),"validate_time() - invalid hour fraction");
ok(!Corinna::Util::validate_time(24,0,0),"validate_time() - invalid hour too big");
ok(!Corinna::Util::validate_time(12,-10,0),"validate_time() - invalid minute -ve");
ok(!Corinna::Util::validate_time(12,1.5,0),"validate_time() - invalid minute fractione");
ok(!Corinna::Util::validate_time(12,99,0),"validate_time() - invalid minute too big");
ok(!Corinna::Util::validate_time(12,15,-10),"validate_time() - invalid seconds -ve");
ok(!Corinna::Util::validate_time(12,15,99),"validate_time() - invalid seconds too big");


1;
