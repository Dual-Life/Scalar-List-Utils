
use List::Util qw(forall);

print "1..4\n";

@a =  qw(H l W l);
@b =  qw(e o o d);
@c = (qw(l _ r),"\n");
@r = forall { $_[0] . $_[1] . $_[2] } \(@a,@b,@c);

print "not " unless join("",@a,@b,@c) eq "HlWleoodl_r\n";
print "ok 1\n";
print "#'",@r,"'\n";
print "not " unless join("",@r) eq "Hello_World\n";
print "ok 2\n";

forall { $_[0] .= $_[1] . $_[2] } \@a, \@b, \@c;
print @a;

print "not " unless join("",@a,@b,@c) eq "Hello_World\neoodl_r\n";
print "ok 3\n";

$l = forall { $_[0] *= ($_[1] || 0) } [1,2,3,7],[4,5,6];

print "not " unless $l == 4;
print "ok 4\n";
