# List::Util.pm
#
# Copyright (c) 1997-1999 Graham Barr <gbarr@pobox.com>. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package List::Util;
# DualVar loads the XS
require Scalar::DualVar;
require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw(min max minstr maxstr reduce sum forall);
$VERSION = $Scalar::DualVar::VERSION;

1;
__END__

=head1 NAME

List::Util - A selection of general-utility list subroutines

=head1 SYNOPSIS

    use List::Util qw(sum min max minstr maxstr reduce);

=head1 DESCRIPTION

C<List::Util> contains a selection of subroutines that people have
expressed would be nice to have in the perl core, but the usage would
not really be high enough to warrant the use of a keyword, and the size
so small such that being individual extensions would be wasteful.

By default C<List::Util> does not export any subroutines. The
subroutines defined are

=over 4

=item forall BLOCK LIST

LIST must be a list of array references. BLOCK will be called N times
when N is the length of the longet array. Each time the elements of
C<@_> will be aliases to an element from each of the arrays.

If the elements of C<@_> are modified then the input arrays will be modified.
If called in an array context the results of the block evaluations will be
returned. In a scalar context returns the number of elements in the largest
array.

    @a =  qw(H l W l);
    @b =  qw(e o o d);
    @c = (qw(l _ r),"\n");
    @r = forall { $_[0] . $_[1] . $_[2] } \(@a,@b,@c);
    print @r;
    # Hello_World

    forall { $_[0] .= $_[1] . $_[2] } \@a, \@b, \@c;
    print @a;
    # Hello_World

    $l = forall { $_[0] *= $_[1] } [1,2,3],[4,5,6,7];
    print $l,"\n";
    # 4
    
=item max LIST

Returns the entry in the list with the highest numerical value. If the
list is empty then C<undef> is returned.

    $foo = max 1..10                # 10
    $foo = max 3,9,12               # 12
    $foo = max @bar, @baz           # whatever

This function could be implemented using C<reduce> like this

    $foo = reduce { $a > $b ? $a : $b } 1..10

=item maxstr LIST

Similar to C<max>, but treats all the entries in the list as strings
and returns the highest string as defined by the C<gt> operator.
If the list is empty then C<undef> is returned.
 
    $foo = maxstr 'A'..'Z'     	    # 'Z'
    $foo = maxstr "hello","world"   # "world"
    $foo = maxstr @bar, @baz        # whatever

This function could be implemented using C<reduce> like this

    $foo = reduce { $a gt $b ? $a : $b } 'A'..'Z'

=item min LIST

Similar to C<max> but returns the entry in the list with the lowest
numerical value. If the list is empty then C<undef> is returned.

    $foo = min 1..10                # 1
    $foo = min 3,9,12               # 3
    $foo = min @bar, @baz           # whatever

This function could be implemented using C<reduce> like this

    $foo = reduce { $a < $b ? $a : $b } 1..10

=item minstr LIST

Similar to C<min>, but treats all the entries in the list as strings
and returns the lowest string as defined by the C<lt> operator.
If the list is empty then C<undef> is returned.

    $foo = maxstr 'A'..'Z'     	    # 'A'
    $foo = maxstr "hello","world"   # "hello"
    $foo = maxstr @bar, @baz        # whatever

This function could be implemented using C<reduce> like this

    $foo = reduce { $a lt $b ? $a : $b } 'A'..'Z'

=item reduce BLOCK LIST

Reduces LIST by calling BLOCK, or the sub referenced by SUBREF,
multiple times with two arguments. The first call will be with the
first two elements of the list, subsequent calls will be done by
passing the result of the previous call and the next element in the
list. 

Returns the result of the last call to BLOCK. If LIST is empty then
C<undef> is returned. If LIST only contains one element then that
element is returned and BLOCK is not executed.

    $foo = reduce { $a < $b ? $a : $b } 1..10       # min
    $foo = reduce { $a lt $b ? $a : $b } 'aa'..'zz' # minstr
    $foo = reduce { $a + $b } 1 .. 10                     # sum
    $foo = reduce { $a . $b } @bar                        # concat


=item sum LIST

Returns the sum of all the elements in LIST.

    $foo = sum 1..10                # 55
    $foo = sum 3,9,12               # 24
    $foo = sum @bar, @baz           # whatever

This function could be implemented using C<reduce> like this

    $foo = reduce { $a + $b } 1..10

=back

=head1 NOTE

It should be noted that this module is not intended to be a
I<bit bucket> for any sub that some person thinks might be useful.
Some general guidelines are to consider if a particular sub should
be included in C<List::Util> are

The sub is of general use B<and> cannot be implemented in perl.

or

The sub is very commonly used B<and> needs fast implementation in C.

=head1 COPYRIGHT

Copyright (c) 1997-1999 Graham Barr <gbarr@pobox.com>. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
