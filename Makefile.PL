#!/usr/bin/env perl

use ExtUtils::MakeMaker;

$no_xs = grep { $_ eq '-pm' } @ARGV;

WriteMakefile(
	VERSION_FROM	=> "lib/List/Util.pm",
	NAME            => "List::Util",
	DISTNAME      	=> "Scalar-List-Utils",
	clean           => { FILES => 'noxs' },
	CONFIGURE       => \&init,
);

sub init {
  my($self,$hash) = @_;

  if ($no_xs) {
    @{$hash}{XS,C} = ( {}, [] );

    print "\n\n","*"x40,"\n";
    print "Using perl only implementation\n";
    print "Some functions will not be avaliable\n";
    print "*"x40,"\n\n";
    

    $hash->{PM} = {
     'noxs/List/Util.pm'   => '$(INST_LIB)/List/Util.pm',
     'noxs/Scalar/Util.pm' => '$(INST_LIB)/Scalar/Util.pm'
    };
    $hash->{MAN3PODS} = {
     'noxs/List/Util.pm'   => '$(INST_MAN3DIR)/List::Util.3',
     'noxs/Scalar/Util.pm' => '$(INST_MAN3DIR)/Scalar::Util.3'
    };
  
  }
  $hash;
}

sub MY::postamble {

  return '' unless $no_xs;

<<'ESQ';

NOXS = $(PERL) -p -e 's/^\#(?=.*no-XS)//; s/^(?=.*XS-only)/\#/; s?^__END__??;'

noxs/List/Util.pm : lib/List/Util.pm
	$(NOXS) lib/List/Util.pm > noxs/List/Util.pm

noxs/Scalar/Util.pm : lib/Scalar/Util.pm
	$(NOXS) lib/Scalar/Util.pm > noxs/Scalar/Util.pm

config :: noxs/List/.exists noxs/Scalar/.exists
	@$(NOOP)

noxs/List/.exists :
	@$(MKPATH) noxs/List

noxs/Scalar/.exists :
	@$(MKPATH) noxs/Scalar

ESQ

}
