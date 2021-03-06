package Corinna;

use utf8;
use strict;
use warnings;

require 5.008;

use Corinna::Builtin;
use Corinna::ComplexType;
use Corinna::Element;
use Corinna::Generator;
use Corinna::Meta;
use Corinna::NodeArray;
use Corinna::Schema;
use Corinna::SimpleType;
use Corinna::Stack;
use Corinna::Util;

our $VERSION = 2.0;

#------------------------------------------------------------
sub new {
    my $class = shift;
    my $self  = {@_};
    return bless $self, $class;
}

#--------------------------------------------------------
sub version {
    return $Corinna::VERSION;
}

#--------------------------------------------------------
sub generate {
    my $self    = shift;
    my $args    = {@_};
    my $verbose = $args->{verbose} || $self->{verbose} || 0;

    my $parser = Corinna::Schema::Parser->new( verbose => $verbose );
    my $model = $parser->parse( @_, verbose => $verbose );

    print STDERR "\n========= AFTER PARSE =============\n"
      . $model->dump() . "\n\n"
      if ( $verbose >= 8 );

    $model->resolve( @_, verbose => $verbose );
    print STDERR "\n========= AFTER RESOLVE =============\n"
      . $model->dump() . "\n\n"
      if ( $verbose >= 8 );

    my $generator = Corinna::Generator->new( verbose => $verbose );
    my $result =
      $generator->generate( @_, model => $model, verbose => $verbose );

    print STDERR "\n========= AFTER GENERATE =============\n"
      . $model->dump() . "\n\n"
      if ( $verbose >= 8 );

    return $result;
}

1;

__END__


=head1 NAME

B<Corinna> - Generate Perl classes with XML bindings starting from a W3C XSD Schema

=head1 VERSION

2.0

=head1 SYNOPSIS

    use Corinna;

    my $corinna = Corinna->new();

    # Generate MULTIPLE modules, one module for each class, and put them under destination.

    $corinna->generate(
        mode         => 'offline',
        style        => 'multiple',
        schema       => '/some/path/to/schema.xsd',
        class_prefix => 'MyApp::Data::',
        destination  => '/tmp/lib/perl/',
    );

    # Generate a SINGLE module which contains all the classes and put it under destination.
    # Note that the schema may be read from a URL too.

    $corinna->generate(
        mode         => 'offline',
        style        => 'single',
        schema       => 'http://some/url/to/schema.xsd',
        class_prefix => 'MyApp::Data::',
        module       => 'Module',
        destination  => '/tmp/lib/perl/',
    );

    # Generate classes in MEMORY, and EVALUATE the generated code on the fly.
    # (Run Time code generation)

    $corinna->generate(
        mode         => 'eval',
        schema       => '/some/path/to/schema.xsd',
        class_prefix => 'MyApp::Data::'
    );

    # Same thing, with a maximum of DEBUG output on STDERR

    $corinna->generate(
        mode         => 'eval',
        schema       => '/some/path/to/schema.xsd',
        class_prefix => 'MyApp::Data::',
        verbose      => 9
    );

