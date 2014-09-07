package Corinna::Element;

use strict;
use warnings;

use Moose;
extends qw(Corinna::ComplexType);
with qw(Corinna::Role::XmlSchemaElement);
use MooseX::StrictConstructor;

our $VERSION = '2.91';

1;
