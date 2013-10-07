use Test::More;
use Joose;

my @seq = ();
sub Vehicle : Object {
    push @seq,'a';
    this->registration = rand(10);
}

sub LandVehicle : Object {
    push @seq,'b';
}

sub Car : Object {
    push @seq,'c';
}

sub SportsCar : Object {
    push @seq,'d';
}

sub RacingCar : Object {
    Vehicle->call(this) if $_[0] && $_[0] == 1;
    push @seq,'e';
}

#set up the inheritance chain
LandVehicle->prototype = Vehicle->new(); 
Car->prototype         = LandVehicle->new(); 
SportsCar->prototype   = Car->new();
RacingCar->prototype   = SportsCar->new();

my $f1_ferrari = RacingCar->new();
my $f1_mazda   = RacingCar->new();
my $registration1 = $f1_ferrari->registration; 
my $registration2 = $f1_mazda->registration;

ok ($registration1 == $registration2);
is (scalar @seq, 6);
is (join(',', @seq), 'a,b,c,d,e,e');


$f1_ferrari = RacingCar->new(1);
$f1_mazda   = RacingCar->new(1);
$registration1 = $f1_ferrari->registration; 
$registration2 = $f1_mazda->registration;

ok ($registration1 != $registration2);
is (scalar @seq, 10);
is (join(',', @seq), 'a,b,c,d,e,e,a,e,a,e');

done_testing(6);
