# This -*- perl -*- script makes the Makefile

use ExtUtils::MakeMaker;

#--- MY package

sub MY::libscan {
    my($self,$path) = @_;

    return '' 
	if($path =~ m:/(RCS|CVS|SCCS)/: ||
	   $path =~ m:[~%]$: ||
	   $path =~ m:\.(b[ac]k|orig|rej)$:
	  );

    $path;
}

WriteMakefile(
	VERSION_FROM	=> "builtin.pm",
	NAME      	=> "builtin",
 	LIBS		=> [qw(-lposix4)],
	'dist'    	=> {COMPRESS => 'gzip -9f',
			    SUFFIX   => 'gz', 
			   },
	'clean'   	=> {FILES => join(" ",
					map { "$_ */$_ */*/$_" }
					qw(*% *.html *.b[ac]k *.old *.orig))
			   },
);
