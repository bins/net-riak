package Net::Riak::Link;

# ABSTRACT: the riaklink object represents a link from one Riak object to another

use Mouse;

# with 'Net::Riak::Role::Base' => {classes =>
#       [{name => 'client', required => 0}, {name => 'bucket', required => 1},]};

# Replacement for  with 'Net::Riak::Role::Base'
has client => (
    is       => 'rw',
    isa      => 'Net::Riak::Client',
    required => 0,
);

has bucket => (
    is       => 'rw',
    isa      => 'Net::Riak::Bucket',
    required => 1,
);

has key => (
    is      => 'rw',
    isa     => 'Str',
    lazy    => 1,
    default => '_',
);
has tag => (
    is      => 'rw',
    isa     => 'Str',
    lazy    => 1,
    default => sub {(shift)->bucket->name}
);

1;
