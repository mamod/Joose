package Joose;
use strict;
use warnings;
use Data::Dumper;

#==========================================================================
#globals
#==========================================================================
my %PACKAGES;
my %SOURCE;
my $THIS;

our $VERSION = '0.001';

sub import {
    my $class = shift;
    strict->import;
    warnings->import;
    my @c = caller;
    my $pkg = $c[0];
    
    open(my $fh, "<", $c[1])  or die "cannot open < $c[1]: $!";
    my $data = do { local $/;<$fh>};
    close $fh;
    my @data = split /\n/, $data;
    $SOURCE{$c[0]} = \@data;
    
    eval qq {
        package $pkg;
        use base 'Joose::Attr';
    };
    
    {
        no strict 'refs';
        *{ $pkg . '::this'  } = \&this;
        *{ $pkg . '::Object'  } = \&object;
    }
}

sub this {$THIS}

sub object {
    my $const = shift;
    my $self = {};
    if (ref $const eq 'CODE') {
        $self->{constructor} = $const;
    } elsif (ref $const){
        $self = $const;
    }
    return bless $self, 'Joose::Object';
}

package Joose::Attr {
    use Data::Dumper;
    use B;
    sub MODIFY_CODE_ATTRIBUTES {
        my ($pkg,$code,$attr) = @_;
        my $obj = B::svref_2object $code;
        my $name = $obj->GV->NAME;
        if ($attr eq 'Object') {
            no strict 'refs';
            no warnings 'redefine';
            my $module = $pkg . '::' . $name;
            my $warn = '$' . $pkg . '::SIG{__WARN__}';
            eval qq {
                package $module;
                use base 'Joose::Object';
            };
            
            $PACKAGES{$module} = bless({constructor => $code}, $module);
            
            *{ $pkg . '::' . $name } = sub {
                $PACKAGES{$module};
            };
        }
        
        return ();
    }
}

package Joose::Object {
    use Data::Dumper;
    use Carp;
    
    my $ProtoSearch = sub {
        my $self = shift;
        my $method = shift;
        my $proto = $THIS->{__proto__};
        while ($proto) {
            if (my $found = $proto->{$method}){
                return $found;
            }
            $proto = $proto->{__proto__};
        }
        return undef;
    };
    
    our $AUTOLOAD;
    sub AUTOLOAD : lvalue {
        my $self = shift;
        my ($method) = ($AUTOLOAD =~ /([^:']+$)/);
        return if $method eq 'DESTROY';
        $THIS = $self;
        ##what's being called?
        my $called = $self->{$method} || $ProtoSearch->($self,$method);
        if ( ref $called eq 'CODE' ) {
            my @c = caller(0);
            my $line = $SOURCE{$c[0]}->[$c[2] - 1];
            if (my $ok = $line eq 'ok' || $line =~ /$method\s*?\(/){
                $SOURCE{$c[0]}->[$c[2] - 1] = 'ok' if !$ok;
                my $ret;
                my $error = do {
                    local $@;
                    eval {
                        $ret = $called->(@_);
                    };
                    $@;
                };
                
                if ($error){
                    Carp::croak $error;
                }
                return $ret;
            }
            
        } elsif (ref $called eq 'HASH') {
            $self->{$method} = bless {},ref $self;
        }
        
        $self->{$method} ||= $called;
    }
    
    sub new {
        my $class = shift;
        my $n = {};
        $n->{__proto__} = $class;
        $THIS = bless $n, ref $class;
        if (my $constructor = $n->{__proto__}->{constructor}) {
            $constructor->(@_);
        }
        return $n;
    }
    
    sub prototype : lvalue {
        my $self = shift;
        $self->{__proto__};
    }
    
    sub instanceof {
        my $self = shift;
        my $class = shift;
        return ref $self eq ref $class;
    }
}


1;

__END__





