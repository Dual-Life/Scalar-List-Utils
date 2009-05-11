# -*- perl -*-
BEGIN { require 5.008; } # allow CPAN testers to get the point
use strict;
use warnings;
use Config;
use File::Spec;
use ExtUtils::MakeMaker;

my $do_xs = can_cc();

for (@ARGV) {
  /^-pm/ and $do_xs = 0;
  /^-xs/ and $do_xs = 1;
}

WriteMakefile(
    ABSTRACT     => q[Common Scalar and List utility subroutines],
    AUTHOR       => q[Graham Barr <gbarr@cpan.org>],
    DEFINE       => q[-DPERL_EXT],
    DISTNAME     => q[Scalar-List-Utils],
    INSTALLDIRS  => q[perl],
    NAME         => q[List::Util],
    PREREQ_PM    => {
      'Test::More' => 0,
    },
    VERSION_FROM => 'lib/List/Util.pm',
    (eval { ExtUtils::MakeMaker->VERSION(6.21) } ? (LICENSE => 'perl') : ()),
    ($do_xs ? () : (XS => {}, C => [])),
    (   eval { ExtUtils::MakeMaker->VERSION(6.46) } ? (
            META_MERGE => {
                resources => {    ##
                    repository => 'http://github.com/gbarr/Scalar-List-Utils',
                },
            }
          )
        : ()
    ),
);


sub can_cc {

    foreach my $cmd (split(/ /, $Config::Config{cc})) {
        my $_cmd = $cmd;
        return $_cmd if (-x $_cmd or $_cmd = MM->maybe_command($_cmd));

        for my $dir ((split /$Config::Config{path_sep}/, $ENV{PATH}), '.') {
            my $abs = File::Spec->catfile($dir, $_[1]);
            return $abs if (-x $abs or $abs = MM->maybe_command($abs));
        }
    }

    return;
}
