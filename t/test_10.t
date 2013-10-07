use Test::More;
use Joose;

#The functions we are going to use 
sub A : Object {}
sub B : Object {}
sub C : Object {}
sub D : Object {}
sub E : Object {}

#set up the inheritance chain 
D->prototype = E->new();
C->prototype = D->new();
B->prototype = C->new();
A->prototype = B->new();

#Add custom functions to each
A->foo = sub {
    return "a";
};
B->bar = sub {
    return "b";
};
C->baz = sub {
    return "c";
};
D->wee = sub {
    return "d";
};
E->woo = sub {
    return "e";
};

#Some tests
my $a = A->new();

is ($a->foo(),'a');
is ($a->bar(), 'b');
is ($a->baz(), 'c');
is ($a->wee(),'d');
is ($a->woo(),'e');

done_testing(5);
