package Net::Riak::LinkPhase;

use Mouse;
use JSON;

has bucket => (is => 'ro', required => 1);
has tag    => (is => 'ro', required => 1);
has keep   => (is => 'rw', required => 1);

sub to_array {
    my $self     = shift;
    my $step_def = {
        bucket => $self->bucket,
        tag    => $self->tag,
        keep   => $self->keep,
    };
    return {link => $step_def};
}

1;
