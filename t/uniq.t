#!./perl

use strict;
use warnings;

use Test::More tests => 6;
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

is_deeply( [ uniqnum qw( 1 1.0 1E0 2 3 ) ],
           [ 1, 2, 3 ],
           'uniqnum compares numbers' );
