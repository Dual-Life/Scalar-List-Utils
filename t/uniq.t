#!./perl

use strict;
use warnings;

use Test::More;

use B qw(svref_2object);
use List::Util qw(uniq);
use Tie::Array;

{
    my @array = map { ( 1 .. 10 ) } 0 .. 1;
    is_deeply(
        [ uniq @array ],
        [ 1 .. 10 ],
        'uniq uniquifies numbers correctly'
    );
}

{
    my @array = map { ( 'a' .. 'z' ) } 0 .. 1;
    is_deeply(
        [ uniq @array ],
        [ 'a' .. 'z' ],
        'uniq uniquifies strings correctly'
    );
}

{
    my @array = (
        ( map { ( 1 .. 10 ) } 0 .. 1 ),
        ( map { ( 'a' .. 'z' ) } 0 .. 1 )
    );

    my @u = uniq @array;
    is_deeply(
        \@u,
        [ 1 .. 10, 'a' .. 'z' ],
        'uniq uniquifies mixed numbers and strings correctly'
    );

    ok(
        !( grep { _is_string($_) } @array[ 0 .. 9 ] ),
        'none of the numbers in the array were stringified by uniq'
    );
}

{
    my @array;
    tie @array, 'Tie::StdArray';
    @array = (
        ( map { ( 1 .. 10 ) } 0 .. 1 ),
        ( map { ( 'a' .. 'z' ) } 0 .. 1 )
    );

    my @u = uniq @array;
    is_deeply(
        \@u,
        [ 1 .. 10, 'a' .. 'z' ],
        'uniq uniquifies mixed numbers and strings correctly in a tied array'
    );

    ok(
        !( grep { _is_string($_) } @array[ 0 .. 9 ] ),
        'none of the numbers in the tied array were stringified by uniq'
    );
}

{
    my @array = ( 'a', 'b', '', undef, 'b', 'c', undef, '' );
    is_deeply(
        [ uniq @array ],
        [ 'a', 'b', '', undef, 'c' ],
        'undef is handled correctly'
    );
}

{
    package DieOnStringify;
    use overload q{""} => \&stringify;
    sub new { bless {}, shift }
    sub stringify { die 'DieOnStringify exception' }
}

if ( eval { require Test::LeakTrace; 1 } ) {
    Test::LeakTrace->import('no_leaks_ok');

    no_leaks_ok(
        sub {
            my @array = map { ( 1 .. 1000 ) } 0 .. 1;
            my @uniq  = uniq @array;
            my $count = uniq @array;
            uniq @array[ 1 .. 100 ];
        },
        'no leaks calling uniq in list, scalar, and void context'
    );

    # This test (and the associated fix) are from Kevin Ryde; see RT#49796
    no_leaks_ok(
        sub {
            eval {
                my $obj = DieOnStringify->new;
                my @u = uniq $obj, $obj;
            };
            eval {
                my $obj = DieOnStringify->new;
                my $u = uniq $obj, $obj;
            };
        },
        'uniq with exception in overloading stringify',
    );
}

done_testing;

sub _is_string {
    return svref_2object( \$_[0] )->FLAGS & B::SVf_POK;
}
