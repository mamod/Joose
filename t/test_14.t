use Test::More;
use Joose;

my $Base = {
    superalert => sub {
        ok(1);
    }
};

my $Child = Object $Base;
$Child->width = 20;
$Child->height = 15;
$Child->a = ['s',''];
$Child->childAlert = sub {
    is (scalar @{this->a},2);
    is (this->height, 'h');
};

my $Child1 = Object $Child;
$Child1->depth = 'depth';
$Child1->height = 'h';
$Child1->alert = sub {
    is(this->height,'h');
    is(scalar @{this->a},2);
    this->childAlert->();
    this->superalert->();
};

my $child1 = Object $Child1;
$child1->alert->();

done_testing(5);
