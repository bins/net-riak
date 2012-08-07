package Net::Riak::Client;

use Mouse;
use MIME::Base64;

with 'MouseX::Traits';

has prefix => (
    is      => 'rw',
    default => 'riak'
);
has mapred_prefix => (
    is      => 'rw',
    default => 'mapred'
);
has search_prefix => (
    is      => 'rw',
    default => 'solr'
);
has [qw/r w dw/] => (
    is      => 'rw',
    default => 2
);
has client_id => (
    is         => 'rw',
    lazy_build => 1,
);

sub _build_client_id {
    "perl_net_riak" . encode_base64(int(rand(10737411824)), '');
}


1;
