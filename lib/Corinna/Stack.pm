package Corinna::Stack;

use strict;
use warnings;

our $VERSION = '0.01';

use Moose;

has _items =>  (
         is => 'rw',
         isa   => 'ArrayRef',
         default => sub { [] },
         traits   => ['Array'],
         handles => {
             _first => 'first',
             clear   => 'clear',
             get     => 'get',
             count   => 'count',
             empty   => 'is_empty',
             pop     => 'shift',
             push    => 'unshift',
         },

);

sub peek
{
    my ( $self ) = @_;

    return $self->_first(sub { 1; });
}

1;

__END__

=head1 NAME

Corinna::Stack - A Stack!

=head1 WARNING

This module is used internally by L<Corinna>. You do not normally know much
about this module to actually use L<Corinna>.  It is documented here for
completeness and for L<Corinna> developers. Do not count on the interface of
this module. It may change in any of the subsequent releases. You have been
warned.

=head1 SYNOPSIS

  use Corinna::Stack;
  my $stack = Corinna::Stack->new();

=head1 DESCRIPTION

Quite simple, really.  Just a stack implemented via an array.

This module is a blunt copy of the L<Data::Stack> module. I had originally
intended to use that module but it turns out that it -superflously- requires
perl 5.8.6 to build and I only had perl 5.8.4 on my system with no means to
upgrade. So that's why I had to copy all the code in L<Data::Stack> into this
otherwise needless module.

=head1 METHODS

=over 4

=item new( [ @ITEMS ] )

Creates a new Corinna::Stack.  If passed an array, those items are added to
the stack.

=item peek()

Returns the item at the top of the stack but does not remove it.

=item get($INDEX)

Returns the item at position $INDEX in the stack but does not remove it.  0
based.

=item count()

Returns the number of items in the stack.

=item empty()

Returns a true value if the stack is empty.  Returns a false value if not.

=item clear()

Completely clear the stack.

=item pop()

Removes the item at the top of the stack and returns it.

=item push($item)

Adds the item to the top of the stack.

=back

=head2 EXPORT

None by default.

=head1 SEE ALSO

There are various Stack packages out there but none of them seemed simple
enough. Here we are!

=head1 AUTHOR

Ayhan Ulusoy <dev(at)ulusoy(dot)name>

The author of the original module L<Data::Stack> is: Cory Watson,
E<lt>cpan@onemogin.comE<gt>

=head1 COPYRIGHT AND LICENSE

  Copyright (C) 2006-2007 by Ayhan Ulusoy. (A shame, as the code is copied from Data::Stack by Cory Watson)

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
