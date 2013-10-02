use Joose;
use Test::More;
use Data::Dumper;

sub myObject : Object {
    this->iAm = $_[0];
    this->whoAmI = sub {  
        return this->iAm;
    };
}

my $first = myObject->new('Mamod');
my $firstname = $first->whoAmI();

my $second = myObject->new('Mehyar');
my $lastname = $second->whoAmI();


is ($firstname, 'Mamod');
is ($lastname, 'Mehyar');

done_testing(2);

