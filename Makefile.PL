# -*- perl -*-
BEGIN { require 5.006; }
use strict;
use warnings;
use Config;
use File::Spec;
use ExtUtils::MakeMaker;
my $PERL_CORE = grep { $_ eq 'PERL_CORE=1' } @ARGV;
my $defines = $ENV{PERL_CORE} ? q[-DPERL_EXT] : q[-DPERL_EXT -DUSE_PPPORT_H];

# For uniqnum() we distinguish between those builds for which
# $Config{nvsize} == $Config{ivsize} and those builds for which
# $Config{nvsize} != $Config{ivsize}
# Hence:

$defines .= " -DNVSIZE_EQUAL_IVSIZE"
  if $Config{nvsize} == $Config{ivsize};

# For uniqnum(), set $nvsize to be the size of the NV in bytes,
# excluding allocated but unused bytes.
# This will be the same as $Config{nvsize}, except for the 10-byte
# extended precision long double (for which $Config{nvsize} will report
# either 12 or 16):

my $nvsize = $Config{nvsize};

# Keep in mind that 8-byte long doubles exist - for which
# $nvsize should remain at 8:

if($nvsize > 8 && $Config{nvtype} eq 'long double') {
  # Examine the length of sqrt 2.0 to determine whether we
  # have the extended precision 10-byte long double.
  # If so, amend $nvsize to 10.
  $nvsize = 10 if length sqrt 2.0 < 30;
}

# Now define USED_NV_BYTES (which is used by uniqnum) to the
# value of $nvsize

$defines .= " -DUSED_NV_BYTES=$nvsize";

print "DEFINES: $defines\n";

WriteMakefile(
  NAME         => q[List::Util],
  ABSTRACT     => q[Common Scalar and List utility subroutines],
  AUTHOR       => q[Graham Barr <gbarr@cpan.org>],
  DEFINE       => $defines,
  DISTNAME     => q[Scalar-List-Utils],
  VERSION_FROM => 'lib/List/Util.pm',

  # We go through the ListUtil.xs trickery to foil platforms
  # that have the feature combination of
  # (1) static builds
  # (2) allowing only one object by the same name in the static library
  # (3) the object name matching being case-blind
  # This means that we can't have the top-level util.o
  # and the extension-level Util.o in the same build.
  # One such platform is the POSIX-BC BS2000 EBCDIC mainframe platform.
  XS     => {'ListUtil.xs' => 'ListUtil.c'},
  OBJECT => 'ListUtil$(OBJ_EXT)',
  ( $PERL_CORE
    ? ()
    : (
      INSTALLDIRS      => ($] < 5.011 ? q[perl] : q[site]),
      PREREQ_PM        => {'Test::More' => 0,},
      (eval { ExtUtils::MakeMaker->VERSION(6.31) } ? (LICENSE => 'perl') : ()),
      (eval { ExtUtils::MakeMaker->VERSION(6.48) } ? (MIN_PERL_VERSION => '5.006') : ()),
      ( eval { ExtUtils::MakeMaker->VERSION(6.46) } ? (
          META_MERGE => {
            'meta-spec' => { version => 2 },
            dynamic_config => 0,
            resources => {    ##
              repository => {
                url => 'https://github.com/Scalar-List-Utils/Scalar-List-Utils.git',
                web => 'https://github.com/Scalar-List-Utils/Scalar-List-Utils',
                type => 'git',
              },
              bugtracker => {
                mailto => 'bug-Scalar-List-Utils@rt.cpan.org',
                web => 'https://rt.cpan.org/Public/Dist/Display.html?Name=Scalar-List-Utils',
              },
            },
          }
          )
        : ()
      ),
    )
  ),
);
