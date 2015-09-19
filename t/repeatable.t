use strict;
use warnings;
use Test::More;
use Data::Dumper;

use_ok('HTML::MuForm::Field::Repeatable');

{
    package Test::Form;
    use Moo;
    use HTML::MuForm::Meta;
    extends 'HTML::MuForm';

    has_field 'my_name';
    has_field 'my_records' => ( type => 'Repeatable', num_when_empty => 2,);
    has_field 'my_records.one';
    has_field 'my_records.two';
    has_field 'tags' => ( type => 'Repeatable' );
    has_field 'tags.contains' => ( type => 'Text' );
}
my $form = Test::Form->new;
ok( $form, 'form built' );

is( $form->num_fields, 3, 'right number of form fields' );
my $rep_field = $form->field('my_records');
ok( $rep_field, 'we got the repeatable field' );

is( $rep_field->num_fields, 2, 'right number of repeatable subfields' );

my $rep_one = $rep_field->field('0');
ok( $rep_one, 'got first repeatable field' );

ok( $form->field('my_records.0.'), 'got field by another method');

is( $rep_one->num_fields, 2, 'first repeatable has 2 subfields' );

my $rep_two = $form->field('my_records.1');
ok( $rep_two, 'got second repeatable field' );
is( $rep_one->num_fields, 2, 'second repeatable has 2 subfields' );

my $expected_fif = {
    'my_name' => '',
    'my_records.0.one' => '',
    'my_records.0.two' => '',
    'my_records.1.one' => '',
    'my_records.1.two' => '',
    'tags.0' => '',
};
my $fif = $form->fif;

is_deeply( $fif, $expected_fif, 'got right fif' );


my $params = {
    'my_name' => 'Jane',
    'my_records.0.one' => 'first, one',
    'my_records.0.two' => 'first, two',
    'my_records.1.one' => 'second, one',
    'my_records.1.two' => 'second, two',
    'tags.0' => 'my_category',
    'tags.1' => 'trouble',
};

$form->process( params => $params );
ok( $form->validated, 'form validated ok' );

#0  HASH(0x7fc126195b88)
#  'my_name' => 'Jane'
#  'my_records' => HASH(0x7fc126f89a08)
#     0 => HASH(0x7fc12780c9a0)
#        'one' => 'first, one'
#        'two' => 'first, two'
#     1 => HASH(0x7fc127815640)
#        'one' => 'second, one'
#        'two' => 'second, two'
#  'tags' => HASH(0x7fc127815c58)
#     0 => 'my_category'
#     1 => 'trouble'

my $value = $form->value;
my $expected_value = {
    'my_name' => 'Jane',
    'my_records' => [
        { 'one' => 'first, one', 'two' => 'first, two' },
        { 'one' => 'second, one', 'two' => 'second, two' }
    ],
    'tags' => [ 'my_category', 'trouble' ],
};

is_deeply ( $value, $expected_value, 'got correct value from processed form');
diag(Dumper($value));

done_testing;
