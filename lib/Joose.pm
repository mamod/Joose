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
            
            $PACKAGES{$module} = bless( { constructor => $code }, $module);
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
        my $called = $self->{$method} || $ProtoSearch->($self,$method);
        if ( ref $called eq 'CODE') {
            my $OLDTHIS = $THIS;
            $self->{$method} = sub {
                $THIS = $self;
                my $ret = $called->(@_);
                $THIS = $OLDTHIS;
                return $ret;
            };
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
        if ( my $constructor = $n->{__proto__}->{constructor} ) {
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
        $self->constructor->(@_);
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

=head1 NAME

Joose - A Perl Object System the javascript Way

=head1 DESCRIPTION



=head1 SYNOPSIS
    
    package TEST;
    use Joose;
    
    sub Person : Object {
        this->name = $_[0];
    }
    
    Person->getName = sub {
        return this->name;
    };
    
    my $preson = Test::Person->new('me');
    print $person->getName->(); ## = me
    print $person->getName ## = returns sub ref
    
=head1 METHODS


=head1 EXAMPLE

    sub extend {
        my ($b,$a,$t,$p) = @_;
        $b->prototype = $a;
        $a->call($t,@{$p});
    }
        
    sub A : Object {
        this->info1 = sub {
            return("A");
        };
    }

    sub B : Object {}
    B->constructor = sub {
        my ($p1,$p2) = @_;
        extend(B,A,this);
        this->info2 = sub {
            return("B" . $p1  . $p2);
        }
    };

    my $C; $C = Object sub {
        my ($p) = @_;
        extend($C,B,this,["1","2"]);
        this->info3 = sub {
            return("C" . $p);
        };
    };
    
    my $c = $C->new("c");
    $c->info1->(); # A
    $c->info2->(); # B12
    $c->info3->(); # Cc
