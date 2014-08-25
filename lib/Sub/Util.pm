# Copyright (c) 2014 Paul Evans <leonerd@leonerd.org.uk>. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package Sub::Util;

use strict;
use warnings;

require Exporter;
require List::Util; # as it has the XS

our @ISA = qw( Exporter );
our @EXPORT_OK = qw(
  subname set_subname
);

our $VERSION    = "1.39_001";
$VERSION   = eval $VERSION;

=head1 NAME

Sub::Util - A selection of utility subroutines for subs and CODE references

=head1 SYNOPSIS

    use Sub::Util qw( subname set_subname );

=head1 DESCRIPTION

C<Sub::Util> contains a selection of utility subroutines that are useful for
operating on subs and CODE references.

The rationale for inclusion in this module is that the function performs some
work for which an XS implementation is essential because it cannot be
implemented in Pure Perl, and which is sufficiently-widely used across CPAN
that its popularity warrants inclusion in a core module, which this is.

=cut

=head1 FUNCTIONS

=cut

=head2 $name = subname( $code )

I<Since version 1.39_002.>

Returns the name of the given C<$code> reference, if it has one. Normal named
subs will give a fully-qualified name consisting of the package and the
localname separated by C<::>. Anonymous code references will give C<__ANON__>
as the localname. If a name has been set using C<set_subname>, this name will
be returned instead.

This function was inspired by C<sub_fullname> from L<Sub::Identify>. The
remaining functions that C<Sub::Identify> implements can easily be emulated
using regexp operations, such as

 sub get_code_info { return (subname $_[0]) =~ m/^(.+)::(.+?)$/ }
 sub sub_name      { return (get_code_info $_[0])[0] }
 sub stash_name    { return (get_code_info $_[0])[1] }

=cut

=head2 $code = set_subname( $name, $code )

I<Since version 1.39_002.>

Sets the name of the function given by the C<$code> reference. Returns the
C<$code> reference itself. If the C<$name> is unqualified, the package of the
caller is used to qualify it.

    my $code = set_subname do_thing => sub { ... };

This is useful for applying names to anonymous CODE references so that stack
traces and similar situations, to give a useful name rather than having the
default of C<__ANON__>. Note that this name is only used for this situation;
the C<set_subname> will not install it into the symbol table; you will have to
do that yourself if required.

However, since the name is not used by perl except as the return value of
C<caller>, for stack traces or similar, there is no actual requirement that
the name be syntactically valid as a perl function name. This could be used to
attach extra information that could be useful in debugging stack traces.

This function was copied from C<Sub::Name::subname> and renamed to the naming
convention of this module.

=cut

=head1 AUTHOR

The general structure of this module was written by Paul Evans
<leonerd@leonerd.org.uk>.

The XS implementation of C<set_subname> was copied from L<Sub::Name> by
Matthijs van Duin <xmath@cpan.org>

=cut

1;
