#!./perl

use strict;
use warnings;

use Test::More;

use List::Util qw( reductions );

is_deeply( [ reductions { } ], [],
  'emmpty list'
);

is_deeply(
  [ reductions { $a + $b } 1 .. 5 ],
  [ 1, 3, 6, 10, 15 ],
  'sum 1..5'
);

{
  my $destroyed_count;
  sub Guardian::DESTROY { $destroyed_count++ }

  my @ret = reductions { $b } map { bless [], "Guardian" } 1 .. 5;

  ok( !$destroyed_count, 'nothing destroyed yet' );

  @ret = ();

  is( $destroyed_count, 5, 'all the items were destroyed' );
}

done_testing;