And somewhere in an other place of the code ...
(Assuming a global XML element 'country' existed in you schema and hence been generated by Corinna).

    # This is the preferred way of getting at the class names of XML elements and types (since v1,0,3)
    my $class = MyApp::Data::Corinna::Meta->Model->xml_item_class('country');

    # Or, with a namespace URI, in case there are multiple namespaces in the model.
    $class = MyApp::Data::Corinna::Meta->Model->xml_item_class( 'country',
        'http://www.example.com/country' );

    my $country =
      $class->from_xml_file('/some/path/to/country.xml');    # retrieve from a file
    $country =
      $class->from_xml_url('http://some/url/to/country.xml');    # or from a URL
    $country = $class->from_xml_fh($fh);    # or from a file handle
    $country = $class->from_xml_dom($dom)
      ;    # or from DOM  (a XML::LibXML::Node or XML::LibXML::Document)
    $country = $class->from_xml($resource)
      ;    # or from any of the above. Handy if you don't know the resource.'

    # or from an XML string (Note the alternate way of using the class name directly)
    $country = MyApp::Data::country->from_xml_string(<<'EOF');

      <?xml version="1.0" encoding="UTF-8"?>
      <country  xmlns="http://www.example.com/country"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xsi:schemaLocation="http://www.example.com/country"
                code="FR">

        <name>France</name>
        <population date="2000-01-01" figure="60000000"/>
        <currency code="EUR" name="Euro"/>
        <city code="AVA">
            <name>Ambrières-les-Vallées</name>
        </city>
        <city code="BCX">
            <name>Beire-le-Châtel</name>
        </city>
        <city code="LYO">
            <name>Lyon</name>
        </city>
        <city code="NCE">
            <name>Nice</name>
        </city>
        <city code="PAR">
            <name>Paris</name>
        </city>
      </country>
    EOF

    # or if you don't know if you have a file, URL, FH, or string
    $country = MyApp::Data::country->from_xml('http://some/url/to/country.xml');

    # Now you can manipulate your country object.
    print $country->name;               # prints "France"
    print $country->currency->_code;    # prints "EUR"
    print $country->city->[0]->name;    # prints "Ambrières-les-Vallées"

    print $country->city
      ->name;    # prints the same thing, i.e. "Ambrières-les-Vallées"
                 # Note the ABSENCE of array indexing.
                 # You don't have to worry about multiplicity!

    # Let's make some changes
    $country->_code('fr')
      ; # Change the 'code' attribute. Notice the underscore prefix on the accessor.
    $country->code('fr')
      ; # Same thing, but risky in case of attribute name collision with a child element name. It's there for backward compatibility.
    $country->name('FRANCE');

    #Let's access the cities as a hash keyed on city code.
    my $city_h = $country->city->hash('_code')
      ;    # This will hash the node array on the 'code' attribute
    my $city_h =
      $country->city->hash( sub { shift->_code(); } )
      ;    # This will do the same thing with a CODE reference.

    print $city_h->{'NCE'}->name;    # prints "Nice".

    # Let's add a city
    my $class = $country->xml_field_class('city');
    my $city  = $class->new();
    $city->_code('MRS');
    $city->name('Marseille');

    push @{ $country->city }, $city;

    print $country->city->[5]->name;    # prints "Marseille"

    # Time to validate our XML
    $country->xml_validate();           # This one will DIE on failure

    if ( $country->is_xml_valid() ) {   # This one will not die.
        print "ok\n";
    }
    else {
        print "Validation error : $@\n";   # Note that $@ contains the error message
    }

    # Time to write the the object back to XML
    $country->to_xml_file('some/path/to/country.xml');         # To a file
    $country->to_xml_url('http://some/url/to/country.xml');    # To a URL
    $country->to_xml_fh($fh);                                  # To a FILE HANDLE
    $country->to_xml($resource)
      ;    # To any of the above. Handy if we don't know ahead of time.'

    my $dom = $country->to_xml_dom();    # To a DOM Node (XML::LibXML::Node)
    my $dom =
      $country->to_xml_dom_document();  # To a DOM Document  (XML::LibXML::Document)
    my $xml  = $country->to_xml_string();    # To a string
    my $frag = $country->to_xml_fragment()
      ;    # Same thing without the <?xml version="1.0?> part

