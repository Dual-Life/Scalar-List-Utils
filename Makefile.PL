# -*- perl -*-
BEGIN { require 5.006; }
use strict;
use warnings;
use Config;
use File::Spec;
use ExtUtils::MakeMaker;

my $PERL_CORE = grep { $_ eq 'PERL_CORE=1' } @ARGV;
my $defines = $ENV{PERL_CORE} ? q[-DPERL_EXT] : q[-DPERL_EXT -DUSE_PPPORT_H];

# Determine the correct NV formatting required by uniqnum() in ListUtil.xs
# For this we need to determine which of the following 3 possible categories 
# describes perl's NV:
#  1) NV is either an 8-byte double or an 8-byte long double;
#  2) NV is an extended precision (10-byte) long double;
#  3) NV is something other than 1) or 2) ... which implies that it's either
#     a 16-byte IEEE long double, a 16-byte __float 128, or a 16-byte DoubleDouble.
# When we know that the case is 3) we also make the effort to single out the 
# DoubleDouble kind for separate treatment as it makes better sense to examine the
# byte structure of the value encapsulated in the DoubleDouble, rather than the
# the actual value itself.
#
# With perl-5.22 and later this could all be done by examining $Config{longdblkind}
# and $Config{nvtype} but we need to support earlier perl versions. We threfore
# sort it out by doing as follows - which appears to be somewhat ad-hoc, but does
# the job reliably:

my $nvbits;

if($Config{nvsize} == 8)   { $nvbits =  64 } # double or 8-byte long double

elsif(length(sqrt 2) > 25) {                 # IEEE long double or __float128 or DoubleDouble
  $nvbits =  128;

  # Define NV_IS_DOUBLEDOUBLE when appropriate
  if(1.0 + (2 ** -1000) != 1.0) { $defines .= " -DNV_IS_DOUBLEDOUBLE" }
}
 
else                       { $nvbits =  80  } # extended precision long double

$defines .= " -DLU_NV_BITS=$nvbits";

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
