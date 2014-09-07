package Corinna::Generator::Dynamic;

use strict;
use warnings;
 
use Moose;
with qw(
         Corinna::Role::Generator
       );

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
                 super_classes => $supers,
                 roles  => $roles,
               );

    my $meta_meta = Moose::Meta::Class->create($class => @opts);

    $class->Model($self->model()->clone());
}


=back

=cut

1;

