package Joose;
use strict;
use warnings;
use Data::Dumper;

#==========================================================================
#globals
#==========================================================================
my %PACKAGES;
my %SOURCE;
my %THESE;
my $THIS;
my $LASTTHIS;
our $VERSION = '0.001';

sub import {
    my $class = shift;
    strict->import;
    warnings->import;
    my $pkg = caller;
    
    eval qq {
        package $pkg;
        use base 'Joose::Attr';
    };
    
    {
        no strict 'refs';
        *{   $pkg . '::this'    } = \&this;
        *{   $pkg . '::Object'  } = \&object;
    }
}

sub this {
    my $c = (caller(1))[3];
    if ($c =~ /__ANON__$/) {
        return $THIS;
    }
    
    $THIS = $THESE{$c} || $THIS;
}

sub object {
    my $const = shift;
    my $self = {};
    if (ref $const eq 'CODE') {
        $self->{constructor} = $const;
    } elsif (ref $const) {
        $self = $const;
    }
    
    $THESE{'Joose::Object'} = bless $self, 'Joose::Object';
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
        my $proto = $self->{__proto__};
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
        ##what's being called?
        my $called = $self->{$method} || $ProtoSearch->($self,$method);
        if ( ref $called eq 'CODE' ) {
            my @c = caller;
            
            if (!$SOURCE{$c[0]}) {
                open(my $fh, "<", $c[1])  or die "cannot open < $c[1]: $!";
                my $data = do { local $/;<$fh>};
                close $fh;
                my @data = split /\n/, $data;
                $SOURCE{$c[0]} = \@data;
            }
            
            my $line = $SOURCE{$c[0]}->[$c[2] - 1];
            if (my $ok = $line eq 'ok' || $line =~ /$method\s*?\(/){
                $SOURCE{$c[0]}->[$c[2] - 1] = 'ok' if !$ok;
                my $ret;
                my $oldthis = $THIS;
                $THIS = $self;
                my $error = do {
                    local $@;
                    eval {
                        $ret = $called->(@_);
                    };
                    $@;
                };
                $THIS = $oldthis;
                if ($error){
                    Carp::croak $error;
                }
                return $ret;
            }
        } elsif (ref $called eq 'HASH') {
            $self->{$method} = bless $self->{$method},ref $self;
        }
        $self->{$method} ||= $called;
    }
    
    sub new {
        my $class = shift;
        my $n = {};
        $n->{__proto__} = $class;
        my $oldthis = $THIS;
        $THIS = $THESE{ref $class} = bless $n, ref $class;
        if (my $constructor = $n->{__proto__}->{constructor}) {
            $constructor->(@_);
        }
        $THIS = $oldthis;
        return $n;
    }
    
    sub prototype : lvalue {
        my $self = shift;
        if (@_) {
            my $proto = shift;
            $self->{__proto__} = $proto;
        }
        $self->{__proto__};
    }
    
    sub call {
        my $self = shift;
        my $parent = shift;
        $THESE{ref $self} = $parent;
        $self->constructor(@_);
    }
    
    sub instanceof {
        my $self = shift;
        my $class = shift;
        while ($self) {
            if (ref $self eq ref $class) {
                return 1;
            }
            
            $self = $self->{__proto__};
        }
        
        return 0;
    }
}

1;

__END__


