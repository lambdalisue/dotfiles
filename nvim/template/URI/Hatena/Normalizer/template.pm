package URI::Hatena::Normalizer::<%=expand('%:t:r')%>;
use strict;
use warnings;
use utf8;

sub normalize {
    my ($class, $url) = @_;

    my $path = $url->path;
    $url->path($path) if $path =~ s!^/s/!/!;
    <+CURSOR+>

    return $url;
}

1;
