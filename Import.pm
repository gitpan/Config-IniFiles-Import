# ###################################################################################################
# # Script      :  Config::IniFiles::Import                                                         #
# #                -------------------------------------------------------------------------------- #
# # Author      :  Juergen von Brietzke                                                 (c) JvBSoft #
# #                -------------------------------------------------------------------------------- #
# # Version     :  0.800                                                                13.Jun.2003 #
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
# # Decription  :  Import von Ini-Dateien auf Variablen                                             #
# #                -------------------------------------------------------------------------------- #
# #                Die Definitionen von Ini-Dateien werden mittels des Moduls 'Config::IniFiles'    #
# #                gelesen, und mit dem vorliegenden Modul auf korrespondierende Variablen impor-   #
# #                tiert. Dabei werden die Variablen-Namen wie folgt gebildet:                      #
# #                 - Der Sektions-Name wird mit dem Parameter-Namen, getrennt durch Unterstrich    #
# #                   verbunden und dem Package 'INI' im Standardfall zugeordnet. Es besteht auch   #
# #                   die Moeglichkeit den Package-Name vorzugeben.                                 #
# #                Es besteht die Moeglichkeit Substitutionen bei den Werten vorzunehmen, hierfuer  #
# #                ist folgende Syntax anzuwenden:                                                  #
# #                 - Parameter = ...{Sektionsname::Parametername}...                               #
# #                Fuer die Substitution steht ein Satz von prefinierten Variablen zur Verfuegung,  #
# #                die wie folgt angesprochen werden koennen:                                       #
# #                 - Parameter = ...{Variable}...                                                  #
# #                Folgende predefinierte Variablen sind definiert:                                 #
# #                 - FindBin     - Verzeichnis-Pfad zum Skript                                     #
# #                 - UserName    - Name des angemeldeten Nutzers                                   #
# #                 - TimeShort   - Uhrzeit des Programmstarts           - 'HH:MM'                  #
# #                 - TimeLong    - Uhrzeit des Programmstarts           - 'HH:MM:SS'               #
# #                 - DateShort   - Datum des Programmstarts             - 'TT.MM.JJJJ'             #
# #                 - DateTime    - Datum und Uhrzeit des Programmstarts - 'TT.MM.JJJJ - HH:MM'     #
# #                 - DateLong    - Datum des Programmstarts             - 'TT.MMM.JJJJ'            #
# #                   Der Monatsname wird standardmaessig in deutscher Sprache erzeugt. Durch den   #
# #                   Parameter '-language' beim Konstruktor kann dieses Verhalten ueberschrieben   #
# #                   werden. Unterstuetzt werden die Moeglichkeiten des Moduls 'Date::Language'.   #
# #                Darueber hinaus besteht die Moeglichkeit weitere 'predifierte Variablen' ueber   #
# #                den Konstruktor zu erzeugen. Hierfuer stehen die beiden folgenden Formen:        #
# #                 - -predef => [ 'UserValue', key, value ]               allgemeiner Wert         #
# #                 - -predef => [ 'DateTime' , key, template, language ]  Datum und/oder Zeit      #
# #                -------------------------------------------------------------------------------- #
# #                Methode:  new                   Klassenkonstruktor                               #
# #                          ---------------------------------------------------------------------- #
# #                          Definiert eine neue Klasse vom Typ - Config::IniFiles::Import          #
# #                          ---------------------------------------------------------------------- #
# #                          Folgende Parameterpaare ( Option / Wert ) werden von diesem Modul aus- #
# #                          gewertet:                                                              #
# #                           -language              ( optional )                                   #
# #                            Syntax: '-language' => language_name                                 #
# #                                     - Beeinflusst die Schreibweise der predifinierten Variable  #
# #                                       DateLong. Fuer language_name siehe Date::Language. Vorga- #
# #                                       be ist German.                                            #
# #                          -predef                 ( optional )                                   #
# #                           Syntax:  '-predef' => [ 'DateTime', key, template, language ]         #
# #                                     - Erstellt Datum/Zeit - Variable mit dem Namen 'key', der   #
# #                                       Formatierung 'template' in der Sprache 'language' mittels #
# #                                       des Moduls Date::Language.                                #
# #                           Syntax:  '-predef' => [ 'UserValue', key, value ]                     #
# #                                     - Erstellt frei definierbare predifinierte Variablen.       #
# #                          ---------------------------------------------------------------------- #
# #                          Alle weiteren hier uebergebenen Parameterpaare ( Option / Wert ) wer-  #
# #                          den an das Modul 'Config::IniFiles' weitergereicht. Die Beschreibung   #
# #                          der Parameter ist dessen Dokumentation zu entnehmen.                   #
# #                           -file                                                                 #
# #                           -allowcontinue         ( optional )                                   #
# #                           -allowedcommentchars   ( optional )                                   #
# #                           -commentchar           ( optional )                                   #
# #                           -default               ( optional )                                   #
# #                           -import                ( optional )                                   #
# #                           -nocase                ( optional )                                   #
# #                           -reloadwarn            ( optional )                                   #
# #                -------------------------------------------------------------------------------- #
# #                Methode:  Import                Importiert die Werte auf Variable                #
# #                          ---------------------------------------------------------------------- #
# #                          Diese Methode liest die Ini-Datei(en) ein und importiert die Daten auf #
# #                          Variable.                                                              #
# #                          ---------------------------------------------------------------------- #
# #                          Der Import-Methode koennen folgende Optionen uebergeben werden:        #
# #                           -loadsection           ( optional )                                   #
# #                            Syntax: '-loadsection' => [ qw( section1 section2 ... ) ]            #
# #                                     - Wird diese Option uebergeben, so werden nur die benannten #
# #                                       Sektionen importiert.                                     #
# #                           -loadvariable          ( optional )                                   #
# #                            Syntax: '-loadvariable' => [ qw( section::par1+par2 ... ) ]          #
# #                                     - Wird diese Option uebergeben, so werden nur die benannten #
# #                                       Variablen importiert.                                     #
# #                           -protocol              ( optional )                                   #
# #                            Syntax: '-protocol' => filehandle                                    #
# #                                     - Wird diese Option uebergeben, so wird der Import der Va-  #
# #                                       riablen in der durch den 'filehandle' uebergebenen Datei  #
# #                                       protokolliert.                                            #
# #                           -exportto              ( optional )                                   #
# #                            Syntax: '-exportto' => 'PackageName'                                 #
# #                                     - Standardmaessig werden die Variablen in dem Package 'INI' #
# #                                       abgelegt. Dies kann mit dieser Option beim Aufruf der Me- #
# #                                       thode geaendert werden.                                   #
# #                -------------------------------------------------------------------------------- #
# #                ...                                                                              #
# #                use Config::IniFiles::Import                                                     #
# #                ...                                                                              #
# #                $INI = Config::IniFiles::Import -> new( -option => value ... );                  #
# #                ...                                                                              #
# #                $INI -> Import(                                                                  #
# #                                -loadsection  => [ qw( section1 section2 ... ) ]             ,   #
# #                                -loadvariable => [ qw( section3::par1+par2 section4::par1 ) ],   #
# #                                -protocol     => filehandle                                      #
# #                                -exportto     => 'Config'                                    ,   #
# #                              );                                                                 #
# #                ...                                                                              #
# ###################################################################################################
# # History     :  0.100 - 22.09.2002 - JvB                                                         #
# #                        Erste Test- und Entwicklungsversion                                      #
# #                0.200 - 22.09.2002 - JvB                                                         #
# #                        Mit der Option '-loadsection', der Import-Methode, ist es moeglich aus-  #
# #                        gewaehlte Sektione zu importieren.                                       #
# #                0.210 - 23.09.2002 - JvB                                                         #
# #                        Ueberarbeitung der Dokumentation und Straffung des Codes                 #
# #                0.300 - 23.09.2002 - JvB                                                         #
# #                        Mit der Option '-protocol' besteht die Moeglichkeit den Variablenimport  #
# #                        zu Protokollieren.                                                       #
# #                0.301 - 24.09.2002 - JvB                                                         #
# #                        Fehlerkorrektur:                                                         #
# #                        - Wurde die Option '-loadsection' nicht angegeben, wurden der Variablen- #
# #                          import nicht durchgefuehrt.                                            #
# #                0.400 - 14.05.2003 - JvB                                                         #
# #                        Veraenderung des Importes der INI-Daten.                                 #
# #                        - Die Namen der Variablen werden nach einem neuen Verfahren gebildet.    #
# #                        - Das Package, in das der Import der Variablen erfolgt ist waehlbar.     #
# #                0.500 - 14.05.2003 - JvB                                                         #
# #                        Erweiterung fuer die Verarbeitung predefinierter Variablen.              #
# #                        - FindBin, UserName                                                      #
# #                0.600 - 15.05.2003 - JvB                                                         #
# #                        Erweiterung fuer den Import einzelner Parameter einer Sektion.           #
# #                        - Mit der Option '-loadvariable' koennen nur einzelne Parameter einer    #
# #                          Sektion uebernommen werden.                                            #
# #                0.700 - 15.05.2003 - JvB                                                         #
# #                        Weitere predefinierte Variable hinzugefuegt.                             #
# #                        - TimeShort, TimeLong, DateShort, DateLong, DateTime                     #
# #                        - Veraenderung des optionalen Protokolldrucks.                           #
# #                0.701 - 13.06.2003 - JvB                                                         #
# #                        - Korrektur der Dokumentation                                            #
# #                0.800 - 13.06.2003 - JvB                                                         #
# #                        - Erweiterung fuer frei definierbare 'predefinierte Variable'            #
# ###################################################################################################

  package Config::IniFiles::Import;

  use vars qw( $VERSION );  $VERSION = '0.800';

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
          while ( $self->{entrys}->{$key} =~ /{([:\w]+)}/ )
          {
            if    ( defined( $self->{entrys}->{$1} ) )
            {
              $self->{entrys}->{$key} =~ s/{([:\w]+)}/$self->{entrys}->{$1}/g;
            }
            elsif ( defined( $self->{predef}->{$1} ) )
            {
              $self->{entrys}->{$key} =~ s/{([:\w]+)}/$self->{predef}->{$1}/g;
            }
            else
            {
              croak "Can't substitute value by $key\n";
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
# #                                              P O D                                              #
# ###################################################################################################

=pod

=head1 NAME

Config::IniFile::Import - Import von MS-Windows-Format-Ini-Dateien auf Variablen

=head1 VERSION

Dieses Dokument beschreibt die Version 0.800 des Moduls Config::IniFiles::Import vom 13.06.2003

=head1 ANWENDUNG

  use Config::IniFiles::Import;
  ...
  $INI = Config::IniFiles::Import -> new( -option => value [ ... ] );
  ...
  $INI -> Import(
                  -loadsection  => [ qw( section1 section2 ...                        ) ],
                  -loadvariable => [ qw( section3::param1+param2 section4::param1 ... ) ],
                  -protocol     => filehandle                                            ,
                  -exportto     => 'Package'
                );

=head1 BESCHREIBUNG

Die Definitionen von INI-Dateien werden mittels des Moduls 'Config::IniFiles' gelesen, und mit dem
vorliegenden Modul auf korrespondierende Variablen importiert.

Dabei werden die Variablen-Namen wie folgt gebildet:

  - Der Sektions-Name wird mit dem Parameter-Namen, getrennt durch Unterstrich verbunden.
  - Standardmaessig werden die Variablen in dem Package 'INI' abgelegt. Dies kann jedoch durch die
    Option '-exportto' beim Aufruf der Methode 'Import' geaendert werden.

Aus diesem Grunde gelten fuer die Sektions- und Parameter-Namen folgende Einschraenkungen:

  - Diese Bezeichner duerfen nur aus gueltigen Wortzeichen bestehen
    ( a-z, A-Z, 0-9, _ )
  - Die Gross-/Kleinschreibung wird beachtet und fuehrt zu verschiedenen
    Variablennamen

=head2 Wertesubstitution mit INI-Datei Eintraegen

Es besteht die Moeglichkeit eine Wertesubstitution in den INI-Dateien vorzunehmen zu lassen. Hierzu
ist folgende Syntax anzuwenden:

  Parameter = ...{Sektion::Parameter}...

=item B<Substitutions-Beispiel>

  [SEKTION_1]
  Wert1 = bla
  Wert2 = foo{SEKTION_1::Wert1}foo

  Das ergibt fuer Wert2 den Wert 'fooblafoo'.

=head2 Wertesubstitution mit 'predefinierte Variablen'

Fuer die Substitution steht ein Satz von prefinierten Variablen zur Verfuegung, die wie folgt
angesprochen werden koennen:

  Parameter = ...{Variable}...

=head2 Predefinierte Variable

Folgende 'predefinierte Variablen' sind definiert:

=over 7

=item B<FindBin>

=back

Enthaelt den Pfad zum aktuellen Perl-Skript.

=over 7

=item B<UserName>

=back

Enthaelt den Namen des User's, der das aktuelle Skript gestarten hat.

=over 7

=item B<TimeShort>

=back

Enthaelt die Uhrzeit des Programmstarts in der Form 'HH:MM'

=over 7

=item B<TimeLong>

=back

Enthaelt die Uhrzeit des Programmstarts in der Form 'HH:MM:SS'

=over 7

=item B<DateShort>

=back

Enthaelt das Datum des Programmstarts in der Form 'TT.MM.JJJJ'

=over 7

=item B<DateLong>

=back

Enthaelt das Datum des Programmstarts in der Form 'TT.MMM.JJJJ'

=over 7

=item B<DateTime>

=back

Enthaelt das Datum und die Uhrzeit des Programmstarts in der Form 'TT.MM.JJJJ - HH:MM'

=item B<Substitutions-Beispiel fuer 'predifinierte Variablen'>

  [SEKTION_2]
  Wert3 = {FindBin}

  Das ergibt fuer Wert3 den Pfad zum aktuellen Perl-Skript.

=head2 User-definierte 'predefinierte Variablen'

Seit der Version 0.800 koennen mittels des Klassenkonstruktor eigene predefienierte Variablen
erzeugt werden.

=head1 METHODEN

=head2 new - Klassenkonstruktor

$INI = Config::IniFiles::Import -> new(
                                        -option => value,
                                        -option => value,
                                        ...
                                      );

=over 7

=item B<-language>  -  ( optional )

=back

Syntax:  '-language' => language_name

language_name : Alle vom Modul 'Date::Language' unterstuetzen Sprachen.

Dieser Parameter beeinflusst die Schreibweise der predefinierten Variablen 'DateLong'.

=over 7

=item B<-predef>  -  ( optional )

=back

Syntax 1:  '-predef' = [ 'DateTime', key, template, language ]

Erstellt Datum/Zeit - Variable mit dem Namen 'key', der Formatierung 'template' in der Sprache
'language' mittels des Moduls Date::Language.

Syntax 2:  '-predef' = [ 'UserValue', key, value ]

Erstellt eine frei definierbare predifinierte Variable mit dem Namen 'key' und Wert 'value'.

Alle weiteren hier uebergebenen Parameterpaare ( Option / Wert ) werden an das Modul
'Config::IniFiles' weitergereicht. Die Beschreibung der Parameter ist dessen Dokumentation zu
entnehmen. Nachfolgend werden jedoch die moeglichen Parameter aufgefuehrt.

=over 7

=item B<-file>

=item B<-allowcontinue>

=item B<-allowedcommentchars>

=item B<-commentchar>

=item B<-default>

=item B<-import>

=item B<-nocase>

=item B<-reloadwarn>

=back

=head2 Import - Importiert die Werte auf Variable

$INI -> Import(
                -loadsection  => [ qw( section1 section2 ...                        ) ],
                -loadvariable => [ qw( section3::param1+param2 section4::param1 ... ) ],
                -protocol     => filehandle                                            ,
                -exportto     => 'Package'
              );

Diese Methode liest die INI-Datei(en) ein und importiert die Daten auf Variable. Die Definition
der Variablen erfolgt in dieser Methode als globale Variable ( use vars qw( ... ) ). Damit
koennen Programme die dieses Modul anwenden, weiter mit dem Pragma 'use strict' arbeiten.

=over 7

=item B<-loadsection>  -  ( optional )

=back

Syntax:  '-loadsection' => [ qw( section1 section2 ... ) ]

Wird diese Option uebergeben, so werden nur die benannten Sektionen importiert. Andernfall erfolgt
der Import aller Sektionen.

=over 7

=item B<-loadvariable>  -  ( optional )

=back

Syntax: '-loadvariable' => [ qw( section1::par1+par2 section2::par ... ) ]

Wird diese Option uebergeben, so werden nur die benannten Variablen importiert.

=over 7

=item B<-protocol>  -  ( optional )

=back

Syntax: '-protocol' => filehandle

Wird diese Option uebergeben, so wird der Import der Variablen in der durch den 'filehandle'
uebergebenen Datei protokolliert.

=over 7

=item B<-exportto>

=back

Syntax: '-exportto' => 'PackageName'

Standardmaessig werden die Variablen in dem Package 'INI' abgelegt. Dies kann mit dieser Option
beim Aufruf der Methode geaendert werden.

=over 7

=item B<Hinweis>

=back

Die Optionen '-loadsection' und '-loadvariable' koennen kombiniert werden.

=head1 BEISPIEL

Das nachfolgende Beispiel liest die INI-Dateien 'Ini1.ini' und 'Ini2.ini' aus dem aktuellen
Verzeichnis ein. Es werden die Angaben der Sektionen 'GLOBAL' und 'VERZEICHNISSE' sowie die
Parameter 'Name' und 'TempDir' der Sektion 'USER' auf die entsprechenden Variablen des Package
'Cfg' des Programms importiert. Weitere eventuell vorhandene Sektionen und Variablen werden
ignoriert.

Die importierten Variablen werden in der Datei 'Load.prt' im aktuellen Verzeichnis protokolliert.

=head2 Datei - Ini1.ini

  [GLOBAL]
  Script        = {FindBin}
  [USER]
  Name          = {UserName}
  TmpDir        = C:\Tmp
  TempDir       = C:\Temp\{UserName}
  [VAR]
  Datum         = {Datum}
  Ort           = {City}

=head2 Datei - Ini2.ini

  [VERZEICHNISSE]
  Daten         = {USER::TempDir}\Daten
  Protokolle    = {USER::TempDir}\Protokoll
  [UPDATE]
  Programme     = D:\Update\Prg
  Dokumentation = D:\Update\Doc

=head2 Programm

  #!/usr/bin/perl
  ###############################################################################
  #
    use Config::IniFiles::Import;
    use File::Spec;
  #
    $FH = FileHandle -> new( File::Spec -> catfile( qw( . Load.prt ) ), 'w' );
  #
    print $FH "Test des Moduls : Config::IniFiles::Import\n";
    print $FH '-' x 100 . "\n\n";
  #
    $INI = Config::IniFiles::Import ->
           new( -predef => [ 'DateTime' , 'Datum', '%B.%Y', 'German' ],
                -predef => [ qw( UserValue City Berlin ) ],
                -file   => File::Spec->catfile( qw( . Ini1.ini ) ),
                -import => Config::IniFiles ->
                           new( -file => File::Spec->catfile( qw( . Ini2.ini ) ) )
              );
  #
    $INI -> Import(
                    -loadsection  => [ qw( GLOBAL VERZEICHNISSE ) ],
                    -loadvariable => [ qw( USER::Name+TempDir VAR::Datum+Ort ) ],
                    -protocol     => $FH                           ,
                    -exportto     => 'Cfg'
                  );
  #
    print "$Cfg::USER_Name\n";   # print = Name des Users
    print "$Cfg::VAR_Datum\n";   # print = Monatsname.Jahr in deutsch
    print "$Cfg::VAR_Ort\n";     # print = Berlin
  #
  ###############################################################################

=head1 FEHLERMELDUNGEN

=over 7

=item B<Can't substitute value by sektion_schluessel>

=back

Bei einer Substitution wird auf eine nicht definierte Kombination aus Sektion und Schluessel
zugegriffen, oder es wird eine nicht existente predifinierte Variable angesprochen.

Das Skript wird in diesem Fall mit einer entsprechenden Fehlermeldung abgebrochen!

=over 7

=item B<Can't create variable package::sektion_schluessel>

=back

Die Angegeben Variable konnte nicht erzeugt werden.

Das Skript wird in diesem Fall mit einer entsprechenden Fehlermeldung abgebrochen!

=over 7

=item B<Error by predifinition : $type : $key = $value\n>

=back

Die Definition einer privaten 'predefinierten Variablen' ist falsch.

Das Skript wird in diesem Fall mit einer entsprechenden Fehlermeldung abgebrochen!

=head1 PRAGMAS

strict

vars

=head1 MODULE

Carp

Date::Language

FindBin

Config::IniFiles   Version : 2.29 ( oder neuer )

Bei dem Einsatz unter Windoofs ist folgender Patch in dem Modul 'Config::IniFiles'
vorzunehmen:

  - Im Unterprogramm 'ReadConfig' ist die Anweisung wie folgt zu aendern:
    - von: 'while($self->{allowcontinue} && $val =~ s/\\$//) {'
    - in : 'while($self->{allowcontinue} && $val =~ s/\s\\$//) {'

=head1 VERSIONEN

0.100 - 22.09.2002 - JvB

        Erste Test- und Entwicklungsversion

0.200 - 22.09.2002 - JvB

        Mit der Option '-loadsection', der Import-Methode, ist es moeglich ausgewaehlte Sektione zu
        importieren.

0.210 - 23.09.2002 - JvB

        Ueberarbeitung der Dokumentation und Straffung des Codes

0.300 - 23.09.2002 - JvB

        Mit der Option '-protocol' besteht die Moeglichkeit den Variablenimport zu Protokollieren.

0.301 - 24.09.2002 - JvB

        Fehlerkorrektur:
        - Wurde die Option '-loadsection' nicht angegeben, wurden der Variablenimport nicht
          durchgefuehrt.

0.400 - 14.05.2003 - JvB

        Veraenderung des Importes der INI-Daten.
        - Die Namen der Variablen werden nach einem neuen Verfahren gebildet.
        - Das Package, in das der Import der Variablen erfolgt ist waehlbar.

0.500 - 14.05.2003 - JvB

        Erweiterung fuer die Verarbeitung predefinierter Variablen.
        - FindBin, UserName

0.600 - 15.05.2003 - JvB

        Erweiterung fuer den Import einzelner Parameter einer Sektion.
        - Mit der Option '-loadvariable' koennen nur einzelne Parameter einer Sektion uebernommen
          werden.

0.700 - 15.05.2003 - JvB

        Weitere predefinierte Variable hinzugefuegt.
        - TimeShort, TimeLong, DateShort, DateLong, DateTime
        Veraenderung des optionalen Protokolldrucks.

0.701 - 13.06.2003 - JvB

        - Korrektur der Dokumentation

0.800 - 13.06.2003 - JvB

        - Erweiterung fuer frei definierbare 'predefinierte Variable'

=head1 AUTOREN

JvB  -  Juergen von Brietzke
     -  juergen.von.brietzke@t-online.de

=head1 COPYRIGHT

Copyright (c) 2002, 2003 by JvB.

Dieses Modul ist freie Software.
Die Benutzung und / oder Veraenderung unterliegt der selben Lizenz wie Perl.

=cut

# ###################################################################################################
# #                                             E N D E                                             #
# ###################################################################################################
1;
