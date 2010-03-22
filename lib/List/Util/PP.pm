# List::Util::PP.pm
#
# Copyright (c) 1997-2009 Graham Barr <gbarr@pobox.com>. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package List::Util::PP;

use strict;
use warnings;
require Exporter;

our @ISA     = qw(Exporter);
our @EXPORT  = qw(first min max minstr maxstr reduce sum shuffle);
our $VERSION = "1.23";
$VERSION = eval $VERSION;

sub reduce (&@) {
  my $code = shift;
  require Scalar::Util;
  my $type = Scalar::Util::reftype($code);
  unless($type and $type eq 'CODE') {
    require Carp;
    Carp::croak("Not a subroutine reference");
  }
  no strict 'refs';

  return shift unless @_ > 1;

  my $caller = caller;
  local(*{$caller."::a"}) = \my $a;
  local(*{$caller."::b"}) = \my $b;

  $a = shift;
  foreach (@_) {
    $b = $_;
    $a = &{$code}();
  }

  $a;
}

sub first (&@) {
  my $code = shift;
  require Scalar::Util;
  my $type = Scalar::Util::reftype($code);
  unless($type and $type eq 'CODE') {
    require Carp;
    Carp::croak("Not a subroutine reference");
  }

  foreach (@_) {
    return $_ if &{$code}();
  }

  undef;
}

our($a, $b);

sub sum (@) { reduce { $a + $b } @_ }

sub min (@) { reduce { $a < $b ? $a : $b } @_ }

sub max (@) { reduce { $a > $b ? $a : $b } @_ }

sub minstr (@) { reduce { $a lt $b ? $a : $b } @_ }

sub maxstr (@) { reduce { $a gt $b ? $a : $b } @_ }

sub shuffle (@) {
  my @a=\(@_);
  my $n;
  my $i=@_;
  map {
    $n = rand($i--);
    (${$a[$n]}, $a[$n] = $a[$i])[0];
  } @_;
}

1;
