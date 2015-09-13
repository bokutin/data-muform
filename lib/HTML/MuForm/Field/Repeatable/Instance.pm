package HTML::MuForm::Field::Repeatable::Instance;
# ABSTRACT: used internally by repeatable fields

use Moo;
use HTML::MuForm::Meta;
extends 'HTML::MuForm::Field::Compound';

=head1 SYNOPSIS

This is a simple container class to hold an instance of a Repeatable field.
It will have a name like '0', '1'... Users should not need to use this class.

=cut

sub BUILD {
    my $self = shift;
}

has '+no_value_if_empty' => ( default => 1 );

__PACKAGE__->meta->make_immutable;
use namespace::autoclean;
1;
