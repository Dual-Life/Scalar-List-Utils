#!./perl

use strict;
use warnings;

use Test::More tests => 4;

use List::Util qw(pick);

my $i;

$i = pick();
ok( !$i, 'no args' );

my @items = pick();
is( scalar @items, 1, 'pick always returns a scalar' );

$i = pick( 1 );
is( $i, 1, 'one in, 1 out' );

$i = pick( 2, 2, 2, 2, 2, 2 );
is( $i, 2, 'a bunch in, one out' );

