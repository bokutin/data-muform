package HTML::MooForm::Field::Text;
use Moo;
extends 'HTML::MooForm::Field';

has 'size' => ( is => 'rw', default => 0 );

sub element_type { 'submit' }

sub field_validate {
    my $self = shift;
}

1;
