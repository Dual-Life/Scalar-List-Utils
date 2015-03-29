use strict;
use warnings;

use Test::More;
use B 'svref_2object';

# This is a mess. The stash can supposedly handle Unicode but the behavior
# is literally undefined before 5.16 (with crashes beyond the basic plane),
# and remains unclear past 5.16 with evalbytes and feature unicode_eval
# In any case - Sub::Name needs to *somehow* work with this, so we will do
# a heuristic with ambiguous eval and looking for octets in the stash
use if $] >= 5.016, feature => 'unicode_eval';

sub compile_named_sub {
    my ( $fullname, $body ) = @_;
    my $sub = eval "sub $fullname { $body }" . '\\&{$fullname}';
    return $sub if $sub;
    my $e = $@;
    require Carp;
    Carp::croak $e;
}

sub caller3_ok {
    my ( $sub, $expected, $type, $ord ) = @_;

    local $Test::Builder::Level = $Test::Builder::Level + 1;

    my $for_what = sprintf "when it contains \\x%s ( %s )", (
        ( ($ord > 255)
            ? sprintf "{%X}", $ord
            : sprintf "%02X", $ord
        ),
        (
            $ord > 255                    ? unpack('H*', pack 'C0U', $ord )
            : ($ord > 0x1f and $ord < 0x7f) ? sprintf "%c", $ord
            :                                 sprintf '\%o', $ord
        ),
    );

    $expected =~ s/'/::/g;

    # this is apparently how things worked before 5.16
    utf8::encode($expected) if $] < 5.016 and $ord > 255;

    my $stash_name = join '::', map { $_->STASH->NAME, $_->NAME } svref_2object($sub)->GV;

    is $stash_name, $expected, "stash name for $type is correct $for_what";
    is $sub->(), $expected, "caller() in $type returns correct name $for_what";
}

#######################################################################

use Sub::Util 'set_subname';

my @ordinal = ( 1 .. 255 );

# 5.14 is the first perl to start properly handling \0 in identifiers
unshift @ordinal, 0
    unless $] < 5.014;

# Unicode in 5.6 is not sane (crashes etc)
push @ordinal,
    0x100,    # LATIN CAPITAL LETTER A WITH MACRON
    0x498,    # CYRILLIC CAPITAL LETTER ZE WITH DESCENDER
    0x2122,   # TRADE MARK SIGN
    0x1f4a9,  # PILE OF POO
    unless $] < 5.008;

plan tests => @ordinal * 2 * 2;

my $legal_ident_char = "A-Z_a-z0-9'";
$legal_ident_char .= join '', map chr, 0x100, 0x498
    unless $] < 5.008;

for my $ord (@ordinal) {
    my $sub;
    my $pkg      = sprintf 'test::SOME_%c_STASH', $ord;
    my $subname  = sprintf 'SOME_%c_NAME', $ord;
    my $fullname = join '::', $pkg, $subname;

    $sub = set_subname $fullname => sub { (caller(0))[3] };
    caller3_ok $sub, $fullname, 'renamed closure', $ord;

    # test that we can *always* compile at least within the correct package
    my $expected;
    if ( chr($ord) =~ m/^[$legal_ident_char]$/o ) { # compile directly
        $expected = $fullname;
        $sub = compile_named_sub $fullname => '(caller(0))[3]';
    }
    else { # not a legal identifier but at least test the package name by aliasing
        $expected = "${pkg}::foo";
        { no strict 'refs'; *palatable:: = *{"${pkg}::"} } # now palatable:: literally means ${pkg}::
        $sub = compile_named_sub 'palatable::foo' => '(caller(0))[3]';
    }
    caller3_ok $sub, $expected, 'natively compiled sub', $ord;
}
