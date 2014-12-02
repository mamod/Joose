use Joose;
use Test::More;
my $counter = 0;
sub Person : Object {
    this->location = $_[0];
}

Person->fname = sub {
	this->firstname = $_[0];
	return $_[0];
};

my $person1 = Person->new('first');
my $person2 = Person->new('second');

###declare after creating new instances
Person->lname = sub {
    this->number = ++$counter;
	this->lastname = $_[0];
	return $_[0];
};

Person->fullname = sub {
    return  this->firstname . ' ' . this->lastname;
};

my $firstname =  $person1->fname->('Mamod');
my $lastname = $person1->lname->('Mehyar');
my $fullname = $person1->fullname->();

my $firstname2 =  $person2->fname->('John');
my $lastname2 = $person2->lname->('Due');
my $fullname2 = $person2->fullname->();

is($firstname, 'Mamod');
is($lastname, 'Mehyar');
is($fullname, 'Mamod Mehyar');
is($person1->number, 1);
is($person1->location, 'first');

is($firstname2, 'John');
is($lastname2, 'Due');
is($fullname2, 'John Due');
is($person2->number, 2);
is($person2->location, 'second');

done_testing(10);

