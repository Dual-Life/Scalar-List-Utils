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
#  1) NV is either an 8-byte double or an 8-byte long double.
#     In this case '"%.19" NVgf' formatting is required.
#  2) NV is an extended precision (10-byte) long double.
#     In this case '"%.21" NVgf' formatting is required.
#  3) NV is something other than 1) or 2) ... which implies that it's either
#     a 16-byte IEEE long double, a 16-byte __float128, or a 16-byte DoubleDouble.
#     In this category, '"%.36" NVgf' formatting is required, except for
#     DoubleDouble - for which we take a different approach.
#
# With perl-5.22 and later, we could determine the category by examining
# $Config{longdblkind} and $Config{nvtype} but we need to support earlier perl
# versions. We therefore sort it all out by doing as below - which appears to be
# somewhat ad-hoc, but does the job reliably.
#
# Ideally that would be all that's needed, but there are odd quirks and
# configurations that prevent it from working universally.
#
# For category 1) && $Config{ivsize} == 8 && the OS is MSWindows
# we need to check that (s)printf "%.19g" formatting works as expected at the
# C level.
# According to my testing, it doesn't work as expected on Windows if the perl
# version is less than 5.26.0. And it also doesn't work there with 5.26.0 and
# later unless perl was built with -D__USE_MINGW_ANSI_STDIO.
# When it fails, we define FALLBACK_TO_BYTES, and have uniqnum() look at the byte
# structures on the NVs, rather than the actual values.
#
# For category 3) we also make the effort to single out the DoubleDouble kind for
# separate treatment( by defining NV_IS_DOUBLEDOUBLE) as it makes better sense
# to examine the byte structure of the value encapsulated in the DoubleDouble,
# rather than the the actual value itself.
# We could use this same approach for all long double and __float128 builds,
# though we would then need to cater for differing nvsizes (which could easily be
# handled by C pre-processing). However, I don't know that doing so would
# constitute an improvement. 
#
# Sisyphus.

my $nvbits;

if($Config{nvsize} == 8)   {                 # double or 8-byte long double
  $nvbits =  64;

  if($Config{ivsize} == 8 && $^O =~ /MSWin/) {
 
    if($] < 5.026 || sprintf("%.0f", 2 ** 64) =~ /0$/) {
      $defines .= " -DFALLBACK_TO_BYTES";
    }
  }
}

elsif(length(sqrt 2) > 25) {                 # IEEE long double or __float128 or DoubleDouble
  $nvbits =  128;

  # Define NV_IS_DOUBLEDOUBLE when appropriate
  if(1.0 + (2 ** -1000) != 1.0) { $defines .= " -DNV_IS_DOUBLEDOUBLE" }
}
 
else                       { $nvbits =  80  } # extended precision long double

$defines .= " -DLU_NV_BITS=$nvbits";

print "FYI: Makefile.PL defines $defines\n";

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
