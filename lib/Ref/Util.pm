# Ref::Util.pm
#
# Copyright (c) 1997-1999 Graham Barr <gbarr@pobox.com>. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package Ref::Util;
# DualVar loads the XS
require Scalar::DualVar;
require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw(blessed reftype weaken isweak);
$VERSION = $Scalar::DualVar::VERSION;

sub export_fail {
  if (grep { /^(weaken|isweak)$/ } @_ ) {
    require Carp;
    Carp::croak("Weak references are not implemented in the version of perl");
  }
  @_;
}

1;
__END__

=head1 NAME

Ref::Util - A selection of general-utility reference subroutines

=head1 SYNOPSIS

    use Ref::Util qw(blessed rftype weaken isweak);

=head1 DESCRIPTION

C<Ref::Util> contains a selection of subroutines that people have
expressed would be nice to have in the perl core, but the usage would
not really be high enough to warrant the use of a keyword, and the size
so small such that being individual extensions would be wasteful.

By default C<Ref::Util> does not export any subroutines. The
subroutines defined are

=over 4

=item blessed EXPR

If EXPR evaluates to a blessed reference the name of the package
that it is blessed into is returned. Otherwise C<undef> is returned.

=item isweak EXPR

If EXPR is a scalar which is a weak reference the 
=item reftype EXPR

If EXPR evaluates to a reference the type of the variable referenced
is returned. Otherwise C<undef> is returned.

=item weaken EXPR

=back

=head1 NOTE

It should be noted that this module is not intended to be a
I<bit bucket> for any sub that some person thinks might be useful.
Some general guidelines are to consider if a particular sub should
be included in C<Ref::Util> are

The sub is of general use B<and> cannot be implemented in perl.

or

The sub is very commonly used B<and> needs fast implementation in C.

=head1 COPYRIGHT

Copyright (c) 1997-1999 Graham Barr <gbarr@pobox.com>. All rights reserved.
This program is free software; you can redistribute it and/or modify it 
under the same terms as Perl itself.

except weaken and isweak which are

Copyright (c) 1999 Tuomas J. Lukka <lukka@iki.fi>. All rights reserved.
This program is free software; you can redistribute it and/or modify it
under the same terms as perl itself.

=head1 BLATANT PLUG

The weanen and isweak subroutines in this module and the patch to the core Perl
were written in connection  with the APress book `Tuomas J. Lukka's Definitive
Guide to Object-Oriented Programming in Perl', to avoid explaining why certain
things would have to be done in cumbersome ways.

=cut
