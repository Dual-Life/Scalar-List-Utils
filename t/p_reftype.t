#!./perl

# force perl-only version to be tested
sub List::Util::bootstrap {}

do 't/reftype.t';
