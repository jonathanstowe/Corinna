package Corinna::Role::Verbose;

use strict;
use warnings;

use Moose::Role;

has verbose => (
                  is => 'rw',
                  isa   => 'Int',
                  lazy  => 1,
                  default  => 0,
               );

1;
