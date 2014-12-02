use Test::More;
use Joose;

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
is ($c->info1->(),'A'); # A
is ($c->info2->(), 'B12'); # B12
is ($c->info3->(),'Cc'); # Cc

done_testing(3);
