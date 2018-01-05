#!./perl

use strict;
use warnings;

use Test::More tests => 9;

use List::Util qw( sum0 );

my $v = sum0;
is( $v, 0, 'no args' );

$v = sum0(9);
is( $v, 9, 'one arg' );

$v = sum0(1,2,3,4);
is( $v, 10, '4 args');

{
  my $warning;
  local $SIG{__WARN__} = sub { $warning = shift };

  is(sum0(undef), 0, 'undef arg');
  like($warning, qr/Use of uninitialized value in subroutine entry/, 'undef arg warning');

  is(sum0("a"), 0, 'non-numeric arg');
  like($warning, qr/Argument "a" isn't numeric in subroutine entry/, 'non-numeric arg warning');

  is(sum0(2, undef), 2, 'undef gets forced to 0');

  is(sum0(2, "a"), 2, 'strings get forced to 0');
}
