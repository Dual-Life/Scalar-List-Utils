# Scalar::Util::PP.pm
#
# Copyright (c) 1997-2009 Graham Barr <gbarr@pobox.com>. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#
# This module is normally only loaded if the XS module is not available

package Scalar::Util::PP;

use strict;
use warnings;
use vars qw(@ISA @EXPORT $VERSION $recurse);
require Exporter;

@ISA     = qw(Exporter);
@EXPORT  = qw(blessed reftype tainted readonly refaddr looks_like_number);
$VERSION = "1.20";
$VERSION = eval $VERSION;

sub blessed ($) {
  local($@, $SIG{__DIE__}, $SIG{__WARN__});
  return ref($_[0]) if $recurse;
  local $recurse = 1; # protect against recursion if user has used UNIVERSAL::can from CPAN
  length(ref($_[0]))
    ? eval { $_[0]->UNIVERSAL::can('can') && ref($_[0]) }
    : undef;
}

sub refaddr($) {
  return undef unless length(ref($_[0]));

  my $addr;
  if(defined(my $pkg = blessed($_[0]))) {
    $addr .= bless $_[0], 'Scalar::Util::Fake';
    bless $_[0], $pkg;
  }
  else {
    $addr .= $_[0]
  }

  $addr =~ /0x(\w+)/;
  local $^W;
  hex($1);
}

sub reftype ($) {
  local($@, $SIG{__DIE__}, $SIG{__WARN__});
  my $r = shift;
  my $t;

  length($t = ref($r)) or return undef;

  # This eval will fail if the reference is not blessed
  eval { $r->UNIVERSAL::can('can') }
    ? do {
      $t = eval {
	  # we have a GLOB or an IO. Stringify a GLOB gives it's name
	  my $q = *$r;
	  (defined($q) && $q =~ /^\*/) ? "GLOB" : "IO";
	}
	or do {
	  # OK, if we don't have a GLOB what parts of
	  # a glob will it populate.
	  # NOTE: A glob always has a SCALAR
	  local *glob = $r;
	  defined *glob{ARRAY} && "ARRAY"
	  or defined *glob{HASH} && "HASH"
	  or defined *glob{CODE} && "CODE"
	  or length(ref(${$r})) ? "REF" : "SCALAR";
	}
    }
    : $t
}

sub tainted {
  local($@, $SIG{__DIE__}, $SIG{__WARN__});
  local $^W = 0;
  no warnings;
  eval { kill 0 * $_[0] };
  $@ =~ /^Insecure/;
}

sub readonly {
  return 0 if tied($_[0]) || (ref(\($_[0])) ne "SCALAR");

  local($@, $SIG{__DIE__}, $SIG{__WARN__});
  my $tmp = $_[0];

  !eval { $_[0] = $tmp; 1 };
}

sub looks_like_number {
  local $_ = shift;

  # checks from perlfaq4
  return 0 if !defined($_);
  if (ref($_)) {
    require overload;
    return overload::Overloaded($_) ? defined(0 + $_) : 0;
  }
  return 1 if (/^[+-]?\d+$/); # is a +/- integer
  return 1 if (/^([+-]?)(?=\d|\.\d)\d*(\.\d*)?([Ee]([+-]?\d+))?$/); # a C float
  return 1 if ($] >= 5.008 and /^(Inf(inity)?|NaN)$/i) or ($] >= 5.006001 and /^Inf$/i);

  0;
}


1;
