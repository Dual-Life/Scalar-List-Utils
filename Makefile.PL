# This -*- perl -*- script makes the Makefile

use ExtUtils::MakeMaker;

#--- MY package

WriteMakefile(
	VERSION_FROM	=> "lib/Scalar/DualVar.pm",
	NAME      	=> "Scalar::DualVar",
	DISTNAME      	=> "Scalar-List-Utils",
# 	LIBS		=> [qw(-lposix4)],
);
