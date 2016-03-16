#!./perl

use strict;
use warnings;

use Test::More tests => 19;
use List::Util qw( uniq uniqnum );

is_deeply( [ uniq ],
           [],
           'uniq of empty list' );

is_deeply( [ uniq qw( abc ) ],
           [qw( abc )],
           'uniq of singleton list' );

is_deeply( [ uniq qw( x x x ) ],
           [qw( x )],
           'uniq of repeated-element list' );

is_deeply( [ uniq qw( a b a c ) ],
           [qw( a b c )],
           'uniq removes subsequent duplicates' );

is_deeply( [ uniq qw( 1 1.0 1E0 ) ],
           [qw( 1 1.0 1E0 )],
           'uniq compares strings' );

{
    my $warnings = "";
    local $SIG{__WARN__} = sub { $warnings .= join "", @_ };

    my $cafe = "cafe\x{301}";

    is_deeply( [ uniq $cafe ],
               [ $cafe ],
               'uniq is happy with Unicode strings' );

    utf8::encode( my $cafebytes = $cafe );

    is_deeply( [ uniq $cafe, $cafebytes ],
               [ $cafe, $cafebytes ],
               'uniq does not squash bytewise-equal but differently-encoded strings' );

    is( $warnings, "", 'No warnings are printed when handling Unicode strings' );
}

is_deeply( [ uniqnum qw( 1 1.0 1E0 2 3 ) ],
           [ 1, 2, 3 ],
           'uniqnum compares numbers' );

is_deeply( [ uniqnum qw( 1 1.1 1.2 1.3 ) ],
           [ 1, 1.1, 1.2, 1.3 ],
           'uniqnum distinguishes floats' );

my $Inf = 0 + "Inf";
my $NaN = $Inf - $Inf;

is_deeply( [ uniqnum 0, 1, 12345, $Inf, -$Inf, $NaN, 0, $Inf, $NaN ],
           [ 0, 1, 12345, $Inf, -$Inf, $NaN ],
           'uniqnum preserves the special values of +-Inf and Nan' );

{
    my $maxint = ~0;

    is_deeply( [ uniqnum $maxint, $maxint-1, -1 ],
               [ $maxint, $maxint-1, -1 ],
               'uniqnum preserves uniqness of full integer range' );
}

is( scalar( uniq qw( a b c d a b e ) ), 5, 'uniq() in scalar context' );

{
    package Stringify;

    use overload '""' => sub { return $_[0]->{str} };

    sub new { bless { str => $_[1] }, $_[0] }

    package main;

    my @strs = map { Stringify->new( $_ ) } qw( foo foo bar );

    is_deeply( [ uniq @strs ],
               [ $strs[0], $strs[2] ],
               'uniq respects stringify overload' );
}

{
    package Numify;

    use overload '0+' => sub { return $_[0]->{num} };

    sub new { bless { num => $_[1] }, $_[0] }

    package main;
    use Scalar::Util qw( refaddr );

    my @nums = map { Numify->new( $_ ) } qw( 2 2 5 );

    # is_deeply wants to use eq overloading
    my @ret = uniqnum @nums;
    ok( scalar @ret == 2 &&
        refaddr $ret[0] == refaddr $nums[0] &&
        refaddr $ret[1] == refaddr $nums[2],
               'uniqnum respects numify overload' );
}

{
    package DestroyNotifier;

    use overload '""' => sub { "SAME" };

    sub new { bless { var => $_[1] }, $_[0] }

    sub DESTROY { ${ $_[0]->{var} }++ }

    package main;

    my @destroyed = (0) x 3;
    my @notifiers = map { DestroyNotifier->new( \$destroyed[$_] ) } 0 .. 2;

    my @uniq = uniq @notifiers;
    undef @notifiers;

    is_deeply( \@destroyed, [ 0, 1, 1 ],
               'values filtered by uniq() are destroyed' );

    undef @uniq;
    is_deeply( \@destroyed, [ 1, 1, 1 ],
               'all values destroyed' );
}

{
    "a a b" =~ m/(.) (.) (.)/;
    is_deeply( [ uniq $1, $2, $3 ],
               [qw( a b )],
               'uniq handles magic' );

    "1 1 2" =~ m/(.) (.) (.)/;
    is_deeply( [ uniqnum $1, $2, $3 ],
               [ 1, 2 ],
               'uniqnum handles magic' );
}
