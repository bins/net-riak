package Net::Riak::Link;

# ABSTRACT: the riaklink object represents a link from one Riak object to another

use Mouse;

=attr client

rw, object of Net::Riak::Client 

=cut

has client => (
    is       => 'rw',
);

=attr bucket

rw, required, object of Net::Riak::Bucket

=cut

has bucket => (
    is       => 'rw',
    required => 1,
);

=attr key

rw, Str, default value is '_'

=cut

has key => (
    is      => 'rw',
    lazy    => 1,
    default => '_',
);

=attr tag

rw, Str, default value is the name of bucket

=cut

has tag => (
    is      => 'rw',
    lazy    => 1,
    default => sub {(shift)->bucket->name}
);

1;
