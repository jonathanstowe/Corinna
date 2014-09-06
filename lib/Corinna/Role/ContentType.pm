package Corinna::Role::ContentType;

use strict;
use warnings;
 
use Moose::Role;

has contentType => (
   is      => 'rw',
   isa     => 'Str',
   predicate   => 'has_content_type',
);

1;

