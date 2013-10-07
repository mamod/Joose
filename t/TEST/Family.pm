package TEST::Family;
use Joose;

sub Name : Object {
    my $name = $_[0];
    this->name = $name;
    this->get_last_Name = sub {
        return $name;
    };
    
    this->get_same_Name = sub {
        return this->name;
    };
    
}

1;
