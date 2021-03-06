use strict;
use warnings;
use Test::More;

{
   package My::Form;
   use Moo;
   use Data::MuForm::Meta;
   extends 'Data::MuForm';

   has '+name' => ( default => 'testform_' );
   sub field_list {
       return [
           reqname     => {
              type => 'Text',
              required => 1,
              messages => { required => 'You must supply a reqname' },
           },
           fruit       => 'Select',
           optname     => 'Text',
           silly_name  => {
              type =>'Text',
           }
       ];
   }
   sub options_fruit {
       return (
           1   => 'apples',
           2   => 'oranges',
           3   => 'kiwi',
       );
   }
   sub validate_silly_name {
      my ( $self, $field ) = @_;
      $field->add_error( 'Not a valid silly_name' )
            unless $field->value eq 'TeStInG';
   }
}

my $form = My::Form->new;

my $bad_1 = {
    optname => 'not req',
    fruit   => 4,
    silly_name => 'what??',
    reqname => '',
};

ok( !$form->process( $bad_1 ), 'bad 1' );

ok( $form->has_errors, 'form has errors' );

is( $form->num_fields, 4, 'form has right number of fields' );

my $errors_by_id = {
    fruit => [q{'4' is not a valid value}],
    reqname => ['You must supply a reqname'],
    silly_name => ['Not a valid silly_name'],
};

is_deeply( $form->errors_by_id, $errors_by_id, 'right errors' );

is_deeply( $form->errors_by_name, $errors_by_id, 'errors by name are the same as by id');

ok( $form->field('fruit')->has_errors, 'fruit has error' );

ok( $form->field('reqname')->has_errors, 'reqname has error' );

ok( !$form->field('optname')->has_errors, 'optname has no error' );
ok( $form->field('silly_name')->has_errors, 'silly_name has error' );
ok( $form->has_errors, 'form has errors' );

my @fields = $form->error_fields;
ok( @fields, 'error fields' );

my $errors = $form->errors;
is_deeply( $errors, [
                     'You must supply a reqname',
                     '\'4\' is not a valid value',
                     'Not a valid silly_name' ],
     'errors from form' );

is( $form->num_errors, 3, 'number of errors' );


{
   package Repeatable::Form;
   use Moo;
   use Data::MuForm::Meta;
   extends 'Data::MuForm';

   has_field 'my_test';
   has_field 'addresses' => ( type => 'Repeatable' );
   has_field 'addresses.street';
   has_field 'addresses.city';
   has_field 'addresses.country';

   sub validate_addresses_city
   {
      my ( $self, $field ) = @_;
      $field->add_error("Invalid City: " . $field->value)
         if( $field->value !~ /City/ );
   }
}

my $init_values = {
   my_test => 'repeatable_errors',
   addresses => [
      {
         street => 'First Street',
         city => 'Prime',
         country => 'Utopia',
         id => 0,
      },
      {
         street => 'Second Street',
         city => 'Secondary',
         country => 'Graustark',
         id => 1,
      },
      {
         street => 'Third Street',
         city => 'Tertiary City',
         country => 'Atlantis',
         id => 2,
      }
   ]
};

$form = Repeatable::Form->new;
ok( $form, 'form created');
$form->process( $init_values );
ok( !$form->validated, 'form did not validate' );
is( $form->num_errors, 2, 'form has two errors' );
my $rendered_field = $form->field('addresses')->render;
ok( $rendered_field, 'rendered field with auto_id ok' );

{
    package Form;
    use Moo;
    use Data::MuForm::Meta;
    extends 'Data::MuForm';

    has_field 'foo' => ( type => 'Repeatable', required => 1);
    has_field 'foo.bar' => ( type => 'Text', required => 1);
    has_field 'foo.optional' => ( type => 'Text', required => 0);
}

$form = Form->new;

ok(!$form->process( params => { 'foo.0.bar' => '' , 'foo.1.bar' => '' }),
   'Processing a form with empty fields should not validate');

ok(!$form->process( params => { 'foo.0.bar' => '' , 'foo.1.bar' => 'Test' }),
   'Processing a form with some empty fields should not validate');

ok(!$form->process( params => { 'foo.0.bar' => 'Test' , 'foo.1.bar' => '' }),
   'Processing a form with some empty fields should not validate');

ok($form->process( params => { 'foo.0.bar' => 'Test' , 'foo.1.bar' => 'Test' }),
   'Processing a form with all inputs validates');


done_testing;
