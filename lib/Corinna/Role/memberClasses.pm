package Corinna::Role::memberClasses;

use strict;
use warnings;
 
use Moose::Role;

has memberClasses => (
      is => 'rw',
      isa   => 'ArrayRef',
      lazy  => 1,
      default  => sub { [] },
);

1;

