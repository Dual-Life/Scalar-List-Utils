#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 2;

TODO: { SKIP: {
  skip "5.6", 1 if $] < 5.008;
  local $TODO = "RT #96343 with 5.20/5.22" if $] >= 5.019008 && $] < 5.023;
  use List::Util qw( first );

  my $hash = {
    'HellO WorlD' => 1,
  };

  # TODO: this fails with 5.20 and 5.22
  is( ( first { 'hello world' eq lc($_) } keys %$hash ), "HellO WorlD",
    'first (lc$_) perserves value' );
}}

{
  use List::Util qw( any );

  my $hash = {
    'HellO WorlD' => 1,
  };

  my $var;

  no warnings 'void';
  any { lc($_); $var = $_; } keys %$hash;

  is( $var, 'HellO WorlD',
    'any (lc$_) leaves value undisturbed' );
}
