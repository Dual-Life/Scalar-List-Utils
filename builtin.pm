# builtin.pm
#
# Copyright (c) 1997 Graham Barr <gbarr@pobox.com>. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package builtin;

use strict;
use DynaLoader ();
use Exporter ();
use vars qw(@ISA @EXPORT_OK $VERSION);

$VERSION = "0.03";
@ISA = qw(Exporter DynaLoader);
@EXPORT_OK = qw(
	blessed
	dualvar
	max
	maxstr
	min
	minstr
	reduce
	sum
	clock
	readonly
);

bootstrap builtin $VERSION;

1;

__END__

=head1 NAME

builtin - A selection of general-utility subroutines

=head1 SYNOPSIS

    use builtin qw(wanted_subroutines);

=head1 DESCRIPTION

C<builtin> contains a selection of subroutines that people have
expressed would be nice to have in the perl core, but the usage would
not really be high enough to warrant the use of a keyword, and the size
so small such that being individual extensions would be wasteful.

By default C<builtin> does not export any subroutines. The
subroutines defined are

=over 4

=item blessed EXPR

If EXPR evaluates to a blessed reference the name of the package
that it is blessed into is returned. Otherwise C<undef> is returned.

=item dualvar NUMERIC, STRING

Returns a new scalar variable which will act in a similar way to the
C<$!> variable. The value of this new variable will be the numerical
value of NUMERIC in a numeric context and the string value of STRING in
a string context.

    $foo = dualvar 10, "Hello";
    $num = $foo + 2;			# 12
    $str = $foo . " world";		# Hello world

=item max LIST

Returns the entry in the list with the highest numerical value. If the
list is empty then C<undef> is returned.

    $foo = max 1..10                # 10
    $foo = max 3,9,12               # 12
    $foo = max @bar, @baz           # whatever

This function could be implemented using C<reduce> like this

    $foo = reduce { $_[0] > $_[1] ? $_[0] : $_[1] } 1..10

=item maxstr LIST

Similar to C<max>, but treats all the entries in the list as strings
and returns the highest string as defined by the C<gt> operator.
If the list is empty then C<undef> is returned.
 
    $foo = maxstr 'A'..'Z'     	    # 'Z'
    $foo = maxstr "hello","world"   # "world"
    $foo = maxstr @bar, @baz        # whatever

This function could be implemented using C<reduce> like this

    $foo = reduce { $_[0] gt $_[1] ? $_[0] : $_[1] } 'A'..'Z'

=item min LIST

Similar to C<max> but returns the entry in the list with the lowest
numerical value. If the list is empty then C<undef> is returned.

    $foo = min 1..10                # 1
    $foo = min 3,9,12               # 3
    $foo = min @bar, @baz           # whatever

This function could be implemented using C<reduce> like this

    $foo = reduce { $_[0] < $_[1] ? $_[0] : $_[1] } 1..10

=item minstr LIST

Similar to C<min>, but treats all the entries in the list as strings
and returns the lowest string as defined by the C<lt> operator.
If the list is empty then C<undef> is returned.

    $foo = maxstr 'A'..'Z'     	    # 'A'
    $foo = maxstr "hello","world"   # "hello"
    $foo = maxstr @bar, @baz        # whatever

This function could be implemented using C<reduce> like this

    $foo = reduce { $_[0] lt $_[1] ? $_[0] : $_[1] } 'A'..'Z'

=item reduce BLOCK LIST

=item reduce SUBREF, LIST

Reduces LIST by calling BLOCK, or the sub referenced by SUBREF,
multiple times with two arguments. The first call will be with the
first two elements of the list, subsequent calls will be done by
passing the result of the previous call and the next element in the
list. 

Returns the result of the last call to BLOCK. If LIST is empty then
C<undef> is returned. If LIST only contains one element then that
element is returned and BLOCK is not executed.

    $foo = reduce { $_[0] < $_[1] ? $_[0] : $_[1] } 1..10       # min
    $foo = reduce { $_[0] lt $_[1] ? $_[0] : $_[1] } 'aa'..'zz' # minstr
    $foo = reduce { $_[0] + $_[1] } 1 .. 10                     # sum
    $foo = reduce { $_[0] . $_[1] } @bar                        # concat

=item sum LIST

Returns the sum of all the elements in LIST.

    $foo = sum 1..10                # 55
    $foo = sum 3,9,12               # 24
    $foo = sum @bar, @baz           # whatever

This function could be implemented using C<reduce> like this

    $foo = reduce { $_[0] + $_[1] } 1..10

=item clock

Returns the time in fractional seconds, to the resolution supplied by
the OS. This function is provided as a high resolution replacement for
perl's built-in C<time> function, see L<perlfunc/time>.

=item readonly SCALAR

Returns a true value is a read-only variable. This is useful in
subroutines that want to modify the arguments, but need to check first
if a constant was passed.

=back

=head1 NOTE

It should be noted that this module is not intended to be a
I<bit bucket> for any sub that some person thinks might be useful.
Some general guidelines are to consider if a particular sub should
be included in C<builtin> are

The sub is of general use B<and> cannot be implemented in perl.

or

The sub is very commonly used B<and> needs fast implementation in C.

=head1 COPYRIGHT

Copyright (c) 1997 Graham Barr <gbarr@pobox.com>. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
