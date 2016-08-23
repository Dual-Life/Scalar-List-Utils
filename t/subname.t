use strict;
use warnings;

BEGIN { $^P |= 0x210 }

use Test::More tests => 19;

use B::Deparse;
use Sub::Util qw( subname set_subname );

{
  sub localfunc {}
  sub fully::qualified::func {}

  is(subname(\&subname), "Sub::Util::subname",
    'subname of \&subname');
  is(subname(\&localfunc), "main::localfunc",
    'subname of \&localfunc');
  is(subname(\&fully::qualified::func), "fully::qualified::func",
    'subname of \&fully::qualfied::func');

  # Because of the $^P debug flag, we'll get [file:line] as well
  like(subname(sub {}), qr/^main::__ANON__\[.+:\d+\]$/, 'subname of anon sub');

  ok(!eval { subname([]) }, 'subname [] dies');
}

my $x = set_subname foo => sub { (caller 0)[3] };
my $line = __LINE__ - 1;
my $file = __FILE__;
my $anon = $DB::sub{"main::__ANON__[${file}:${line}]"};

is($x->(), "main::foo");

{
  package Blork;

  use Sub::Util qw( set_subname );

  set_subname " Bar!", $x;
  ::is($x->(), "Blork:: Bar!");

  set_subname "Foo::Bar::Baz", $x;
  ::is($x->(), "Foo::Bar::Baz");

  set_subname "set_subname (dynamic $_)", \&set_subname  for 1 .. 3;

  for (4 .. 5) {
      set_subname "Dynamic $_", $x;
      ::is($x->(), "Blork::Dynamic $_");
  }

  ::is($DB::sub{"main::foo"}, $anon);

  for (4 .. 5) {
      ::is($DB::sub{"Blork::Dynamic $_"}, $anon);
  }

  for ("Blork:: Bar!", "Foo::Bar::Baz") {
      ::is($DB::sub{$_}, $anon);
  }
}

# RT42725
{
  my $source = eval {
      B::Deparse->new->coderef2text(set_subname foo => sub{ @_ });
  };

  ok !$@;

  like $source, qr/\@\_/;
}

# subname of set_subname
{
  is(subname(set_subname "my-scary-name-here", sub {}), "main::my-scary-name-here",
    'subname of set_subname');
}

# RT116961
{
  {
    package Blarf;
    sub gorp { 1 }
  }
  my $sub = \&Blarf::gorp;
  delete $::{'Blarf::'};
  my $package = "$]" < 5.010 ? 'Blarf' : '__ANON__';
  my $subname = "$]" < 5.012 || "$]" >= 5.014 ? 'gorp' : '__ANON__';
  is subname($sub), $package.'::'.$subname,
    'subname works when stash deleted';
}

# vim: ft=perl
