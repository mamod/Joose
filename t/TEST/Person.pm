package TEST::Person;
use TEST::Family;
use Joose;

sub Name : Object {
    TEST::Family::Name->call(this,'Mehyar');
    this->name = $_[0];
}

Name->get_first_Name = sub {
    return this->name;
};

1;
