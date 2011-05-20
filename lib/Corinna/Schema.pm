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

use parent 'Corinna::Schema::Object';

our $VERSION = '2.0';

Corinna::Schema->mk_accessors(
    qw( targetNamespace attributeFormDefault elementFormDefault ));

1;
