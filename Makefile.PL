#use 5.008;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Config::IniFiles::Import',
    'VERSION_FROM'	=> 'Import.pm', # finds $VERSION
    'PREREQ_PM'		=> {Carp => 0, FindBin => 0, Config::IniFiles => 2.29},
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT => 'Import Ini-File entrys to Perl-Variables',
       AUTHOR     => 'Jürgen von Brietzke <juergen.von.brietzke@t-online.de>') : ()),
);
