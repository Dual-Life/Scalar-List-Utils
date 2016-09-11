#!./perl

warnings->unimport('experimental::lexical_topic')
  unless $Config{usecperl};
my $_ = 1;
$v = first { $_ > 6 } 2,4,6,12;
is($v, 12, 'first with lexical my');
