#!./perl

use strict;
use warnings;

use Test::More tests => 4;
use List::Util qw(zip);

is_deeply( [zip ()], [],
  'zip empty returns empty');

is_deeply( [zip ['a'..'c']], [ ['a'], ['b'], ['c'] ],
  'zip of one list returns a list of singleton lists' );

is_deeply( [zip ['one', 'two'], [1, 2]], [ [one => 1], [two => 2] ],
  'zip of two lists returns a list of pair lists' );

is_deeply( [zip ['x', 'y', 'z'], ['X', 'Y']], [ ['x', 'X'], ['y', 'Y'], ['z', undef] ],
  'zip extends short lists with undef' );
