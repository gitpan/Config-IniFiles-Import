use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'		=> 'Config::IniFiles::Import',
    'VERSION_FROM'	=> 'Import.pm',
    'PREREQ_PM'		=> { Carp => 0,
                       FindBin => 0,
                       Config::IniFiles => 2.29,
                       Date::Language => 0
                     },
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      ( ABSTRACT => 'Import Ini-File entrys to Perl-Variables with extensions',
        AUTHOR     => 'Jürgen von Brietzke <juergen.von.brietzke@t-online.de>') : ()),
);
