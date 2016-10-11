package Data::MuForm::Field::Checkbox;
# ABSTRACT: Checkbox field
use Moo;
extends 'Data::MuForm::Field';

=head1 NAME

Data::MuForm::Field::Checkbox

=head1 DESCRIPTION

Render args:
  option_label
  option_wrapper

=cut

has 'size' => ( is => 'rw', default => 0 );

has 'checkbox_value' => ( is => 'rw', default => 1 );
has '+input_without_param' => ( default => 0 );
#has 'option_label'         => ( is => 'rw' );
#has 'option_wrapper'       => ( is => 'rw' );

sub build_input_type { 'checkbox' }

sub base_render_args {
    my $self = shift;
    my $args = $self->next::method(@_);
    $args->{checkbox_value} = $self->checkbox_value;
    return $args;
}


sub validate {
    my $self = shift;

    $self->add_error($self->get_message('required'), field_label => $self->loc_label) if( $self->required && !$self->value );
}

1;
