
use Ref::Util qw(reftype);
use vars qw($t $y $x *F);

print "1..7\n";

print "not " if reftype(1);
print "ok 1\n";

print "not " if reftype('A');
print "ok 2\n";

print "not " unless reftype({}) eq 'HASH';
print "ok 3\n";

print "not " unless reftype([]) eq 'ARRAY';
print "ok 4\n";

$y = \$t;

print "not " unless reftype($y) eq 'SCALAR';
print "ok 5\n";

$x = bless [], "ABC";

print "not " unless reftype($x) eq 'ARRAY';
print "ok 6\n";

print "not " unless reftype(\*F) eq 'GLOB';
print "ok 7\n";
