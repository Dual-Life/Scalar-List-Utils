#!./perl -T

# force perl-only version to be tested
sub List::Util::bootstrap {}

do 't/tainted.t';
