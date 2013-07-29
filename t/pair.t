#!./perl

use strict;
use Test::More tests => 2;
use List::Util qw(pairgrep);

is_deeply( [ pairgrep { $b % 2 } one => 1, two => 2, three => 3 ],
           [ one => 1, three => 3 ],
           'pairgrep list' );

is( scalar( pairgrep { $b & 2 } one => 1, two => 2, three => 3 ),
    2,
    'pairgrep scalar' );
