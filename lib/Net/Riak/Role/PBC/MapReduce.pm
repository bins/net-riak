package Net::Riak::Role::PBC::MapReduce;
use Mouse::Role;
use JSON;
use List::Util 'sum';
use Data::Dump 'pp';

sub execute_job {
    my ($self, $job, $timeout, $returned_phases) = @_;

    $job->{timeout} = $timeout;

    my $job_request = JSON::encode_json($job);

    my $results;

    my $resp = $self->send_message( MapRedReq => {
            request => $job_request,
            content_type => 'application/json'
        }, sub { push @$results, $self->decode_phase(shift) }) 
        or 
    die "MapReduce query failed!";


    return $returned_phases == 1 ? $results->[0] : $results;
}

sub decode_phase {
    my ($self, $resp) = @_;

    if (defined $resp->response && length($resp->response)) {
        return JSON::decode_json($resp->response);
    }

    return;
}

1;
