# Scalar::DualVar.pm
#
# Copyright (c) 1997-1999 Graham Barr <gbarr@pobox.com>. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package Scalar::DualVar;

use DynaLoader ();
use Exporter ();

$VERSION = "0.10";
@ISA = qw(Exporter DynaLoader);
@EXPORT = qw(dualvar);

bootstrap Scalar::DualVar $VERSION;

1;

__END__

=head1 NAME

Scalar::DualVar - Create dual type variables

=head1 SYNOPSIS

    use Scalar::DualVar qw(dualvar);
    
    $foo = dualvar 10, "Hello";
    $num = $foo + 2;			# 12
    $str = $foo . " world";		# Hello world

=head1 DESCRIPTION

C<Scalar::DualVar> exports one function c<dualvar> which allows the caller
to create a variable that has different numeric and string values.

=head1 COPYRIGHT

Copyright (c) 1997-1999 Graham Barr <gbarr@pobox.com>. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
