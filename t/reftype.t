

use Scalar::Util qw(reftype);
use vars qw($t $y $x *F);

@test = (
 [ undef, 1],
 [ undef, 'A'],
 [ HASH => {} ],
 [ ARRAY => [] ],
 [ SCALAR => \$t ],
 [ REF    => \(\$t) ],
 [ GLOB   => \*F ]
);

print "1..", @test*3, "\n";

my $i = 1;
foreach $test (@test) {
  my($type,$what) = @$test;
  my $pack;
  foreach $pack (undef,"ABC","0") {
    my $res = reftype($what);
    printf "# %s - %s\n", map { defined($_) ? $_ : 'undef' } $type,$res;
    print "not " if $type ? $res ne $type : defined($res);
    bless $what, $pack if $type && $pack;
    print "ok ",$i++,"\n";
  }
}
