package Net::Riak::Transport::REST;

use Mouse::Role;

with qw/
  Net::Riak::Role::UserAgent
  Net::Riak::Role::REST
  Net::Riak::Role::Hosts
  /;

1;
