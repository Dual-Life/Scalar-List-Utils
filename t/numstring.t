#!./perl

use strict;
use warnings;

use Scalar::Util ();
use Test::More  (grep { /isstring|isnumeric/ } @Scalar::Util::EXPORT_FAIL)
			? (skip_all => 'isstring/isnumeric requires XS version')
			: (tests => 6);
use Config;

Scalar::Util->import('isstring');
Scalar::Util->import('isnumeric');

my $var;
$var = "abc";
ok( isstring($var),	'Is a string');
ok( !isnumeric($var), 'Is not a number');

my $var2;
{
	no warnings 'numeric';
	$var2 = $var + 0;
}
ok( isnumeric($var), 'Is a number');

my $var3 = 42;
ok( !isstring($var3),	'Is not a string');
ok( isnumeric($var3), 'Is a number');

my $var4 = "$var3";
ok( isstring($var3),	'Is a string');

