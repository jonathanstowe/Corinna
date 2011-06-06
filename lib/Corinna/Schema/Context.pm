package Corinna::Schema::Context;
use utf8;
use strict;
use warnings;

use Corinna::Stack;
use Corinna::Schema::Object;

use Scalar::Util qw(blessed reftype);

use parent 'Class::Accessor';

our $VERSION = '2.0';

Corinna::Schema::Context->mk_accessors(
    qw( counter schema schema_url operation node_stack targetNamespace));

#------------------------------------------------------------
sub new {
    my $class = shift;
    my $self  = {@_};

    unless ( $self->{node_stack} ) {
        $self->{node_stack} = Corinna::Stack->new();
    }

    unless ( defined( $self->{counter} ) ) {
        $self->{counter} = 0;
    }

    return bless $self, $class;
}

#------------------------------------------------------------
sub top_node {
    my $self = shift;
    return $self->node_stack()->peek();
}

#------------------------------------------------------------
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
