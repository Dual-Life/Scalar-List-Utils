#!./perl

BEGIN {
    unless (-d 'blib') {
	chdir 't' if -d 't';
	@INC = '../lib';
	require Config; import Config;
	keys %Config; # Silence warning
	if ($Config{extensions} !~ /\bList\/Util\b/) {
	    print "1..0 # Skip: List::Util was not built\n";
	    exit 0;
	}
    }
}

use vars qw($skip);

BEGIN {
  require Scalar::Util;

  if (grep { /dualvar/ } @Scalar::Util::EXPORT_FAIL) {
    print "1..0\n";
    $skip=1;
  }
}

eval <<'EOT' unless $skip;
use Scalar::Util qw(dualvar);

print "1..6\n";

$var = dualvar 2.2,"string";

print "not " unless $var == 2.2;
print "ok 1\n";

print "not " unless $var eq "string";
print "ok 2\n";

$var2 = $var;

$var++;

print "not " unless $var == 3.2;
print "ok 3\n";

print "not " unless $var ne "string";
print "ok 4\n";

print "not " unless $var2 == 2.2;
print "ok 5\n";

print "not " unless $var2 eq "string";
print "ok 6\n";

EOT
