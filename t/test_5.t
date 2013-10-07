use Joose;
use Test::More;


sub Person : Object  {
    my ($name) = @_;
    this->name = $name . ' the person';
}

sub Student : Object {
    my ($name)  = @_;
    this->name = $name . ' the student';
}
   
Student->prototype(Person->new('Joe'));
#//Student.prototype.constructor = Person;

my $me = Student->new('Mamod');

is($me->name,'Mamod the student'); #mamod the student
is($me->__proto__->name, 'Joe the person'); #joe the person

ok ($me->instanceof(Student));
ok ($me->instanceof(Person));

done_testing(4);
