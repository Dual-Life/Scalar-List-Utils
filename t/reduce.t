

use builtin qw(reduce min);

print "1..5\n";

print "not " if defined reduce {};
print "ok 1\n";

print "not " unless 9 == reduce { $_[0] / $_[1] } 756,3,7,4;
print "ok 2\n";

print "not " unless 9 == reduce { $_[0] / $_[1] } 9;
print "ok 3\n";

@a = map { rand } 0 .. 20;
print "not " unless min(@a) == reduce { $_[0] < $_[1] ? $_[0] : $_[1] } @a;
print "ok 4\n";

@a = map { pack("C", int(rand(256))) } 0 .. 20;
print "not " unless join("",@a) eq reduce { $_[0] . $_[1] } @a;
print "ok 5\n";
