use 5.010001;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => 'Joose',
    VERSION_FROM      => 'lib/Joose.pm',
    PREREQ_PM         => {
    },
    ($] >= 5.005 ?
      (ABSTRACT_FROM  => 'lib/Joose.pm', # retrieve abstract from module
       AUTHOR         => 'Mamod A. Mehyar <mamod.mehyar@gmail.com>') : ()),
);
