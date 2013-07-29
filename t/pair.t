#!./perl

use strict;
use Test::More tests => 4;
use List::Util qw(pairgrep pairmap);

is_deeply( [ pairgrep { $b % 2 } one => 1, two => 2, three => 3 ],
           [ one => 1, three => 3 ],
           'pairgrep list' );

is( scalar( pairgrep { $b & 2 } one => 1, two => 2, three => 3 ),
    2,
    'pairgrep scalar' );

is_deeply( [ pairmap { uc $a => $b } one => 1, two => 2, three => 3 ],
           [ ONE => 1, TWO => 2, THREE => 3 ],
           'pairmap list' );

is_deeply( [ pairmap { $a => @$b } one => [1,1,1], two => [2,2,2], three => [3,3,3] ],
           [ one => 1, 1, 1, two => 2, 2, 2, three => 3, 3, 3 ],
           'pairmap list returning >2 items' );
