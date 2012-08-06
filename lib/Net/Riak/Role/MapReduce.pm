package Net::Riak::Role::MapReduce;

use Mouse::Role;
use Net::Riak::MapReduce;

sub add {
    my ($self, @args) = @_;
    my $mr = Net::Riak::MapReduce->new(client => $self->client);
    $mr->add(@args);
    $mr;
}

sub link {
    my ($self, @args) = @_;
    my $mr = Net::Riak::MapReduce->new(client => $self->client);
    $mr->link(@args);
    $mr;
}

sub map {
    my ($self, @args) = @_;
    my $mr = Net::Riak::MapReduce->new(client => $self->client);
    $mr->map(@args);
    $mr;
}

sub reduce {
    my ($self, @args) = @_;
    my $mr = Net::Riak::MapReduce->new(client => $self->client);
    $mr->reduce(@args);
    $mr;
}

1;
