# ###################################################################################################
# # Script      :  Config::IniFiles::Import                                                         #
# #                -------------------------------------------------------------------------------- #
# # Author      :  Juergen von Brietzke                                                 (c) JvBSoft #
# #                -------------------------------------------------------------------------------- #
# # Version     :  1.100                                                                27.Aug.2003 #
# ###################################################################################################
# # Language    :  PERL 5                        (v)  5.00x.xx  ,  5.6.x  ,  5.8.x                  #
# #                -------------------------------------------------------------------------------- #
# # Pragmas     :  strict                        Beschraenkt unsichere Konstrukte                   #
# #                vars                          Vordeklaration globaler Variablen                  #
# #                -------------------------------------------------------------------------------- #
# # Module      :  Carp                          Generiert Fehlermeldungen                          #
# #                Date::Language                Datumsformatierung mit Multi-Language-Support      #
# #                FindBin                       Ermittelt das Verzeichnis des Perl-Skripts         #
# #                Config::IniFiles              Verarbeitung von MS-Windows-Format-Ini-Dateien     #
# ###################################################################################################
# # Decription  :  Import von MS-Windows-Format-Ini-Dateien auf Variablen                           #
# #                ================================================================================ #
# #                Die Definitionen von Ini-Dateien werden mittels des Moduls 'Config::IniFiles'    #
# #                gelesen, und mit dem vorliegenden Modul auf korrespondierende Variablen impor-   #
# #                tiert. Dabei werden die Variablen-Namen wie folgt gebildet:                      #
# #                 - Der Sektions-Name wird mit dem Parameter-Namen, getrennt durch Unterstrich    #
# #                   verbunden und dem Package 'INI' ( Standardfall ) zugeordnet.                  #
# #                 - Es besteht aber auch die Moeglichkeit den Package-Name frei zu waehlen.       #
# #                -------------------------------------------------------------------------------- #
# #                Die INI-Dateien koennen durch die Verwendung von Substitutionen flexible gehal-  #
# #                ten werden. Dabei ist folgende Syntax anzuwenden:                                #
# #                 - Parameter = ...{Sektionsname::Parametername}...                               #
# #                -------------------------------------------------------------------------------- #
# #                Fuer die Substitution steht ein Satz von 'predefinierten Variablen' zur Verfue-  #
# #                gung, die wie folgt angesprochen werden koennen:                                 #
# #                 - Parameter = ...{Variable}...                                                  #
# #                 - Folgende predefinierte Variablen stehen zur Verfuegung:                       #
# #                    - FindBin     - Verzeichnis-Pfad zum Skript                                  #
# #                    - UserName    - Name des angemeldeten Nutzers                                #
# #                    - TimeShort   - Uhrzeit des Programmstarts           - 'HH:MM'               #
# #                    - TimeLong    - Uhrzeit des Programmstarts           - 'HH:MM:SS'            #
# #                    - DateShort   - Datum des Programmstarts             - 'TT.MM.JJJJ'          #
# #                    - DateTime    - Datum und Uhrzeit des Programmstarts - 'TT.MM.JJJJ - HH:MM'  #
# #                    - DateLong    - Datum des Programmstarts             - 'TT.MMM.JJJJ'         #
# #                -------------------------------------------------------------------------------- #
# #                Darueber hinaus besteht die Moeglichkeit 'Nutzerdefierte Variablen' zu erzeugen. #
# #                Diese sind dem Konstruktor zu uebergeben.                                        #
# #                 - Hierfuer stehen die beiden folgenden Formen:                                  #
# #                    - -predef => [ 'UserValue', key, value ]                ( allgemeiner Wert ) #
# #                    - -predef => [ 'DateTime' , key, template, language ]   ( Datum/Zeit )       #
# #                ================================================================================ #
# #                Methode:  new                   Klassenkonstruktor                               #
# #                          ---------------------------------------------------------------------- #
# #                          Definiert eine neue Klasse vom Typ - Config::IniFiles::Import          #
# #                -------------------------------------------------------------------------------- #
# #                Methode:  Import                Importiert die Werte auf Variable                #
# #                          ---------------------------------------------------------------------- #
# #                          Diese Methode liest die Ini-Datei(en) ein und importiert die Daten auf #
# #                          Variable.                                                              #
# #                ================================================================================ #
# #                ...                                                                              #
# #                use Config::IniFiles::Import                                                     #
# #                ...                                                                              #
# #                $INI = Config::IniFiles::Import -> new(                                          #
# #                                                        -language => language,                   #
# #                                                        -predef   => [ ... ] ,                   #
# #                                                        -option   => value   ,                   #
# #                                                        ...                                      #
# #                                                      );                                         #
# #                ...                                                                              #
# #                $INI -> Import(                                                                  #
# #                                -loadsection  => [ qw( section1 section2 ... ) ]             ,   #
# #                                -loadvariable => [ qw( section3::par1+par2 section4::par1 ) ],   #
# #                                -protocol     => filehandle                                  ,   #
# #                                -exportto     => 'Config'                                    ,   #
# #                              );                                                                 #
# #                ...                                                                              #
# ###################################################################################################

  package Config::IniFiles::Import;

  use vars qw( $VERSION );

  $VERSION = '1.100';

  use Carp;
  use Date::Language;
  use FindBin;
  use Config::IniFiles  2.29;

  use strict;

  # #################################################################################################
  # # 1.)   OEFFENTLICHE METHODEN                                                                   #
  # #################################################################################################

    # +--------------------------------------------------------------------------------------------+
    # | new                    Klassen-Konstruktor                                                 |
    # | --------------------   ------------------------------------------------------------------- |
    # |                        $INI = Config::IniFiles::Import -> new( -option => value ... );     |
    # +--------------------------------------------------------------------------------------------+

      sub new
      {

        my $class = shift;
        my $self  = { -caller => caller };

        $self->{language} = 'German';

        my $time = time;

        # --- Optionen uebernehmen 

        while ( my ( $key, $value ) = splice( @_, 0, 2 ) )
        {
          if    ( $key eq '-file'     ) { unshift( @{$self->{option}}, ( $key, $value ) ) }
          elsif ( $key eq '-language' ) { $self->{language} = $value }
          elsif ( $key eq '-predef'   )
          {
            my ( $type, $key, $value, $lang ) = @$value;
            if    ( $type eq 'DateTime' )
            {
              my $lang = Date::Language -> new( $lang );
              $self->{predef}->{$key} = $lang -> time2str( $value, $time );
            }
            elsif ( $type eq 'UserValue' )
            {
              $self->{predef}->{$key} = $value;
            }
            else
            {
              croak "Error by predifinition : $type : $key = $value\n";
            }
          }
          else
          {
            push( @{$self->{option}}, ( $key, $value ) );
          }
        }

        # --- Testen ob die INI-Files vorhanden sind

        unless ( defined( ${$self->{option}}[0] )  and  ${$self->{option}}[0] eq '-file' )
        {
          croak "INI-File not defined\n";
        }
        unless ( -T ${$self->{option}}[1] )
        {
          croak "INI-File not found\n";
        }

        # --- Belegen der predefinierten Variablen

        $self->{predef}->{'FindBin'}   = $FindBin::Bin;
        $self->{predef}->{'UserName'}  = $ENV{USER};

        my $lang = Date::Language -> new( $self->{language} );

        $self->{predef}->{'TimeShort'} = $lang -> time2str( '%H:%M'           , $time );
        $self->{predef}->{'TimeLong'}  = $lang -> time2str( '%X'              , $time );
        $self->{predef}->{'DateShort'} = $lang -> time2str( '%d.%m.%Y'        , $time );
        $self->{predef}->{'DateLong'}  = $lang -> time2str( '%d.%b.%Y'        , $time );
        $self->{predef}->{'DateTime'}  = $lang -> time2str( '%d.%m.%Y - %H:%M', $time );

        bless $self, $class;

      }

    # +--------------------------------------------------------------------------------------------+
    # | Import                 Lesen und importieren der Ini-Dateien                               |
    # | --------------------   ------------------------------------------------------------------- |
    # |                        $INI -> Import(                                                     |
    # |                                        -loadsection  => [ qw( section1 ... ) ],            |
    # |                                        -loadvariable => [ qw( section2:value1,... ... ) ], |
    # |                                        -protocol     => filehandle            ,            |
    # |                                        -exportto     => 'packagename'                      |
    # |                                      );                                                    |
    # +--------------------------------------------------------------------------------------------+

      sub Import
      {

        my $self = shift;

        my $sections   = ';';
        my $filehandle = undef;
        my $exportto   = 'INI';

        # --- Optionen uebernehmen 

        while ( my ( $key, $value ) = splice( @_, 0, 2 ) )
        {
          if    ( $key eq '-loadsection'  ) { $sections  .= join( '_*;', @{$value}, ';' ) }
          elsif ( $key eq '-protocol'     ) { $filehandle = $value                        }
          elsif ( $key eq '-exportto'     ) { $exportto   = $value                        }
          elsif ( $key eq '-loadvariable' )
          {
            foreach ( @{$value} )
            {
              my ( $section, $members ) = split( /::/ );
              foreach ( split( /\+/, $members ) )
              {
                $sections .= "${section}_$_;";
              }
            }
          }
        }

        $sections =~ s/;;/;/g;

        # --- Uebernehmen der INI-Eintraege aus Modul Config::IniFiles

        tie my %ini, 'Config::IniFiles', ( @{$self->{option}} );

        foreach my $section ( keys( %ini ) )
        {
          foreach my $parameter ( keys( %{$ini{$section}} ) )
          {
            $self->{entrys}->{"${section}::${parameter}"} = $ini{$section}{$parameter};
          }
        }

        untie %ini;

        # --- Substitutionen ausfuehren

        foreach my $key ( keys( %{$self->{entrys}} ) )
        {
          while ( $self->{entrys}->{$key} =~ /{([:\w]+?)}/ )
          {
            if    ( defined( $self->{entrys}->{$1} ) )
            {
              $self->{entrys}->{$key} =~ s/{([:\w]+?)}/$self->{entrys}->{$1}/;
            }
            elsif ( defined( $self->{predef}->{$1} ) )
            {
              $self->{entrys}->{$key} =~ s/{([:\w]+?)}/$self->{predef}->{$1}/;
            }
            else
            {
              my $subst = $1;
              if ( $subst =~ /(ENV::)(.+)/ )
              {
                if ( defined( $ENV{$2} ) )
                {
                  $self->{entrys}->{$key} =~ s/{([:\w]+?)}/$ENV{$2}/;
                }
                else
                {
                  croak "Can't substitute value by $key\n";
                }
              }
              else
              {
                croak "Can't substitute value by $key\n";
              }
            }
          }
        }

        # --- Export der INI-Eintraege auf Variablen

        if ( defined( $filehandle ) )
        {
          print $filehandle "Config::IniFiles::Import ( V: $VERSION ) - Protokoll";
          print $filehandle ' ' x 13 . $self->{predef}->{'DateTime'} . "\n";
          print $filehandle '=' x 80 . "\n\n";
        }

        foreach my $key ( sort( keys( %{$self->{entrys}} ) ) )
        {
          $key =~ /(\w+)::(\w+)/i;
          my $variable  = "\$$1_$2";
          my $section   = $1;
          my $parameter = $2;
          if ( index( $sections, "$1_*"  ) > 0  or
               index( $sections, "$1_$2" ) > 0  or  $sections eq ';' )
          {
            $self->{entrys}->{$key} =~ s(\\$){\\\\};
            unless (
                     defined(
                              eval(
                                    "package $exportto; "                  .
                                    "use vars qw( $variable ); "           .
                                    "$variable = '$self->{entrys}->{$key}';"
                                  )
                            )
                   )
            {
              croak "Can't create variable $exportto" . '::' . "$variable\n";
            }
            if ( defined( $filehandle ) )
            {
              $variable =~ s/^\$//;
              printf $filehandle "%-25s = %-52s\n", $variable, $self->{entrys}->{$key}
            }
          }
        }

        if ( defined( $filehandle ) )
        {
          print $filehandle "\n" . '=' x 80 . "\n";
        }

      }

# ###################################################################################################
# #                                             E N D E                                             #
# ###################################################################################################
1;
