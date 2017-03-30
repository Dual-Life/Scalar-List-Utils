#!./perl

use strict;
use warnings;

use Test::More tests => 14;

use List::Util qw(pick);

my ( $i, @items );

$i = pick( 1 );
ok( !$i, 'no list to pick from' );
@items = pick( 1 );
is( scalar @items, 0, 'pick returns empty list if no list given' );

$i = pick( 0 );
ok( !$i, 'no list to pick from' );
@items = pick( 0 );
is( scalar @items, 0, 'pick always returns the correct number of items' );

$i = pick( 0, 1, 2, 3, 4 );
ok( !$i, 'pick 0 items' );
@items = pick( 0, 1, 2, 3, 4 );
is( scalar @items, 0, 'pick returns empty list if no list given' );

$i = pick( 1, 1 );
is( $i, 1, 'one in, 1 out' );

@items = pick( 2, 2, 2, 2, 2, 2 );
is( scalar @items, 2, 'asked for 2 got 2' );
is( $items[0], 2, 'a bunch in, two out' );
is( $items[1], 2, 'a bunch in, two out' );

@items = pick( 2, 1, 2 );
is( scalar @items, 2, 'asked for 2 got 2' );
ok +(
    ( $items[0] == 1 && $items[1] == 2 ) || ( $items[0] == 2 && $items[1] == 1 )
   ), 'each item picked only once';

@items = pick( 2, 1 );
is( scalar @items, 1, 'only one item to pick from' );
is( $items[0], 1, 'got the right item' );
