package Data::MuForm::Field::Time;
# ABSTRACT: Time field
use Moo;
extends 'Data::MuForm::Field::Text';

=head1 NAME

Data::MuForm::Field::Time

=head1 DESCRIPTION

A 'Time' field;

=cut

has 'use_seconds' => ( is => 'rw', default => 0 );
has 'twelve_hour_clock' => ( is => 'rw', default => 0 );

our $class_messages = {
    'time_format' => 'Invalid format for time',
};

sub get_class_messages  {
    my $self = shift;
    return {
        %{ $self->next::method },
        %$class_messages,
    }
}

sub validate {
  my $self = shift;

  my $value = $self->value;
  my $hour;
  my $minutes;
  my $seconds;
  if ( $value =~ /:/ ) {
    ($hour, $minutes, $seconds) = split(':', $value);
  }
  else {
    $hour = $value;
    $minutes = 0;
    $seconds = 0;
  }
  $seconds //= 0;
  my $max_hours = $self->twelve_hour_clock ? 12 : 24;
  unless ( defined $hour && $hour >= 0 && $hour <= $max_hours ) {
    $self->add_error($self->get_message('time_format'));
  }
  unless ( defined $minutes && $minutes >= 0 && $minutes < 60 ) {
    $self->add_error($self->get_message('time_format'));
  }
  unless ( $seconds >= 0 && $seconds < 60 ) {
    $self->add_error($self->get_message('time_format'));
  }

  if ( $self->use_seconds ) {
    $self->value(sprintf('%02d:%02d:%02d', $hour, $minutes, $seconds));
  }
  else {
    $self->value(sprintf('%02d:%02d', $hour, $minutes));
  }

}

1;