By the way, for those who are interesed in the data structure, here is a
sample DUMP of what C<$country> might look like.  However, don't count on
anything but attribute and element names. Anything else may change. You have
been warned.

    print Dumper($country);    # actually with Sortkeys(1);

    # ---- Prints the following DUMP

    $VAR1 = bless(
        {
            '._nodeName_' => 'country',
            '_code' => bless( { 'value' => 'FR' }, 'Corinna::Builtin::string' ),
            'city'  => bless(
                [
                    bless(
                        {
                            '._nodeName_' => 'city',
                            '_code'       => bless(
                                { 'value' => 'AVA' },
                                'Corinna::Test::Type::Code'
                            ),
                            'name' => bless(
                                { 'value' => "Ambri\x{e8}res-les-Vall\x{e9}es" },
                                'Corinna::Builtin::string'
                            )
                        },
                        'Corinna::Test::Type::City'
                    ),
                    bless(
                        {
                            '._nodeName_' => 'city',
                            '_code'       => bless(
                                { 'value' => 'BCX' },
                                'Corinna::Test::Type::Code'
                            ),
                            'name' => bless(
                                { 'value' => "Beire-le-Ch\x{e2}tel" },
                                'Corinna::Builtin::string'
                            )
                        },
                        'Corinna::Test::Type::City'
                    ),
                    bless(
                        {
                            '._nodeName_' => 'city',
                            '_code'       => bless(
                                { 'value' => 'LYO' },
                                'Corinna::Test::Type::Code'
                            ),
                            'name' => bless(
                                { 'value' => 'Lyon' },
                                'Corinna::Builtin::string'
                            )
                        },
                        'Corinna::Test::Type::City'
                    ),
                    bless(
                        {
                            '._nodeName_' => 'city',
                            '_code'       => bless(
                                { 'value' => 'NCE' },
                                'Corinna::Test::Type::Code'
                            ),
                            'name' => bless(
                                { 'value' => 'Nice' },
                                'Corinna::Builtin::string'
                            )
                        },
                        'Corinna::Test::Type::City'
                    ),
                    bless(
                        {
                            '._nodeName_' => 'city',
                            '_code'       => bless(
                                { 'value' => 'PAR' },
                                'Corinna::Test::Type::Code'
                            ),
                            'name' => bless(
                                { 'value' => 'Paris' },
                                'Corinna::Builtin::string'
                            )
                        },
                        'Corinna::Test::Type::City'
                    )
                ],
                'Corinna::NodeArray'
            ),
            'currency' => bless(
                {
                    '._nodeName_' => 'currency',
                    '_code' =>
                      bless( { 'value' => 'EUR' }, 'Corinna::Builtin::string' ),
                    '_name' =>
                      bless( { 'value' => 'Euro' }, 'Corinna::Builtin::string' )
                },
                'Corinna::Test::Type::Country_currency'
            ),
            'name' => bless( { 'value' => 'France' }, 'Corinna::Builtin::string' ),
            'population' => bless(
                {
                    '._nodeName_' => 'population',
                    '_date'       => bless(
                        { 'value' => '2000-01-01' }, 'Corinna::Builtin::date'
                    ),
                    '_figure' => bless(
                        { 'value' => '60000000' },
                        'Corinna::Builtin::nonNegativeInteger'
                    )
                },
                'Corinna::Test::Type::Population'
            )
        },
        'Corinna::Test::country'
    );

=head1 DESCRIPTION

Java had CASTOR, and now Perl has C<Corinna>!

If you know what Castor does in the Java world, then B<Corinna> should be
familiar to you. If you have a B<W3C XSD schema>, you can generate Perl
classes with roundtrip XML bindings.

Whereas Castor is limited to offline code generation, B<Corinna> is able to
generate Perl classes either offline or at run-time starting from a W3C XSD
Schema. The generated classes correspond to the global elements, complex and
simple type declarations in the schema. The generated classes have full XML
binding, meaning objects belonging to them can be read from and written to
XML. Accessor methods for attributes and child elements will be generated
automatically.  Furthermore it is possible to validate the objects of
generated classes against the original schema although the schema is typically
no longer accessible.

B<Corinna> defines just one method, 'I<generate()>', but the classes it
generates define many methods which may be found in the documentation of
L<Corinna::ComplexType> and L<Corinna::SimpleType> from which all generated
classes descend.

In 'I<offline>'  mode, it is possible to generate a single module with all the
generated clasess or multiple modules one for each class. The typical use of
the offline mode is during a 'make' process, where you have a set of XSD
schemas and you generate your modules to be later installed by the 'make
install'. This is very similar to Java Castor's behaviour.  This way your XSD
schemas don't have to be accessible during run-time and you don't have a
performance penalty.

