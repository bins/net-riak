package Net::Riak::MapReducePhase;

use Mouse;
use Scalar::Util;
use JSON;

=attr type

rw, Str, required

=cut

has type => (
    is => 'rw', 
    required => 1,
);

=attr function

rw, Str, required

=cut

has function => (
    is => 'ro', 
    required => 1
);

=attr arg

rw, ArrayRef, required, list of arg, default value is 'None'

=cut

has arg      => (
    is => 'ro', 
    default  => 'None'
);

=attr language

rw, Str, default value is 'javascript'

=cut

has language => (
    is => 'ro', 
    default  => 'javascript'
);

=attr keep

rw, a JSON::Boolean value, could be 'JSON::true' or 'JSON::false', default
value is 'JSON::false'

=cut

has keep => (
    is => 'rw', 
    default => sub {JSON::false}
);

sub to_array {
    my $self = shift;

    my $step_def = {
        keep     => $self->keep,
        language => $self->language,
        arg      => $self->arg
    };

    if ($self->function =~ m!\{!) {
        $step_def->{source} = $self->function;
    }else{
        $step_def->{name} = $self->function;
    }
    return {$self->type => $step_def};
}

1;
