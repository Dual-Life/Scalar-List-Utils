# -*- perl -*-

use inc::Module::Install;

my $do_xs = can_cc();

for (@ARGV) {
  /^-pm/ and $do_xs = 0;
  /^-xs/ and $do_xs = 1;
}

name		('Scalar-List-Utils');
module_name	('List::Util');
abstract	('Common Scalar and List utility subroutines');
author		('Graham Barr <gbarr@cpan.org>');
version_from	('lib/List/Util.pm');
license		('perl');

makemaker_args	( XS => {}, C => []) unless $do_xs;
makemaker_args	( DEFINE      => "-DPERL_EXT",);

installdirs	(qw(Scalar::Util List::Util));

check_nmake();      # check and download nmake.exe for Win32

requires( perl => 5.004);
include_deps('Test::More');

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

mydist : manifest run_cpansign dist

run_cpansign :
	cpansign -s

POSTAMBLE

}