Perl philosophy dictates however, that There Is More Than One Way To Do It. In
'I<eval>' (run-time) mode, the XSD schema is processed at run-time giving much
more flexibility to the user. This added flexibility has a price on the other
hand, namely a performance penalty and the fact that the XSD schema needs to
be accessible at run-time. Note that the performance penalty applies only to
the code genereration (pastorize) phase; the generated classes perform the
same as if they were generated offline.

There is a command line utility called L<pastorize> that can help generating
classes offline. See the documentation of L<pastorize> for more details on
that.

=head1 SCOPE AND WARNING

B<Corinna> is quite good for the so called 'data xml', that is, XML without
mixed markup.  It is NOT suitable for parsing and manipulating a markup
language such as XHTML for example. 'Mixed markup' means that an element can
contain both textual data and child elements miexed together. B<Corinna> does
not support that.

B<Corinna> is NOT a recommended way of treating HUGE XML documents. The exact
definition of HUGE varies.  It usually means paging into virtual memory. If
you find yourself doing that, you should know that you might be better of with
L<XML::Twig> which lets you selectively parse chunks of a tree. Or better yet,
just do B<SAX> processing. Note that things are not that bad with B<Corinna>
=> The memory used by B<Corinna> is not that much more than that of
L<XML::Simple> or a DOM for the same document.

=head1 METHODS

=head2 new()       (CONSTRUCTOR)

The new() constructor method instantiates a new B<Corinna> object.

    my $corinna = Corinna->new();

This is currently unnecessary as the only method ('I<generate>') is a class
method.  However, it is higly recommended to use it and call 'generate' on an
object (rather than the class) as in the future, 'generate' may no longer be a
class method.

=head2 version  (CLASS METHOD)

Returns the current VERSION of Corinna;

=head2 generate(%options)

Currently a B<CLASS METHOD>, but may change to be an B<OBJECT METHOD> in the
future. It works when called on an OBJECT too at this time.

This method is the heart of the module. It will accept a schema file name or
URL as input (among some other parameters) and proceed to code generation.

This method will parse the schema(s) given by the L</schema> parameter and
then proceed to code generation.  The generated code will be written to disk
(mode=>L</offline>) or evaluated at run-time (mode=>L</eval>) depending on the
value of the L</mode> parameter.

In L</offline> mode, the generated classes will either all be put in one
L</single> big code block, or in L</multiple> module files (one for each
class) depending on the L</style> parameter. Again in L</offline> mode, the
generated modules will be written to disk under the directory prefix given by
the L</destination> parameter.

In any case, the names of the generated classes will be prefixed by the string
given by the L</class_prefix> parameter.  It is possible to indicate common
ancestors for generated classes via the L</complex_isa> and L</simple_isa>
parameters.

This method expects the following parameters:

=over

=item schema

This is the file name or the URL to the B<W3C XSD schema> file to be
processed. Experimentally, it can also be a string containing schema XSD.

Be careful about the paths that are mentioned for any included schemas though.
If these are relative, they will be taken realtive to the current schema being
processed. In the case of a schema string, the resolution of relative paths
for the included schemas is undefined.

Currently, it is also possible to pass an array reference to this parameter,
in which case the schemas will be processed in order and merged to the same
model for code generation. Just make sure you don't have name collisions in
the schemas though.

=item mode

This parameter affects what actuallly will be done by the method. Either
offline code generation, or run-time code evaluation, or just returning the
generated code.

=over

=item offline

B<Default>.

In this mode, the code generation is done 'offline', that is, similar to
Java's Castor way of doing things, the generated code will be written to disk
on module files under the path given by the L</destination> parameter.

In 'I<offline>'  mode, it is possible to generate a single module with all the
generated clasess or multiple modules one for each class, depending on the
value of the L</style> parameter.

