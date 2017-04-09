#!./perl

use strict;
use warnings;

use Test::More tests => 18;
use List::Util qw(max);

my $v;

ok(defined &max, 'defined');

$v = max(1);
is($v, 1, 'single arg');

$v = max (1,2);
is($v, 2, '2-arg ordered');

$v = max(2,1);
is($v, 2, '2-arg reverse ordered');

my @a = map { rand() } 1 .. 20;
my @b = sort { $a <=> $b } @a;
$v = max(@a);
is($v, $b[-1], '20-arg random order');

my $one = Foo->new(1);
my $two = Foo->new(2);
my $thr = Foo->new(3);

$v = max($one,$two,$thr);
is($v, 3, 'overload');

$v = max($thr,$two,$one);
is($v, 3, 'overload');


{ package Foo;

use overload
  '""' => sub { ${$_[0]} },
  '0+' => sub { ${$_[0]} },
  '>'  => sub { ${$_[0]} > ${$_[1]} },
  fallback => 1;
  sub new {
    my $class = shift;
    my $value = shift;
    bless \$value, $class;
  }
}

use Math::BigInt;

my $v1 = Math::BigInt->new(2) ** Math::BigInt->new(65);
my $v2 = $v1 - 1;
my $v3 = $v2 - 1;
$v = max($v1,$v2,$v1,$v3,$v1);
is($v, $v1, 'bigint');

$v = max($v1, 1, 2, 3);
is($v, $v1, 'bigint and normal int');

$v = max(1, 2, $v1, 3);
is($v, $v1, 'bigint and normal int');

{
  my $warning;
  local $SIG{__WARN__} = sub { $warning = shift };

  is(max(), undef, 'no arg');
  is($warning, undef, 'no args no warning');

  is(max(undef), undef, 'undef arg');
  like($warning, qr/Use of uninitialized value in subroutine entry/, 'undef arg warning');

  is(max("a"), "a", 'non-numeric arg');
  like($warning, qr/Argument "a" isn't numeric in subroutine entry/, 'non-numeric arg warning');

  is(max(2, undef), 2, 'undef is smaller than 2');

  is(max(-2, undef), undef, 'undef is larger than -2');
}
