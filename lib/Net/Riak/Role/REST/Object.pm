package Net::Riak::Role::REST::Object;

use Moose::Role;
use JSON;

sub store_object {
    my ($self, $w, $dw, $object) = @_;

    my $params = {returnbody => 'true', w => $w, dw => $dw};

    $params->{returnbody} = 'false'
        if $self->disable_return_body;

    my $request =
      $self->new_request('PUT',
        [$self->prefix, $object->bucket->name, $object->key], $params);

    $request->header('X-Riak-ClientID' => $self->client_id);
    $request->header('Content-Type'    => $object->content_type);

    if ($object->has_vclock) {
        $request->header('X-Riak-Vclock' => $object->vclock);
    }

    if ($object->has_links) {
        $request->header('link' => $self->_links_to_header($object));
    }

    if (ref $object->data && $object->content_type eq 'application/json') {
        $request->content(JSON::encode_json($object->data));
    }
    else {
        $request->content($object->data);
    }

    my $response = $self->send_request($request);
    $self->populate_object($object, $response, [200, 201, 204, 300]);
    return $object;
}

sub load_object {
    my ( $self, $params, $object ) = @_;

    my $request =
      $self->new_request( 'GET',
        [ $self->prefix, $object->bucket->name, $object->key ], $params );

    my $response = $self->send_request($request);
    $self->populate_object($object, $response, [ 200, 300, 404 ] );
    $object;
}

sub delete_object {
    my ( $self, $params, $object ) = @_;

    my $request =
      $self->new_request( 'DELETE',
        [ $self->prefix, $object->bucket->name, $object->key ], $params );

    my $response = $self->send_request($request);
    $self->populate_object($object, $response, [ 204, 404 ] );
    $object;
}

sub populate_object {
    my ($self, $obj, $http_response, $expected) = @_;

    $obj->_clear_links;
    $obj->exists(0);

    return if (!$http_response);

    my $status = $http_response->code;

    $obj->data($http_response->content)
        unless $self->disable_return_body;

    if (!grep { $status == $_ } @$expected) {
        confess "Expected status "
          . (join(', ', @$expected))
          . ", received $status"
    }

    if ($status == 404) {
        $obj->clear;
        return;
    }

    $obj->exists(1);

    if ($http_response->header('link')) {
        $obj->_populate_links($http_response->header('link'));
    }

    if ($status == 300) {
        my @siblings = split("\n", $obj->data);
        shift @siblings;
        $obj->siblings(\@siblings);
    }
    
    if ($status == 201) {
        my $location = $http_response->header('location');
        my ($key)    = ($location =~ m!/([^/]+)$!);
        $obj->key($key);
    } 
    

    if ($status == 200 || $status == 201) {
        $obj->content_type($http_response->content_type)
            if $http_response->content_type;
        $obj->data(JSON::decode_json($obj->data))
            if $obj->content_type eq 'application/json';
        $obj->vclock($http_response->header('X-Riak-Vclock'));
    }
}


sub _links_to_header {
    my ($self, $object) = @_;
    join(', ', map { $_->to_link_header($self) } $object->links);
}

1;
__END__

=item populate_object

Given the output of RiakUtils.http_request and a list of statuses, populate the object. Only for use by the Riak client library.