The typical use of the I<offline> mode is during a 'B<make>' process, where
you have a set of XSD schemas and you generate your modules to be later
installed by 'B<make install>'. This is very similar to Java Castor's
behaviour.  This way your XSD schemas don't have to be accessible during
run-time and you don't have a performance penalty.

    # Generate MULTIPLE modules, one module for each class, and put them under destination.
    my $corinna = Corinna->new();
    $corinna->generate(
        mode         => 'offline',
        style        => 'multiple',
        schema       => '/some/path/to/schema.xsd',
        class_prefix => 'MyApp::Data::',
        destination  => '/tmp/lib/perl/',
    );

=item eval

In 'I<eval>' (run-time) mode, the XSD schema is processed at run-time giving
much more flexibility to the user. In this mode, no code will be written to
disk. Instead, the generated code (which is necessarily a L</single> block)
will be evaluated before returning to the caller.

The added flexibility has a price on the other hand, namely a performance
penalty and the fact that the XSD schema needs to be accessible at run-time.
Note that the performance penalty applies only to the code genereration
(pastorize) phase; the generated classes perform the same as if they were
generated offline.

Note that 'I<eval>' mode forces the L</style> parameter to have a value of
'I<single>';

    # Generate classes in MEMORY, and EVALUATE the generated code on the fly.
    my $corinna = Corinna->new();
    $corinna->generate(
        mode         => 'eval',
        schema       => '/some/path/to/schema.xsd',
        class_prefix => 'MyApp::Data::'
    );

=item return

In 'I<return>'  mode, the XSD schema is processed but no code is written to
disk or evaluated. In this mode, the method just returns the generated block
of code as a string, so that you may use it to your liking. You would
typically be evaluating it though.

Note that 'I<return>' mode forces the L</style> parameter to have a value of
'I<single>';

=back

=item style

This parameter determines if B<Corinna> will generate a single module where
all classes reside (L</single>), or multiple modules one for each class
(L</multiple>).

Some modes (such as L</eval> and L</return>)force the style argument to be
'I<single>'.

Possible values are :

=over

=item single

One block of code containg all the generated classes will be produced.

=item multiple

A separate piece of code for each class will be produced. In addition, a
module that 'uses' each of the individual generated modules will be created
whose name is given by the 'module' argument (or otherwise it's given by
'class_prefix').

=back

=item class_prefix

If present, the names of the generated classes will be prefixed by this value.
You may end the value with '::' or not, it's up to you. It will be
autocompleted.  In other words both 'MyApp::Data' and 'MyApp::Data::' are
valid.

=item destination

This is the directory prefix where the produced modules will be written in
I<offline> mode. In other modes (I<eval> and I<return>), it is ignored.

Note that the trailing slash ('/') is optional. The default value for this
parameter is '/tmp/lib/perl/'.

=item module

This parameter has sense only when generating one big chunk of code (L</style>
=> L</single>) in offline L</mode>.

It denotes the name of the module (without the .pm extension) that will be
written to disk in this case.

=item complex_isa

Via this parameter, it is possible to indicate a common ancestor (or
ancestors) of all complex types that are generated by B<Corinna>.  The
generated complex types will still have B<Corinna::ComplexType> as their last
ancestor in their @ISA, but they will also have the class whose name is given
by this parameter as their first ancestor. Handy if you would like to add
common behaviour to all your generated classes.

This parameter can have a string value (the usual case) or an array reference
to strings. In the array case, each item is added to the @ISA array (in that
order) of the generated classes.

=item simple_isa

Via this parameter, it is possible to indicate a common ancestor (or
ancestors) of all simple types that are generated by B<Corinna>.  The
generated simple types will still have B<Corinna::SimpleType> as their last
ancestor in their @ISA, but they will also have the class whose name is given
by this parameter as their first ancestor. Handy if you would like to add
common behaviour to all your generated classes.

This parameter can have a string value (the usual case) or an array reference
to strings. In the array case, each item is added to the @ISA array (in that
order) of the generated classes.

=item verbose

This parameter indicates the desired level of verbosity of the output. A value
of zero (0), which is the default, indicates 'silent' operation where only a
fatal error will result in a 'die' which will in turn write on STDERR. A
higher value of 'verbose' indicates more and more chatter on STDERR.


