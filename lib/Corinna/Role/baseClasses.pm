package Corinna::Role::baseClasses;

use Moose::Role;

has baseClasses => (
               is => 'rw',
               isa   => 'ArrayRef',
               lazy  => 1,
               default  => sub { [] },
             );

1;
