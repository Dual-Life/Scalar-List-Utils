#!perl

use strict;
use warnings;
use Test::More tests => 28;

use Sub::Util '__SUB__';

# basic.t

sub davros { __SUB__ }
is(davros(), \&davros, 'davros');

sub borusa {
    my $coderef = __SUB__;
    is($coderef, \&borusa, 'borusa');
}
borusa();

sub romana {
    @_ = (__SUB__, \&romana, 'romana');
    &is;
}
romana();

sub rassilon {
    is(__SUB__, \&rassilon, 'rassilon');
}
rassilon();

# specialblocks.t

BEGIN { ok( defined __SUB__, "Don't point to BEGIN" ); }
CHECK { ok( defined __SUB__, "Don't point to CHECK" ); }
INIT  { ok( defined __SUB__, "Don't point to INIT" ); }
END   { ok( defined __SUB__, "Don't point to END" ); }

# autoload.t

sub AUTOLOAD {
    is(__SUB__, \&AUTOLOAD, "AUTOLOAD $::AUTOLOAD");
}
sarah_jane();
leela();
sarah_jane(); # again

# main.t

ok( !defined __SUB__, "Don't point to main CV" );

# prototype.t

# polyfill prototype must be ''
ok( defined prototype \&Sub::Util::ROUTINE, 'proto defined' );
is( prototype \&Sub::Util::ROUTINE, '', 'proto empty' );

# and this should compile
sub skaro { __SUB__ }
is(skaro(), \&skaro, 'skaro');

# eval.t

sub runcible {
    is(eval { __SUB__ }, \&runcible, "runcible");
}
runcible();

sub omega {
    # eval("") is a special block context
    ok(!defined eval q{ __SUB__ }, "omega");
}
omega();

sub master {
    is(do { __SUB__ }, \&master, "master");
}
master();

# recurse.t

our $i = 0;
sub recurse {
    if ($i++ < 4) {
        ok(1, "test i$i");
        __SUB__->();
    }
}
recurse();

sub recurse2 {
    my $j = shift;
    if ($j > 0) {
        ok(1, "test j$j");
        __SUB__->($j - 1);
    }
}
recurse2(4);

# anon.t

my $anon;
$anon = sub {
    is(__SUB__, $anon, "anon sub");
};
$anon->();
my $copy = $anon;
$copy->();