=back

=head1 ::Corinna::Meta CLASS

Suppose you use L<Corinna> for code generation with a B<class prefix> of
B<MyApp::Data>. Then, L<Corinna> will also generate a class that enables you
to access meta information about the generated code under
'MyApp::Data::Corinna::Meta'.

Currently, the only information you can access is the 'B<Model>' that was used
to generate code.  'B<Model>' is class data that references to an entire
schema model object (of type L<XML::Schema::Model>).  With the help of the
generated 'meta' class, you can access the Model which will in turn enable you
to call methods such as 'B<xml_item_class()>' which helps you determine the
generated Perl class of a given global element or type in the schema.

Example:

    $corinna->generate(
        mode         => 'eval',
        schema       => '/some/path/to/schema.xsd',
        class_prefix => 'MyApp::Data::'
    );

    # Access the schema model
    my $model = MyApp::Data::Corinna::Meta->Model
      ;    # Note that this is $class_prefix . 'Corinna::Meta'

    # Get the class name for element 'country'
    my $class = $model->xml_item_class('country');

    # OR
    $class = $model->xml_item_class( 'country', 'http://www.example.com/country' )
      ;    # with a namespace URI

    # Now read the object from a file
    my $country =
      $class->from_xml_file('/some/path/to/country.xml');    # retrieve from a file

=head1 SCHEMA SUPPORT

The version 1.0 of W3C XSD schema (2001) is supported almost in full, albeit
with some exceptions (see L</"BUGS & CAVEATS">).

=head2 SUPPORTED

Such things as complex and simple types, global elements, groups, attributes,
and attribute groups are supported. Type declarations can either be global or
done locally.

Complex type derivation by extension and simple type derivation by restriction
is supported.

All the basic W3C builtin types are supported.

Unions and lists are supported.

Most of the restriction facets for simple types are supported (length,
minLength, maxLength, pattern, enumeration, minInclusive, maxInclusive,
minExclusive, maxExclusive, totalDigits, fractionDigits>).

Schema inclusion (include) and redefinition (redefine) are supported,
allthough for 'redefine' not much testing was done.

Schema 'import' is now supported (since version 0.6.3).

ComplexTypes with simpleContent (simple-type elements eventually with
attributes) are supported (since v0.6.0).

=head2 PARTIALLY SUPPORTED

Namespaces are quite well supported now (since version 0.6.3). Multiple
namespaces are OK.

However, local name collisions with multiple namespaces will yield unpredicted
results.  That is, if, for example, you have two child elements with the same
local name but with different namespaces, the result is unpredictable.

=head2 NOT SUPPORTED

Elements with 'mixed' content are NOT supported.

Substitution groups are NOT supported.

'any' and 'anyAttribute' are NOT supported.

=head1 HOW IT WORKS

The source code of the L</generate()> method looks like this:

    sub generate {
        my $self = shift;

        my $parser = Corinna::Schema::Parser->new();
        my $model  = $parser->parse(@_);

        $model->resolve(@_);

        my $generator = Corinna::Generator->new();

        my $result = $generator->generate( @_, model => $model );

        return $result;
    }

At code generation time, B<Corinna> will first parse the schema(s) into a
schema model (Corinna::Schema::Model). The model contains all the schema
information in perl data structures. All the global elements, types,
attributes, groups, and attribute groups are put into this model.

Then, the model is 'resolved', i.e. the references ('ref') are resolved, class
names are determined and so on. Then, comes the code generation stage where
your classes are generated according to the given options. In offline mode,
this phase will write out the generated code onto modules on disk. Otherwise
it can also 'eval' the generated code for you.

The generated classes will contain class data named 'B<XmlSchemaType>' (thanks
to L<Class::Data::Inheritable>), which will contain all the schema model
information that corresponds to this type. For a complex type, it will contain
information about child elements and attributes. For a simple type it will
contain the restriction facets that may exist and so on.

