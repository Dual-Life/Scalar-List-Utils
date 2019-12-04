# -*- perl -*-
BEGIN { require 5.006; }
use strict;
use warnings;
use Config;
use File::Spec;
use ExtUtils::MakeMaker;
my $PERL_CORE = grep { $_ eq 'PERL_CORE=1' } @ARGV;
my $defines = $ENV{PERL_CORE} ? q[-DPERL_EXT] : q[-DPERL_EXT -DUSE_PPPORT_H];

# Firstly, assign to $nv_digits the no. of decimal digits that the formatting
# of perl's type of NV requires. Then define that value to NV_MAX_PRECISION.
# The value of $nv_digits is also used to identify the correct key in %used_bytes.
# The value of that key is the byte size (in actual bytes used) of perl's NV type.
# That value is then defined to USED_NV_BYTES.

my %digits     = ('double' => 19, 'long double' => 21, '__float128' => 36);
my %used_bytes = ('19'     => 8,  '21'          => 10, '36'         => 16);

my $nv_digits = $digits{$Config{nvtype}}; # might be altered below if nvtype is 'long double'.

# If nvtype is 'long double, determine what kind of 'long double' it is,
# and modify the value of $nv_digits if appropriate.

if($Config{nvtype} eq 'long double') {
  if (1.0 + (2 ** -1000) != 1.0)  {
    $defines .= " -DNV_IS_DOUBLEDOUBLE";
    $nv_digits = $digits{__float128}; # Not used for the doubledouble, except to
                                      # identify the correct value in %used_bytes 
 }
  elsif ($Config{nvsize} == 8)      { $nv_digits = $digits{double}      }
  elsif (length(sqrt(2.0)) > 30)    { $nv_digits = $digits{__float128}  } #IEEE 754 long double
}

$defines .= " -DNV_MAX_PRECISION=$nv_digits -DUSED_NV_BYTES=$used_bytes{$nv_digits}";

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
