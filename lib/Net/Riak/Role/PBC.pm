package Net::Riak::Role::PBC;

use Mouse::Role;
use MouseX::Types::Mouse qw/Str Int/;

with qw(
  Net::Riak::Role::PBC::Message
  Net::Riak::Role::PBC::Bucket
  Net::Riak::Role::PBC::MapReduce
  Net::Riak::Role::PBC::Link
  Net::Riak::Role::PBC::Object);

use IO::Socket::INET;

has [qw/r w dw/] => (
    is      => 'rw',
    default => 2
);

has host => (
    is  => 'ro',
    required => 1,
);

has port => (
    is  => 'ro',
    required => 1,
);

has socket => (
    is => 'rw',
    predicate => 'has_socket',
);

has timeout => (
    is => 'ro',
    default => 30,
);

sub is_alive {
    my $self = shift;
    return $self->send_message('PingReq');
}

sub connected {
    my $self = shift;
    return $self->has_socket && $self->socket->connected ? 1 : 0;
}

sub connect {
    my $self = shift;
    return if $self->has_socket && $self->connected;
    $self->socket(
        IO::Socket::INET->new(
            PeerAddr => $self->host,
            PeerPort => $self->port,
            Proto    => 'tcp',
            Timeout  => $self->timeout,
        ) or die 'Failed to connect riak server at ' . $self->host . ':' .
        $self->port . " '$@'\n"
    );
}

sub all_buckets {
    my $self = shift;
    my $resp = $self->send_message('ListBucketsReq');
    return ref ($resp->buckets) eq 'ARRAY' ? @{$resp->buckets} : ();
}

sub server_info {
    my $self = shift;
    my $resp = $self->send_message('GetServerInfoReq');
    return $resp;
}

sub stats { die "->stats is only avaliable through the REST interface" }

1; 