For complex types, the generated classes will also have accessors for the
attributes and child elements of that type (thanks to L<Class::Accessor>).
However, you can also use direct hash access as the objects are just blessed
hash references. The fields in the has correspond to attributes and child
elements of the complex type. You can also store additional non-XML data in
these objects. Such fields are silently ignored during validation and XML
serialization. This way, your objects can have state information that is not
stored in XML. Just make sure the names of these fields do not coincide with
XML attributes and child elements though.

The inheritance of classes are also managed by B<Corinna> for you. Complex
types that are derived by extension will automatically be a descendant of the
base class. Same applies to the simple types derived by restriction.  Global
elements will always be a descendant of some type, which may sometimes be
implicitely defined. Global elements will have an added ancestor
L<Corinna::Element> and will also contain an extra class data accessor
"B<XmlSchemaElement>" which will contain schema information about the model.
This class data is currently used mainly to get at the name of the element
when an object of this class is stored in XML (as ComplexTypes don't have an
element name).

Then you I<use> the generated modules. If the generation was offline, you
actually need a 'use' statement. If it was an 'eval', you can start using your
generated classes immediately. At this time, you can call many methods on the
generated classes that enable you to create, retrieve and save an object
from/to XML. There are also methods that enable you to validate these objects
against schema information. Furthermore, you can call the accessors that were
automagically created for you on class generation for getting at the fields of
complex objects.  Since all the schema information is saved as class data, the
schema is no longer needed at run-time.

=head1 NAMING CONVENTIONS FOR GENERATED CLASSES

The generated classes will all be prefixed by the string given by the
L</class_prefix> parameter. The rest of this section assumes that
L</class_prefix> is "B<MyApp::Data>".

Classes that correspond to global elements will keep the name of the element.
For example, if there is an element called 'B<country>' in the schema, the
corresponding clas will have the name 'B<MyApp::Data::country>'. Note that no
change in case occurs.

Classes that correspond to global complex and simple types will be put under
the 'B<Type>' subtree. For example, if there is a complex type called
'B<City>' in the XSD schema, the corresponding class will be called
'B<MyApp::Data::Type::City>'. Note that no change in case occurs.

Implicit types (that is, types that are defined I<inline> in the schema) will
have auto-generated names within the 'Type' subtree. For example, if the
'B<population>' element within 'B<City>' is defined by an implicit type,  its
corresponding class will be 'B<MyApp::Data::Type::City_population>'.

Sometimes implicit types need more to disambiguate their names. In that case,
an auto-incremented sequence is used to generate the class names.

In any case, do not count on the names of the classes for implicit types. The
naming convention for those may change. In other words, do not reference these
classes by their names in your program. You have been warned.


=head1 SUGGESTED NAMING CONVENTIONS FOR XML TYPES, ELEMENTS AND ATTRIBUTES IN W3C SCHEMAS

Sometimes you will be forced to use a W3C schema defined by someone else. In
that case, you will not have a choice for the names of types, elements, and
attributes defined in the schema.

But most often, you will be the one who defines the W3C schema itself. So you
will have full power over the names within.

As mentioned earlier, B<Corinna> will generate accesor methods for the child
elements and attributes of each class. The attribute names will be prefixed by
an underscore in the hash. Attribute accessors will have an underscore prefix,
too. However, accessor aliases will be generated without the underscore prefix
for those attributes whose names don't clash with child element names.  '
Since there exist some utility methods defined under L<Corinna::ComplexType>
and L<Corinna::SimpleType> that are the ancestors of all the generated classes
from your schema there is a risk of name collisions.  Below is a list of
suggestions that will ensure that there are no name collisions within your
schema and with the defined methods.

=over

=item Element and attribute names should start with lower case

Element ant attribute names (incuding global ones) should start with lower
case and be uppercased at word boundries. Example : "firstName", "lastName".
Do not use underscore to separate words as this may open up a possibility for
name collisions of accessors with the names of utility methods defined under
L<Corinna::ComplexType> and L<Corinna::SimpleType>.

=item Element and attribute names should not coincide with builtin method names of L<Corinna::ComplexType>

