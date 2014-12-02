use Joose;
use Test::More;

my $callCounter = 0;

#define the Person Class
sub Person : Object {}

Person->walk = sub {
    ok('Walk Called');
    ++$callCounter;
};

Person->sayHello = sub {
    #should not be called
    ok('say hello called');
    --$callCounter;
};

# define the Student class
sub Student : Object {}

# inherit Person
Student->prototype = Person->new;
 
# replace the sayHello method
Student->sayHello = sub {
    ok('sayHello Called');
    ++$callCounter;
};

# add sayGoodBye method
Student->sayGoodBye = sub {
    ++$callCounter;
};

my $student1 = Student->new();
$student1->sayHello->();
$student1->walk->();
$student1->sayGoodBye->();

is($callCounter,3);

# check inheritance
ok ( $student1->instanceof(Student) ); # true
###############################################
ok ( $student1->instanceof(Person) ); # true

done_testing(5);
