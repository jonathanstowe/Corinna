package Corinna::Schema::Context;
use utf8;
use strict;
use warnings;

use Moose;

use Corinna::Stack;
use Corinna::Schema::Object;

use Scalar::Util qw(blessed reftype);


our $VERSION = '2.0';


has counter => (
               is => 'rw',
               isa   => 'Int',
               lazy  => 1,
               default => 0,
             );

has schema => (
               is => 'rw',
               isa   => 'Str',
             );

has schema_url => (
               is => 'rw',
               isa   => 'URI',
             );

has operation => (
               is => 'rw',
               isa   => 'Str',
             );

has node_stack => (
               is => 'rw',
               isa   => 'Corinna::Stack',
               lazy  => 1,
               builder  => '_get_node_stack',
               handles =>  {
                  top_node => 'peek',
               }
             );

sub _get_node_stack
{
    my ( $self ) = @_;

   require Corinna::Stack;
    return Corinna::Stack->new();

}

has targetNamespace => (
               is => 'rw',
               isa   => 'Str',
             );


sub find_node {
    my $self  = shift;
    my $args  = {@_};
    my $class = $args->{class};

    my $ret;
    my $node_stack = $self->node_stack();
    STACK:
    for ( my $i = 0 ; $i < $node_stack->count() ; $i++ ) {
        my $node = $node_stack->get($i);

        #       print "\n", ref($node);
        if ( ref($class) && reftype($class) eq 'ARRAY' ) {
            foreach my $c (@$class) {
                if (  $node->isa($c) ) {
                    $ret = $node;
                    last STACK;
                 }
            }
        }
        elsif (  $node->isa($class) ) {
            $ret = $node;
        }
    }
    return $ret;
}

#------------------------------------------------------------
sub name_path {
    my $self      = shift;
    my $args      = {@_};
    my $separator = $args->{separator} || '/';
    my @names     = ();

    my $node_stack = $self->node_stack();
    for ( my $i = 0 ; $i < $node_stack->count() ; $i++ ) {
        my $node = $node_stack->get($i);
        my $name = undef;
        if ( blessed( $node ))
        {

        if ( $node->can( "name_is_auto_generated" )
            && $node->name_is_auto_generated() )
        {

            # ignore auto-generated names
            $name = undef;
        }
        elsif ( $node->can( "name" ) ) {
            $name = $node->name();
        }
        elsif ( ( reftype($node) eq 'HASH' ) && $node->{name} ) {
            $name = $node->{name};
        }
     }

        if ($name) {
            unshift @names, $name;
        }
    }
    return join $separator, @names;
}

1;
