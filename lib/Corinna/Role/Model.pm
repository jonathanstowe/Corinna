package Corinna::Role::Model;

use utf8;
use strict;
use warnings;

use Moose::Role;

use MooseX::ClassAttribute;

our $VERSION = '2.91';

=head1 NAME

Corinna::Role::Model

=head1 DESCRIPTION

This provides the C<Model> class attribute, that will contain the
entire L<Corinna::Schema::Model> for a schema.  This is provided as
a role in order that the ClassAttribute semantics (which differ from
that of L<Class::Data::Inheritable> don't confuse matters.)

=over 4

=item Model

The L<Corinna::Schema::Model>

=cut

class_has Model   => (
                  is => 'rw',
                  isa   => 'Corinna::Schema::Model',
               );

=back

=cut

1;

__END__
