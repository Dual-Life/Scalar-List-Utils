
use builtin qw(clock);

print "1..2\n";


print "not " if clock < 0;
print "ok 1\n";

print "not " if clock - time > 1.0; # be generous
print "ok 2\n";
