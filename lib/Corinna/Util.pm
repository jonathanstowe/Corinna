package Corinna::Util;
use utf8;
use strict;
use warnings;

use XML::LibXML;
use Scalar::Util qw(blessed);
use File::Spec;

use parent 'Exporter';

our $VERSION = '2.0';

our @EXPORT    = qw();
our @EXPORT_OK = qw(merge_hash
                    get_attribute_hash
                    get_children_hash_dom
                    module_path
                    slurp_file
                    sprint_xml_doc
                    sprint_xml_element
                    validate_date
                    validate_time
                    );

#------------------------------------------------------------------
# merge h2 into h1;
#------------------------------------------------------------------
sub merge_hash {
    my $h1 = shift;
    my $h2 = shift;

    for my $key ( keys %$h2 ) {
        $h1->{$key} = $h2->{$key};
    }

    return $h1;
}

#------------------------------------------------------------
# This is a utility function (not a method) that will get all the attributes
# of an DOM element into a hash and return that hash.
#-------------------------------------------------------------
sub get_attribute_hash
{
   my $node = shift;
   my $attribs;

   if ( blessed($node) && $node->isa("XML::LibXML::Element") )
   {
      $attribs = {};
      my @attributes = $node->attributes();
      foreach my $attribute (@attributes)
      {

         $attribs->{ $attribute->nodeName() } = $attribute->value();
      }
   }
   return $attribs;
}

#------------------------------------------------------------
# This is a utility function (not a method) that will get all the children
# of an DOM element into a hash of arrays and return that hash.
#-------------------------------------------------------------
sub get_children_hash_dom
{
   my $node = shift;
   my $result;

   if ( blessed($node) && $node->isa("XML::LibXML::Element") )
   {
      $result = {};

      my @children = grep { $_->isa("XML::LibXML::Element") }
                     $node->childNodes();

      foreach my $child (@children)
      {

         my $name = $child->localName();
         unless ( defined( $result->{$name} ) )
         {
            $result->{$name} = [];
         }
         push @{ $result->{$name} }, $child;
      }
   }

   return $result;
}

#------------------------------------------------------------
# A DEBUG routine that prints out an XMLish document given a DOM document.
#-------------------------------------------------------------
sub sprint_xml_doc() {
    my $dom = shift;
    my $s   = "";

    $s .= "\n<xml version=\"1.0\">\n";
    my $root = $dom->documentElement();
    $s .= sprint_xml_element($root);
    $s .= "\n</xml>\n";
    return $s;
}

#------------------------------------------------------------
# A DEBUG routine that returns an XMLish element string given a DOM element.
#-------------------------------------------------------------
sub sprint_xml_element($;$)
  ;    # warning if the compiler doesn't see a prototype in a recursive call.

sub sprint_xml_element($;$) {
    my $elem       = shift;
    my $indent     = shift || 0;
    my $s          = "";
    my $name       = $elem->localName();    #$elem->nodeName();
    my @attributes = $elem->attributes();
    $s .= _sprint_indent($indent);
    $s .= "<$name ";
    foreach my $attribute (@attributes) {
       # pretty certain this isn't needed either
       # next unless defined $attribute;
        $s .= $attribute->nodeName() . "=\"" . $attribute->value() . "\" ";
    }
    my @children = grep { $_->isa( "XML::LibXML::Element" ) } 
                   $elem->childNodes();
    unless ( scalar(@children) ) {
        $s .= "/>";
    }
    else {
        $s .= ">";
        foreach my $child (@children) {
            $s .= sprint_xml_element( $child, $indent + 1 );
        }
        $s .= _sprint_indent($indent);
        $s .= "</$name>";
    }
    return $s;
}

#------------------------------------------------------------
# A DEBUG routine that helps the print_xml_element family
#-------------------------------------------------------------
sub _sprint_indent() {
    my $indent = shift;
    my $s      = "";
    $s .= "\n";
    for ( my $i = 0 ; $i < $indent ; $i++ ) {
        $s .= "  ";
    }
    return $s;
}

#------------------------------------------------------------
# Slurps an entire file into memory and returns the resulting string
#-------------------------------------------------------------
sub slurp_file {
    my $file = shift;

    local ($/);
    open( my $fh, $file )
      or die "Corinna::Util : slurp_file : Can't open file $file\n";
    return <$fh>;
}

#------------------------------------------------------------
# module_path
# Given a module name (without the .pm) and a destination directory,
# Compute the file path where the module would be written to.
#-------------------------------------------------------------
sub module_path 
{
    my $args        = {@_};
    my $module      = $args->{module} || die "Need a module name!";
    my $destination = $args->{destination} || _tmp_dir();

    # this is so much more sensible  
    my @bits = split '::', $module;

    my $file = File::Spec->catfile($destination, @bits) . '.pm';

    return $file;
}

# This returns the default location for creation of the modules
# # if none is supplied in the arguments.
# # This is by default /tmp/lib/perl (or its platform specific equivalent
#
sub _tmp_dir
{
   return File::Spec->catfile(File::Spec->tmpdir(),'lib','perl');
}


#------------------------------------------------
# code taken from XML::Schema::Validate who took it from Date::Simple
#--------------------------------------------------
our @days_in_month = (
    [ 0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ],
    [ 0, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ]
);

sub validate_date ($$$)
{
   my ( $y, $m, $d ) = @_;

   my $rc = 0;

   # any +ve integral year is valid
   if ( defined $y && defined $m && defined $d )
   {
      $rc = 1;
      $rc = 0 if $y != abs int $y;
      $rc = 0 unless 1 <= $m and $m <= 12;
      my $dim = $days_in_month[ _leap_year($y) ][$m];
      $rc = 0 unless 1 <= $d and (defined $dim && $d <= $dim);
   }

   return $rc;
}

sub _leap_year {
    my $y = shift;
    return ( ( $y % 4 == 0 ) and ( $y % 400 == 0 or $y % 100 != 0 ) ) || 0;
}

#------------------------------------------------
sub validate_time ($$$) {
    my ( $h, $m, $s ) = @_;

    return 0 if $h != abs int $h;
    return 0 if $m != abs int $m;
    return 0 unless $h <= 23;  
    return 0 unless $m <= 59;
    return 0 unless 0 <= $s and $s <= 61;    # Leap seconds can be upto 61!!!
    return 1;
}

#

1;
