
use builtin qw(readonly);

print "1..7\n";

my $a = "a";

print "not " if readonly($a);
print "ok 1\n";

print "not " unless readonly(1);
print "ok 2\n";

print "not " unless readonly("d");
print "ok 3\n";

print "not " unless readonly(undef);
print "ok 4\n";

print "not " unless readonly(readonly(undef));
print "ok 5\n";

print "not " unless readonly(readonly($a));
print "ok 6\n";

print "not " if readonly(\$a);
print "ok 7\n";
