# -*- perl -*-

use inc::Module::Install;

my $do_xs = can_cc();

for (@ARGV) {
  /^-pm/ and $do_xs = 0;
  /^-xs/ and $do_xs = 1;
}

perl_version    5.006001;
name		('Scalar-List-Utils');
module_name	('List::Util');
abstract	('Common Scalar and List utility subroutines');
author		('Graham Barr <gbarr@cpan.org>');
version_from	('lib/List/Util.pm');
license		('perl');
repository      ('http://git.goingon.net/?p=Scalar-List-Utils.git;a=summary');

makemaker_args	( XS => {}, C => []) unless $do_xs;
makemaker_args	( DEFINE      => "-DPERL_EXT",);
makemaker_args	( PL_FILES => { 'xs_version.PL' => '__FORCE__' });

installdirs	('perl');

check_nmake();      # check and download nmake.exe for Win32

include_deps('Test::More');

&Makefile->write;
&Meta->write;

## - - - - - - - -

sub MY::post_constants {
  return '' if $] >= 5.006_01;

  return <<'POST_CONST' if $^O eq 'MSWin32';

XSUBPPARGS = $(XSUBPPARGS) -typemap mytypemap

POST_CONST

  return <<'POST_CONST';

XSUBPPARGS +=  -typemap mytypemap

POST_CONST

}

