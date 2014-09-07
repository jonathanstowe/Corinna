package Corinna::Generator::Dynamic;

use strict;
use warnings;
 
use Moose;
with qw(
         Corinna::Role::Generator
       );

use MooseX::Aliases;
use MooseX::Aliases::Meta::Trait::Attribute;

use MooseX::StrictConstructor;

our $VERSION = '2.91';

=head1 NAME

Corinna::Generator::Dynamic

=head1 DESCRIPTION

This is the class that is used to generate the schema classes dynamically.

=head2 METHODS

=over 4

=item generate

This is the method that will actuall create the classes.  It doesn't
take any arguments as these will all have been passed to the constructor


=cut

sub generate
{
    my ( $self ) = @_;

    $self->generate_meta();
    $self->generate_classes();
}


=item generate_meta

This generates the L<Corinna::Meta> sub-class that will be used to contain
the model data for the schema.

=cut

sub generate_meta
{
    my ( $self ) = @_;

    my $class = $self->metaModule();
    my $supers = [qw(Corinna::Meta)];
    my $roles  = [qw(Corinna::Role::Model)];

    my @opts = (
                 superclasses => $supers,
                 roles  => $roles,
               );

    my $meta_meta = Moose::Meta::Class->create($class => @opts);

    $class->Model($self->model()->clone());
}

=item generate_classes

This generates the classes for the actual schema. The build of the
work is done per required class in generate_class.

=cut

sub generate_classes
{
    my ( $self ) = @_;

    foreach my $items ( $self->model()->items() )
    {
        foreach my $name ( sort keys %{$items} )
        {
            my $object = $items->{$name};
            $self->generate_class($object);
        }
    }
}

=item generate_class

This dynamically creates the actual class. It takes a L<Corinna::Schema::Object>
as its only argument.

=cut

sub generate_class
{
    my ( $self, $object ) = @_;

    my $class = $object->class();
    my $supers = $object->baseClasses();
    my $roles  =  $object->class_roles();
    my $attrs = $self->_generate_attributes($object);

    my $info_attr = $object->xml_info_attribute();

    my @opts = (
      roles  => $roles,
      superclasses  => $supers,
      attributes  => $attrs,
    );

    my $meta = Moose::Meta::Class->create($class => @opts);

    $class->$info_attr($object->clone());
}


=item _generate_attributes

If this is a L<Corinna::Schema::ComplexType> then this returns an
ArrayRef of attributes L<Moose::Meta::Attribute> to be added to the
class representing the attributes and elements of the XML type.

=cut

sub _generate_attributes
{
    my ( $self, $object ) = @_;

   my $attrs = [];
   if ( $object->isa('Corinna::Schema::ComplexType') )
   {
       foreach my $item ( $self->_complex_attrs($object) )
       {
           my ($name, $alias) = $self->_get_attr_name_alias($item, $object);

           my $class = $self->_get_attribute_type($item);

           my @opts = (
                        is => 'rw',
                        isa   => $class,
                      );

           if (defined $alias )
           {
               push @opts, (alias => $alias, traits => [qw(Aliased)]);
           }

           push @{$attrs}, Moose::Meta::Attribute->interpolate_class_and_new($name => @opts);
       }
   }

   return $attrs;

}

=item _get_attribute_type

This returns the appropriate type to feed to the 'isa' of the attribute
will get created for the attributes or elements

=cut

sub _get_attribute_type
{
    my ( $self, $item ) = @_;

    my $type = $item->class();

    if ( $item->isa('Corinna::Schema::Element') )
    {
        if (!$item->is_singleton() )
        {
            $type = 'Corinna::NodeArray';
        }
    }

    return $type;
}


=item _get_attr_name_alias

This returns a two element list consisting of the name and an alias
that may be provided to the attribute constructor.  The alias will
only be provided for an attribute where there is no existing element
with the same name.

It takes the item and the object as arguments.

=cut

sub _get_attr_name_alias
{
    my ( $self, $item, $object ) = @_;

    my $alias;
    my $name = $item->name();

    if ( $item->isa('Corinna::Schema::Attribute') )
    {
        if ( !exists $object->elementInfo()->{$name} )
        {
            $alias = $name;
        }
        $name = $object->attributePrefix() . $name;
    }

    return ( $name, $alias );
}



=item _complex_attrs


=cut

sub _complex_attrs
{
    my ( $self, $object ) = @_;

    my @attrs = (
                  values %{$object->attribute_info()},
                  values %{$object->elementInfo()}
                 );

   return @attrs;
}



=back

=cut

1;

