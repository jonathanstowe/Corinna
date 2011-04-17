
#PASTOR: Code generated by Corinna/1.0.3 at 'Sun Apr 17 11:55:13 2011'

use utf8;
use strict;
use warnings;
no warnings qw(uninitialized);

use Corinna;



#================================================================

package Corinna::Test::city;

use Corinna::Test::Type::City;

our @ISA=qw(Corinna::Test::Type::City Corinna::Element);

Corinna::Test::city->XmlSchemaElement( bless( {
         'baseClasses' => [
                            'Corinna::Test::Type::City',
                            'Corinna::Element'
                          ],
         'class' => 'Corinna::Test::city',
         'isRedefinable' => 1,
         'metaClass' => 'Corinna::Test::Pastor::Meta',
         'name' => 'city',
         'scope' => 'global',
         'targetNamespace' => 'http://www.example.com/country',
         'type' => 'City|http://www.example.com/country'
       }, 'Corinna::Schema::Element' ) );

1;


__END__



=head1 NAME

B<Corinna::Test::city>  -  A class generated by L<Corinna> . 


=head1 ISA

This class descends from L<Corinna::Test::Type::City>, L<Corinna::Element>.


=head1 CODE GENERATION

This module was automatically generated by L<Corinna> version 1.0.3 at 'Sun Apr 17 11:55:13 2011'


=head1 SEE ALSO

L<Corinna::Test::Type::City>, L<Corinna::Element>, L<Corinna>, L<Corinna::Type>, L<Corinna::ComplexType>, L<Corinna::SimpleType>


=cut
