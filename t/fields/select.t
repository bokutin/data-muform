use strict;
use warnings;
use Test::More;
use Data::MuForm::Field::Text;

# select

my $class = 'Data::MuForm::Field::Select';
use_ok( $class );
my $field = $class->new( name    => 'test_field',);

ok( defined $field,  'new() called' );
ok( $field->options, 'Test for init_options failure in 0.09' );
my $options = [
    { value => 1, label => 'one' },
    { value => 2, label => 'two' },
    { value => 3, label => 'three' },
];
$field->options($options);
ok( $field->options, 'Test for set options failure' );
$field->input( 1 );
$field->validate_field;
ok( !$field->has_errors, 'Test for errors 1' );
is( $field->value, 1, 'Test true == 1' );
$field->input( [1] );
$field->validate_field;
ok( $field->has_errors, 'Test for errors array' );
$field->input( [1,4] );
$field->validate_field;
ok( $field->has_errors, 'Test for errors 4' );
is( $field->errors->[0], 'This field does not take multiple values', 'Error message' );
$field = $class->new( name => 'test_prompt', 'empty_select' => "Choose a Number",
    options => $options, required => 1 );
is( $field->num_options, 3, 'right number of options');

{
   package Test::Form;
   use Moo;
   use Data::MuForm::Meta;
   extends 'Data::MuForm';

   has '+name' => ( default => 'options_form' );
   has_field 'test_field' => (
               type => 'Text',
               label => 'TEST',
               id    => 'f99',
            );
   has_field 'fruit' => ( type => 'Select' );
   has_field 'vegetables' => ( type => 'Multiple' );
   has_field 'empty' => ( type => 'Multiple', no_option_validation => 1 );
   has_field 'build_attr' => ( type => 'Select' );

   sub default_fruit { 2 }

   # the following sometimes happens with db options
   sub options_empty { ([]) }

   has 'options_fruit' => ( is => 'rw',
       default => sub { [1 => 'apples', 2 => 'oranges', 3 => 'kiwi'] } );

   sub options_vegetables {
       return (
           1   => 'lettuce',
           2   => 'broccoli',
           3   => 'carrots',
           4   => 'peas',
       );
   }

}


my $form = Test::Form->new;
ok( $form, 'create form');

my $veg_options =   [ {'label' => 'lettuce',
      'value' => 1 },
     {'label' => 'broccoli',
      'value' => 2 },
     {'label' => 'carrots',
      'value' => 3 },
     {'label' => 'peas',
      'value' => 4 } ];
my $field_options = $form->field('vegetables')->options;
is_deeply( $field_options, $veg_options,
   'get options for vegetables' );

my $fruit_options = [ {'label' => 'apples',
       'value' => 1 },
      {'label' => 'oranges',
       'value' => 2 },
      {'label' => 'kiwi',
       'value' => 3 } ];
$field_options = $form->field('fruit')->options;
is_deeply( $field_options, $fruit_options,
    'get options for fruit' );

is( $form->field('fruit')->value, 2, 'initial value ok');

$form->process( params => {},
    init_values => { vegetables => undef, fruit => undef, build_attr => undef } );
$field_options = $form->field('vegetables')->options;
is_deeply( $field_options, $veg_options,
   'get options for vegetables after process' );
$field_options = $form->field('fruit')->options;
is_deeply( $field_options, $fruit_options,
    'get options for fruit after process' );

my $params = {
   fruit => 2,
   vegetables => [2,4],
   empty => 'test',
};
$form->process( $params );
ok( $form->validated, 'form validated' );
is( $form->field('fruit')->value, 2, 'fruit value is correct');
is_deeply( $form->field('vegetables')->value, [2,4], 'vegetables value is correct');

is_deeply( $form->fif, { fruit => 2, vegetables => [2, 4], empty => ['test'], test_field => '', build_attr => '' },
    'fif is correct');
is_deeply( $form->values, { fruit => 2, vegetables => [2, 4], empty => ['test'] },
    'values are correct');

=comment
is( $form->field('vegetables')->as_label, 'broccoli, peas', 'multiple as_label works');
is( $form->field('vegetables')->as_label([3,4]), 'carrots, peas', 'pass in multiple as_label works');

$params = {
    fruit => 2,
    vegetables => 4,
};
$form->process($params);
is_deeply( $form->field('vegetables')->value, [4], 'value for vegetables correct' );
is_deeply( $form->field('vegetables')->fif, [4], 'fif for vegetables correct' );


{
    package Test::Multiple::InitObject;
    use Moo;
    use Data::MuForm::Meta;
    extends 'Data::MuForm';

    has_field 'foo' => ( default => 'my_foo' );
    has_field 'bar' => ( type => 'Multiple' );

   sub options_bar {
       return (
           1   => 'one',
           2   => 'two',
           3   => 'three',
           4   => 'four',
       );
   }


}

$form = Test::Multiple::InitObject->new;
my $init_values = { foo => 'new_foo', bar => [3,4] };
$form->process(init_values => $init_values, params => {} );
my $rendered = $form->render;
like($rendered, qr/<option value="4" id="bar.1" selected="selected">four<\/option>/, 'rendered option');
my $value = $form->value;
is_deeply( $value, $init_values, 'correct value');
=cut

done_testing;
