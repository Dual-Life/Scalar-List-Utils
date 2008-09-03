#!perl
use strict;
use warnings;
use File::Spec;
use Scalar::Util;
my $has_xs = eval { Scalar::Util->import('dualvar'); 1 };
my $xs_pm = File::Spec->catfile(qw(blib lib List Util XS.pm));
open(FH,$xs_pm) or die "Cannot open $xs_pm: $!\n";
my @file = <FH>;
foreach my $line (@file) {
  next unless $line =~ /# FIXUP/;
  if ($has_xs) {
    $line =~ s/^sub VERSION/sub _VERSION/;
    $line =~ s/^# VERSION/\$VERSION/;
  }
  else {
    $line =~ s/^sub _VERSION/sub VERSION/;
    $line =~ s/^\$VERSION/# VERSION/;
  }
}
unlink($xs_pm);
open(FH,">$xs_pm") or die "Cannot open $xs_pm: $!\n";
print FH @file;
close(FH);
