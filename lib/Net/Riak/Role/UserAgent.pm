package Net::Riak::Role::UserAgent;

# ABSTRACT: useragent for Net::Riak

use Mouse::Role;
use LWP::UserAgent;
use LWP::ConnCache;

our $CONN_CACHE;

sub connection_cache { $CONN_CACHE ||= LWP::ConnCache->new }

has ua_timeout => (
    is  => 'rw',
    default => 120
);

=attr useragent

rw, object of LWP::UserAgent, default value is new object of LWP::UserAgent
with given attribute timeout

=cut

has useragent => (
    is      => 'rw',
    lazy    => 1,
    default => sub {
        my $self = shift;

        # The Links header Riak returns (esp. for buckets) can get really long,
        # so here increase the MaxLineLength LWP will accept (default = 8192)
        my %opts = @LWP::Protocol::http::EXTRA_SOCK_OPTS;
        $opts{MaxLineLength} = 65_536;
        @LWP::Protocol::http::EXTRA_SOCK_OPTS = %opts;

        my $ua = LWP::UserAgent->new(
            timeout => $self->ua_timeout,
            keep_alive => 1,
        );

        $ua->conn_cache(__PACKAGE__->connection_cache);

        $ua;
    }
);

1;
