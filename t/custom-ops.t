#!./perl

use strict;
use warnings;

use B::Concise;
use Scalar::Util;
use Test::More;

my @ops = qw/
    blessed
    isdual
    isvstring
    isweak
    looks_like_number
    readonly
    reftype
    tainted
/;

plan +($] <= 5.014_000)
    ? (skip_all => 'Perl is too old for custom ops')
    : (tests => 3 * @ops);

Scalar::Util->import(@ops);

for (@ops) {
    B::Concise::walk_output(\my $out);

    B::Concise::compile(
        '-exec', $_, eval "sub { $_(1) }",
    )->();

    like   $out, qr/ $_ /,         "$_ is a custom op";
    unlike $out, qr/\bentersub\b/, "$_ doesn't use entersub";

    my $sub = \&$_;

    eval { $sub->(1) };

    is $@, '', "$_ via a subref doesn't die";
}
