
#PASTOR: Code generated by Corinna/1.0.3 at 'Sun Apr 17 11:55:13 2011'

use utf8;
use strict;
use warnings;
no warnings qw(uninitialized);

use Corinna;



#================================================================

package Corinna::Test::Type::Code_item_0003;


our @ISA=qw(Corinna::Builtin::date);

Corinna::Test::Type::Code_item_0003->XmlSchemaType( bless( {
         'base' => 'date|http://www.w3.org/2001/XMLSchema',
         'baseClasses' => [
                            'Corinna::Builtin::date'
                          ],
         'class' => 'Corinna::Test::Type::Code_item_0003',
         'contentType' => 'simple',
         'derivedBy' => 'restriction',
         'isRedefinable' => 1,
         'metaClass' => 'Corinna::Test::Pastor::Meta',
         'name' => 'Code_item_0003',
         'nameIsAutoGenerated' => 1,
         'scope' => 'local',
         'targetNamespace' => 'http://www.example.com/country'
       }, 'Corinna::Schema::SimpleType' ) );

1;


__END__



=head1 NAME

B<Corinna::Test::Type::Code_item_0003>  -  A class generated by L<Corinna> . 


=head1 ISA

This class descends from L<Corinna::Builtin::date>.


=head1 CODE GENERATION

This module was automatically generated by L<Corinna> version 1.0.3 at 'Sun Apr 17 11:55:13 2011'


=head1 SEE ALSO

L<Corinna::Builtin::date>, L<Corinna>, L<Corinna::Type>, L<Corinna::ComplexType>, L<Corinna::SimpleType>


=cut
