package Corinna::Schema;
use utf8;
use strict;
use warnings;

#=======================================================

use Corinna::Schema::Attribute;
use Corinna::Schema::AttributeGroup;
use Corinna::Schema::ComplexType;
use Corinna::Schema::Context;
use Corinna::Schema::Documentation;
use Corinna::Schema::Element;
use Corinna::Schema::Group;
use Corinna::Schema::List;
use Corinna::Schema::Model;
use Corinna::Schema::NamespaceInfo;
use Corinna::Schema::Parser;
use Corinna::Schema::SimpleType;
use Corinna::Schema::Union;

use Moose;
extends qw(Corinna::Schema::Object);


our $VERSION = '2.91';

has targetNamespace => (
               is => 'rw',
               isa   => 'Str',
             );

has attributeFormDefault => (
               is => 'rw',
               isa   => 'Str',
             );

has elementFormDefault => (
               is => 'rw',
               isa   => 'Str',
             );

1;
