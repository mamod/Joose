use Test::More;

package TEST {
    use Joose;
    use Data::Dumper;
    use Test::More;
    
    sub Jaguar : Object {
        is (ref this, 'TEST::Jaguar');
        is (this->name,'Jaguar');
    }
    
    Jaguar->name = 'Jaguar';
    Jaguar->getName = sub {
        return this->name;
    };
    
    my $Animal = Object sub {
        my $j = Jaguar->new();
        is (ref this, 'Joose::Object');
        is ($j->getName->(),'Jaguar');
        this->setName->(@_);
    };
    
    $Animal->setName = sub {
        this->name = $_[0];
        is (ref this, 'Joose::Object');
    };
    
    sub Cheeta : Object {
        my $a = $Animal->new('Rabbit');
        is ($a->name,'Rabbit');
        this->name = 'Cheeta';
        is ('TEST::Cheeta', ref this);
        is (this->name, 'Cheeta');
    }
    
    sub Lion : Object {
        Cheeta->new();
        this->name = 'Lion';
        is (ref this,'TEST::Lion');
    }
    
    sub Tiger : Object {
        this->name = 'Tiger';
        my $lion = Lion->new();
        is (ref this,'TEST::Tiger');
        is (ref this->name2,'CODE');
        is (ref $lion,'TEST::Lion');
        this->name2->();
    }
    
    Tiger->name2 = sub {
        Jaguar->new();
        is (this->name, 'Tiger');
    };
    
    my $t = $Animal->new('Donkey');
    is (ref $t->setName,'CODE');
    is ($t->name,'Donkey');
}

TEST::Tiger->new();
done_testing(22);
