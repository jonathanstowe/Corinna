package Corinna::Role::Generator;

use strict;
use warnings;

use Moose::Role;
with qw(Corinna::Role::Verbose);

=head1 NAME

Corinna::Role::Generator

=head1 DESCRIPTION

This provides the attributes for the generator classes.

=head2 METHODS

=over 4

=item class_prefix

=cut

has class_prefix => (
      is => 'rw',
      isa   => 'Str',
      );

=item destination

=cut

has destination  => (
      is => 'rw',
      isa   => 'Str',
      );

=item metaModule

=cut

has metaModule  => (
      is => 'rw',
      isa   => 'Str',
      );

=item mode

=cut


has mode  => (
      is => 'rw',
      isa   => 'Str',
      );

=item model

=cut

has model  => (
      is => 'rw',
      isa   => 'Corinna::Schema::Model',
      );

=item schema

=cut

has schema  => (
      is => 'rw',
      isa   => 'ArrayRef',
      default  => sub { [] },
      );

=item style

=cut

has style => (
      is => 'rw',
      isa   => 'Str',
      );

=item module

=cut

has module  => (
      is => 'rw',
      isa   => 'Str',
      );

=back

=cut


1;
