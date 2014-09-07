package Corinna::Role::XmlSchemaElement;

use Moose::Role;

use MooseX::ClassAttribute;

class_has XmlSchemaElement => (
                              is => 'rw',
                              isa   => 'Corinna::Schema::Object',
                              lazy  => 1,
                              builder  => '_xml_schema_element',
                           );

1;
