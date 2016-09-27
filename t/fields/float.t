use strict;
use warnings;
use Test::More;

# float

my $class = 'Data::MuForm::Field::Float';
use_ok( $class );
my $field = $class->new( name => 'float_test' );
ok( defined $field, 'field built' );

$field->input( '2.0' );
$field->validate_field;
ok( !$field->has_errors, 'accepted 2.0 value' );
$field->input( '2.000' );
$field->validate_field;
ok( $field->has_errors, 'error for 3 decimal places' );
is( $field->errors->[0], 'May have a maximum of 2 digits after the decimal point, but has 3', 'error message correct' );

$field->clear;
$field->size(4);
$field->input( '12345.00' );
$field->validate_field;
ok( $field->has_errors, 'error for size' );
is( $field->errors->[0], 'Total size of number must be less than or equal to 4, but is 7', 'error message correct' );

$field->clear;
$field->input( '12.30' );
$field->validate_field;
ok( $field->validated, 'field validated' );

done_testing;
