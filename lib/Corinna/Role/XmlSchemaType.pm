package Corinna::Role::XmlSchemaType;

use Moose::Role;

use MooseX::ClassAttribute;

class_has XmlSchemaType => (
                              is => 'rw',
                              isa   => 'Corinna::Schema::Object',
                              lazy  => 1,
                              builder  => '_get_xml_schema_type',
                           );

1;
