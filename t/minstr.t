#!./perl

use strict;
use warnings;

use Test::More tests => 12;
use List::Util qw(minstr);

my $v;

ok(defined &minstr, 'defined');

$v = minstr('a');
is($v, 'a', 'single arg');

$v = minstr('a','b');
is($v, 'a', '2-arg ordered');

$v = minstr('B','A');
is($v, 'A', '2-arg reverse ordered');

my @a = map { pack("u", pack("C*",map { int(rand(256))} (0..int(rand(10) + 2)))) } 0 .. 20;
my @b = sort { $a cmp $b } @a;
$v = minstr(@a);
is($v, $b[0], 'random ordered');

{
  my $warning;
  local $SIG{__WARN__} = sub { $warning = shift };

  is(minstr(), undef, 'no arg');
  is($warning, undef, 'no args no warning');

  is(minstr(undef), undef, 'single undef arg');
  is($warning, undef, 'no single undef arg warning'); # XXX

  is(minstr(undef, undef), undef, 'two undef arg');
  like($warning, qr/Use of uninitialized value in subroutine entry/, 'two undef arg warning');

  is(minstr("a", undef), undef, 'undef is lt anything');
}
