#!./perl -T

use strict;
use warnings;

use Test::More tests => 7;

use Scalar::Util qw(tainted);

ok( !tainted(1), 'constant number');

my $var = 2;

ok( !tainted($var), 'known variable');

ok( tainted($^X),	'interpreter variable');

$var = $^X;
ok( tainted($var),	'copy of interpreter variable');

{
    package Tainted;
    sub TIESCALAR { bless {} }
    sub FETCH { $^X }
}

tie my $tiedvar, 'Tainted';
ok( tainted($tiedvar), 'for magic variables');

{
  my $warning;
  local $SIG{__WARN__} = sub { $warning = shift };

  ok(!tainted(undef), 'undef is not tainted');
  is($warning, undef, 'no undef arg warning');
}
