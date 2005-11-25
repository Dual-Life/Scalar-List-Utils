#line 1 "inc/Module/Install/Base.pm - /home/gbarr/perl/Module/Install/Base.pm"
package Module::Install::Base;

#line 28

sub new {
    my ($class, %args) = @_;

    foreach my $method (qw(call load)) {
        *{"$class\::$method"} = sub {
            +shift->_top->$method(@_);
        } unless defined &{"$class\::$method"};
    }

    bless(\%args, $class);
}

#line 46

sub AUTOLOAD {
    my $self = shift;
    goto &{$self->_top->autoload};
}

#line 57

sub _top { $_[0]->{_top} }

#line 68

sub admin {
    my $self = shift;
    $self->_top->{admin} or Module::Install::Base::FakeAdmin->new;
}

sub is_admin {
    my $self = shift;
    $self->admin->VERSION;
}

sub DESTROY {}

package Module::Install::Base::FakeAdmin;

my $Fake;
sub new { $Fake ||= bless(\@_, $_[0]) }
sub AUTOLOAD {}
sub DESTROY {}

1;

__END__

#line 112
