use Test::More tests => 4;
use_ok 'List::Util', ':all';
use_ok 'Scalar::Util', ':all';
can_ok __PACKAGE__, 'blessed';
can_ok __PACKAGE__, 'min';
