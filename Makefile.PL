# -*- perl -*-

use inc::Module::Install;

my $do_xs = can_cc();

for (@ARGV) {
  /^-pm/ and $do_xs = 0;
  /^-xs/ and $do_xs = 1;
}

name		('Scalar-List-Util');
abstract	('Common Scalar and List utility subroutines');
author		('Graham Barr <gbarr@cpan.org>');
version_from	('lib/List/Util.pm');
license		('perl');

makemaker_args	( XS => {}, C => []) unless $do_xs;
makemaker_args	( DEFINE      => "-DPERL_EXT",);

installdirs	(qw(Scalar::Util List::Util));

check_nmake();      # check and download nmake.exe for Win32

&Makefile->write;
&Meta->write;

## - - - - - - - -

sub MY::post_constants {
  return '' if $] >= 5.006_01;

  return <<'POST_CONST';

XSUBPP_EXTRA_ARGS = -typemap mytypemap

POST_CONST

}

sub MY::postamble {
  return <<'POSTAMBLE';

distdir : manifest run_cpansign

run_cpansign :
	cpansign -s

POSTAMBLE

}

