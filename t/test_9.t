use Joose;
use Test::More;

sub extend {
    my ($Child, $Parent) = @_;
    $Child->prototype = inherit($Parent);
    $Child->parent = $Parent;
}

sub inherit {
    my ($proto) = @_;
    my $F = Object sub{};
    $F->prototype = $proto;
    return $F->new();
}

# --------- the base object ------------
sub Animal : Object {
    my ($name) = @_;
    this->name = $name;
}

# methods
Animal->run = sub {
    return (this->toString() . " is running!");
};

Animal->toString = sub {
    return this->name;
};


# --------- the child object -----------
sub Rabbit : Object {
    my ($name) = @_;
    this->parent->constructor($name);
}

# inherit
extend(Rabbit, Animal);

#// override
Rabbit->run = sub {
    my $parentText = Rabbit->parent->run();
    is ($parentText, 'Jumper is running!');
    return (this->name . " bounces high into the sky!");
};

my $rabbit = Rabbit->new('Jumper');

my $text = $rabbit->run();

is ($text,'Jumper bounces high into the sky!');

done_testing(2);
