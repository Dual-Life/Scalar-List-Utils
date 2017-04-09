#!./perl

use strict;
use warnings;

$|=1;
use Scalar::Util ();
use Test::More  (grep { /isvstring/ } @Scalar::Util::EXPORT_FAIL)
			? (skip_all => 'isvstring requires XS version')
			: (tests => 7);

Scalar::Util->import(qw[isvstring]);

my $vs = ord("A") == 193 ? 241.75.240 : 49.46.48;

ok( $vs == "1.0",	'dotted num');
ok( isvstring($vs),	'isvstring');

my $sv = "1.0";
ok( !isvstring($sv),	'not isvstring');

ok !eval { isvstring() }, "arg count gets checked";
ok !eval { isvstring(2, "a") }, "arg count gets checked";

{
  my $warning;
  local $SIG{__WARN__} = sub { $warning = shift };

  ok(!isvstring(undef), 'undef is no ivstring');
  is($warning, undef, 'no undef arg warning');
}
