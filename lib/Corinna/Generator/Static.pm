package Corinna::Generator::Static;

use strict;
use warnings;
 
use Moose;
with qw(
         Corinna::Role::Generator
       );

use MooseX::StrictConstructor;

our $VERSION = '2.91';

=head1 NAME

Corinna::Generator::Static

=head1 DESCRIPTION

This is the class that is used to generate the schema classes statically.

=head2 METHODS

=over 4

=item generate

This is the method that will actuall create the classes.  It doesn't
take any arguments as these will all have been passed to the constructor


=cut

sub generate
{
    my ( $self ) = @_;
}



=back

=cut

1;

