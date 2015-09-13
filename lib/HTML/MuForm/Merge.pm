package HTML::MuForm::Merge;
# ABSTRACT: internal hash merging
use warnings;
use Data::Clone ('data_clone');
use base 'Exporter';

our @EXPORT_OK = ( 'merge' );

our $matrix = {
    'SCALAR' => {
        'SCALAR' => sub { $_[0] },
        'ARRAY'  => sub { [ $_[0], @{ $_[1] } ] },
        'HASH'   => sub { $_[1] },
    },
    'ARRAY' => {
        'SCALAR' => sub { [ @{ $_[0] }, $_[1] ] },
        'ARRAY'  => sub { [ @{ $_[0] }, @{ $_[1] } ] },
        'HASH'   => sub { $_[1] },
    },
    'HASH' => {
        'SCALAR' => sub { $_[0] },
        'ARRAY'  => sub { $_[0] },
        'HASH'   => sub { merge_hashes( $_[0], $_[1] ) },
    },
};

sub merge {
    my ( $left, $right ) = @_;

    my $lefttype =
        ref $left eq 'HASH'  ? 'HASH' :
        ref $left eq 'ARRAY' ? 'ARRAY' :
                               'SCALAR';
    my $righttype =
        ref $right eq 'HASH'  ? 'HASH' :
        ref $right eq 'ARRAY' ? 'ARRAY' :
                                'SCALAR';
    $left  = data_clone($left);
    $right = data_clone($right);
    return $matrix->{$lefttype}{$righttype}->( $left, $right );
}

sub merge_hashes {
    my ( $left, $right ) = @_;
    my %newhash;
    foreach my $leftkey ( keys %$left ) {
        if ( exists $right->{$leftkey} ) {
            $newhash{$leftkey} = merge( $left->{$leftkey}, $right->{$leftkey} );
        }
        else {
            $newhash{$leftkey} = data_clone( $left->{$leftkey} );
        }
    }
    foreach my $rightkey ( keys %$right ) {
        if ( !exists $left->{$rightkey} ) {
            $newhash{$rightkey} = data_clone( $right->{$rightkey} );
        }
    }
    return \%newhash;
}

1;
