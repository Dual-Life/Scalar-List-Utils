#line 1
# Copyright (c) 2003 Graham Barr <gbarr@pobox.com>. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package Module::Install::InstallDirs;
use Module::Install::Base; @ISA = qw(Module::Install::Base);
use Config;

$VERSION = '0.01';
use strict;

sub installdirs {
  my $self = shift;
  my @dirs = ($Config{privlib},$Config{archlib});
  foreach my $module (@_) {
    (my $path = "$module.pm") =~ s,::,/,g;
    foreach my $dir (@dirs) {
      if (-f "$dir/$path") {
	$self->makemaker_args(INSTALLDIRS => 'perl');
	return;
      }
    }
  }
}

1;

__END__

#line 57
