#!/usr/bin/perl -w

  use File::Spec;
  use FileHandle;
  use FindBin;

  use lib $FindBin::Bin;

  use Config::IniFiles::Import;

  use strict;

  BEGIN
  {
    my $FH = FileHandle ->
             new( File::Spec -> catfile( $FindBin::Bin,  'Test.prt' ), 'w' );

    my $INI = Config::IniFiles::Import ->
              new (
                    -file     => File::Spec->catfile( $FindBin::Bin,'Test.ini' ),
                    -language => 'English',
                    -predef   => [ 'UserValue', 'KV', 'This value set on script' ],
                    -predef   => [ 'DateTime' , 'Datum', '%B.%Y', 'German' ],
                  );

    $INI -> Import(
                    -loadsection  => [ qw( K ) ],
                    -loadvariable => [ qw( Update::Kiwi+User ) ],
                    -exportto     => 'Cfg',
                    -protocol     => $FH
                  );
  }

  print "Update_Kiwi    : $Cfg::Update_Kiwi\n";
  print "Update_User    : $Cfg::Update_User\n";
  print "K_Time         : $Cfg::K_Time\n";
  print "K_Date         : $Cfg::K_Date\n";
  print "K_Name         : $Cfg::K_Name\n";
  print "K_Datum        : $Cfg::K_Datum\n";

