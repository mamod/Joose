use Joose;
use Test::More;

sub Numbers : Object {}

my $numbers = Numbers->new();

##no number
is ($numbers->number,undef);

##add number to prototype
Numbers->number = 1;

is ($numbers->number,1);

##change numbers
$numbers->number = 9;
is ($numbers->number,9);

##but proto must stay 1
is ($numbers->__proto__->number,1);

##change number proto
Numbers->number = 10;

##construct new instance
my $numbers2 = Numbers->new();
is ($numbers2->__proto__->number,10);
is ($numbers2->number,10);

##first instant has not changed
is ($numbers->__proto__->number,10);
is ($numbers->number,9);

done_testing(8);
