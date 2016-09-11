#!./perl

warnings->unimport('experimental::lexical_topic')
    unless $Config{usecperl};
my $_ = "foo";
ok( any { $_ eq "a" } qw(a b c), 'any my $_');
