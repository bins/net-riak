package Net::Riak::Role::REST::Search;
use Mouse::Role;
use JSON;

#ABSTRACT: Search interface

sub search {
    my $self = shift;
    my %params = @_;
    my $request;

    $request =
      $self->new_request( 'GET',
        [ $self->search_prefix, "select" ], \%params ) unless $params{index};
    if ( $params{index} ){
        my $index = delete $params{index};
        $request =
            $self->new_request( 'GET',
                [ $self->search_prefix, $index, "select" ], \%params );
    }

    my $http_response = $self->send_request($request);

    return if (!$http_response);

    my $status = $http_response->code;
    if ($status == 404) {
        return;
    }

    return JSON::decode_json($http_response->content) if $params{wt} =~ /json/i;
    $http_response->content;
};

sub setup_indexing {
    my ( $self, $bucket ) = @_;
    my $request =
        $self->new_request( 'GET',
            [ $self->prefix, $bucket ] );

    my $http_response = $self->send_request($request);

    return if (!$http_response);
    my $status = $http_response->code;
    if ($status == 404) {
        return;
    }

    my $precommits = JSON::decode_json($http_response->content)->{props}->{precommit};

    for (@$precommits){
        return JSON::decode_json($http_response->content) if $_->{mod} eq "riak_search_kv_hook";
    }
    push ( @$precommits, { mod => "riak_search_kv_hook" , fun => "precommit" } );

    $request = $self->new_request( 'PUT', [ $self->prefix, $bucket ] );
    $request->content( JSON::encode_json({ props => { precommit => $precommits } } ) );
    $request->header('Content-Type' => "application/json" );

    $http_response = $self->send_request($request);

    return if (!$http_response);
    $status = $http_response->code;
    if ($status == 404) {
        return;
    }
    $request =
        $self->new_request( 'GET',
            [ $self->prefix, $bucket ] );

    $http_response = $self->send_request($request);

    JSON::decode_json($http_response->content);
}

1;