Element ant attribute names (incuding global ones) should not coincide with
builtin method names defined under L<Corinna::ComplexType> as this will cause
a name collision with the generated accessor method. Extra care should be
taken for the methods called 'B<get>', 'B<set>', and 'B<grab>' as these are
one-word builtin method names. Same goes for 'B<isa>' and 'B<can>' that come
from Perl's B<UNIVERSAL> package. Multiple word method names should not
normally cause trouble if you abide by the principle of not using underscore
for separating words in element and attribute names. See
L<Corinna::ComplexType> for the names of other builtin methods for the
generated classes.

=item Global complex and simple types should start with upper case

The names of global types (complex and simple) should start with an upper case
and continue with lower case. Word boundries should be uppercased. This
resembles the package name convention in Perl.  Example : 'B<City>',
'B<Country>', 'B<CountryCode>'.

=item Avoid child Elements and attributes with the same name, if you can

Try not to use the same name for an attribute and a child element of the same
complex type or element within your schema. For instance, if you have an
attribute called 'title' within a Complex type called 'Person', do not in any
circumstance create a child element with the same name 'title'. Although this
is technically possible under W3C schema, it should really be discoureged.
Since v0.54, Corinna overcomes this by introducing an underscore ('_') prefix
to attribute names in the hash. Attribute accessors will have an underscore
prefix, too. However, accessor aliases will be generated without the
underscore prefix for those attributes whose names don't clash with child
element names. So, if there is no clash, old code should continue to work as
long as it used accessors to get at the value.

=back

You are free to name global groups and attribute groups to your liking.

=head1 BUGS & CAVEATS

There no known bugs at this time, but this doesn't mean there are aren't any.
Note that, although some testing was done prior to releasing the module, this
should still be considered alpha code.  So use it at your own risk.

There are known limitations however:

=over

=item * Namespaces

Namespaces are quite well supported now (since version 0.6.3). Multiple
namespaces are OK.

However, local name collisions with multiple namespaces will yield unpredicted
results.  That is, if, for example, you have two child elements with the same
local name but with different namespaces, the result is unpredictable.

=item * 'mixed' elements

Elements with 'mixed' content (text and child elements) are not supported at
this time.

=item * substitution groups

Substitution groups are not supported at this time.

=item * Encoding

Only the B<UTF-8> encoding is -officially- supported. You should make sure
that your data is in UTF-8 format. It may be possible to read and write XML
from other encodings.  But this feature is experimental and not tested at this
time.

=item * Default values for attributes

Default values for attributes are not supported at this time. If you can think
of a simple way to support this, please let me know.

=back

Note that there may be other bugs or limitations that the author is not aware of.

=head1 AUTHOR

Curtis "Ovid" Poe. Ayhan did great work on this, but patches have been in the
queue for years and this nice idea stalled, so I'm forking and picking it up
again.

=head1 AUTHOR EMERITUS

Ayhan Ulusoy <dev(at)ulusoy(dot)name>


=head1 COPYRIGHT

  Copyright (C) 2006-2008 Ayhan Ulusoy. All Rights Reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 DISCLAIMER

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY FOR THE
SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW.  EXCEPT WHEN OTHERWISE
STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES PROVIDE THE
SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE.  THE ENTIRE RISK AS TO THE QUALITY AND
PERFORMANCE OF THE SOFTWARE IS WITH YOU.  SHOULD THE SOFTWARE PROVE DEFECTIVE,
YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING WILL ANY
COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR REDISTRIBUTE THE
SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE LIABLE TO YOU FOR DAMAGES,
INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING
OUT OF THE USE OR INABILITY TO USE THE SOFTWARE (INCLUDING BUT NOT LIMITED TO
LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR
THIRD PARTIES OR A FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER
SOFTWARE), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGES.

=head1 SEE ALSO

See also L<pastorize>, L<Corinna::ComplexType>, L<Corinna::SimpleType>

If you are curious about the implementation, see also
L<Corinna::Schema::Parser>, L<Corinna::Schema::Model>, L<Corinna::Generator>.

=cut

1;
