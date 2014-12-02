use Joose;
use Test::More;


my $test = Object sub {
    is (__LINE__, 6);
    this->num = $_[0];
};

$test->anotherSay = sub {
    this->num = 9;
    return 'Hi there';
};

my $n = $test->new(5);
my $n2 = $test->new(15);

is ( $n->num, 5); #5

my $ret = $n->anotherSay->();

is ($ret, 'Hi there');

is ( $n->num, 9); #9;
is ($n2->num, 15); #15

done_testing(6);
