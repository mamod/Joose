use Test::More;
use FindBin qw($Bin);
use lib $Bin;
use TEST::Person;

my $n = TEST::Person::Name->new('Mamod');

is ($n->get_first_Name->(),'Mamod');
is ($n->get_last_Name->(), 'Mehyar');
is $n->get_same_Name->(), 'Mamod';

done_testing(3);
