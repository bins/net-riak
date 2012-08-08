package Net::Riak::Types;

use MouseX::Types::Mouse qw/Str ArrayRef HashRef/;
use MouseX::Types -declare => [qw(RiakHost)];

subtype RiakHost, as ArrayRef [HashRef];

coerce RiakHost, from Str, via {
    [ { node => $_, weight => 1 } ];
};

coerce RiakHost, from ArrayRef, via {
    warn "DEPRECATED: Support for multiple hosts will be removed in the 0.17 release.";
    my $backends = $_;
    my $weight   = 1 / @$backends;
    [ map { { node => $_, weight => $weight } } @$backends ];
};

coerce RiakHost, from HashRef, via {
    warn "DEPRECATED: Support for multiple hosts will be removed in the 0.17 release.";
    my $backends = $_;
    my $total    = 0;
    $total += $_ for values %$backends;
    [
        map { { node => $_, weight => $backends->{$_} / $total } }
          keys %$backends
    ];
};

1;

