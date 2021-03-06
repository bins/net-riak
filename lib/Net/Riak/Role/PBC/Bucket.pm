package Net::Riak::Role::PBC::Bucket;

use Mouse::Role;
use Data::Dumper;

sub get_properties {
    my ( $self, $name, $params ) = @_;
    my $resp = $self->send_message( GetBucketReq => { bucket => $name } );
    return { props =>  { %{ $resp->props } } };
}

sub set_properties {
    my ( $self, $bucket, $props ) = @_;
    return $self->send_message(
        SetBucketReq => {
            bucket => $bucket->name,
            props  => $props
        }
    );
}

sub get_keys {
    my ( $self, $name, $params) = @_;
    my $keys = [];

    my $res = $self->send_message(
        ListKeysReq => { bucket => $name, },
        sub {
            if ( defined $_[0]->keys ) {
                if ($params->{cb}) {
                    $params->{cb}->($_) for @{ $_[0]->keys };
                } 
                else {
                    push @$keys, @{ $_[0]->keys };
                }
            }
        }
    );

    return $params->{cb} ? undef : $keys; 
}



1;

