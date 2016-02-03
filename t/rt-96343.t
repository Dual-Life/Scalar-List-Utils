#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use List::Util qw( first );

my $hash = {
  'HellO WorlD' => 1,
};

is( ( first { 'hello world' eq lc($_) } keys %$hash ), "HellO WorlD",
  'first (lc$_) perserves value' );

done_testing;
