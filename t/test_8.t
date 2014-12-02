use Joose;
use Test::More;

sub Person : Object {
    this->cool = 1 if $_[0] eq 'First';
    this->setName->(@_);
}

Person->setName = sub {
    this->name = $_[0];
    return 9;
};



my $p1 = Person->new('First');
my $p2 = Person->new('Second');

$p1->toot = sub{};

ok($p1->cool);
ok(!$p2->cool);

ok (ref $p1->toot eq 'CODE');
ok (!$p2->toot);

is ($p1->name, 'First');
is ($p2->name, 'Second');

done_testing(6);
