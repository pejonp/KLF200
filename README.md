# KLF200
Perlmodul für Velux KLF200 Gateway

Ist für KLF200 mit der neuen Firmware 0.2.0.0.71.0.
Das Perl-Script kann z.Z. nur die hinterlegten Scenen starten. Keine Statusprüfung oder sonst irgend etwas. Ist vielleicht etwas für erfahrene FHEM-User.
Im Script muss das Passwort und die IP-Adresse angepasst werden.

Das Script kann per Commandozeile im Linux gestarte werden :  perl ./99_KLF200.pl 1 <-- Scenen-ID

oder auch von FHEM aus. Das Script ins FHEM-Verzeichnis (/opt/fhem/FHEM) legen und Eigner fhem und Zugriff 777.

Im FHEM einen Dummy und Notify anlegen. Hier mal meine Konfig. Es kann immer nur ein Befehl abgesendet werden. 
Dieser muss erst fertig sein, dann wird der nächste verarbeitet. 1-2 mal hat sich der KLF200 auch schon aufgehangen. 
Nach Aus- und Einschalten ging bei mir alles wieder. ggf. müssen auch noch Perl-Libs (CRC) nachinstalliert werden.


define AlleFenster_n notify AlleFenster {if ($EVENT eq "auf") {system "perl /opt/fhem/FHEM/99_KLF200.pl 0 &";;}else{system "perl /opt/fhem/FHEM/99_KLF200.pl 1 &";;}Log 1, "notify AlleFenster_aufzu: $NAME $EVENT";;}

attr AlleFenster_n room VELUX
attr AlleFenster_n verbose 5

define AlleRolladen_n notify AlleRolladen {if ($EVENT eq "auf") {system "perl /opt/fhem/FHEM/99_KLF200.pl 9 &";;}else{system "perl /opt/fhem/FHEM/99_KLF200.pl 8 &";;}Log 1, "notify AlleRolladen_aufzu: $NAME $EVENT";;}

attr AlleRolladen_n room VELUX
attr AlleRolladen_n verbose 5

define BellaRolladen_n0 notify BellaRolladen {if ($EVENT eq '0' ) {system "perl /opt/fhem/FHEM/99_KLF200.pl 3 &";;} Log 1, "notify BellaRolladen_auf: $NAME $EVENT";;}

attr BellaRolladen_n0 room VELUX

define BellaRolladen_n50 notify BellaRolladen {if ($EVENT eq '50' ) {system "perl /opt/fhem/FHEM/99_KLF200.pl 13 &";;} Log 1, "notify 
BellaRolladen_50: $NAME $EVENT";;}

attr BellaRolladen_n50 room VELUX

define BellaRolladen_n100 notify BellaRolladen {if ($EVENT eq '100' ) {system "perl /opt/fhem/FHEM/99_KLF200.pl 2 &";;} Log 1, "notify BellaRolladen_zu: $NAME $EVENT";;}

attr BellaRolladen_n100 room VELUX

define JoergRolladen_n0 notify JoergRolladen {if ($EVENT eq '0' ) {system "perl /opt/fhem/FHEM/99_KLF200.pl 7 &";;} Log 1, "notify JoergRolladen_auf: $NAME $EVENT";;}

attr JoergRolladen_n0 room VELUX

define JoergRolladen_n50 notify JoergRolladen {if ($EVENT eq '50' ) {system "perl /opt/fhem/FHEM/99_KLF200.pl 10 &";;} Log 1, "notify JoergRolladen_50: $NAME $EVENT";;}

attr JoergRolladen_n50 room VELUX

define JoergRolladen_n100 notify JoergRolladen {if ($EVENT eq '100' ) {system "perl /opt/fhem/FHEM/99_KLF200.pl 6 &";;} Log 1, "notify JoergRolladen_zu: $NAME $EVENT";;}

attr JoergRolladen_n100 room VELUX

define JoergFenster_n notify JoergFenster {if ($EVENT eq "auf") {system "perl /opt/fhem/FHEM/99_KLF200.pl 4 &";;}else{system "perl /opt/fhem/FHEM/99_KLF200.pl 5 &";;}Log 1, "notify JoergFenster_aufzu: $NAME $EVENT";;}

attr JoergFenster_n room VELUX

define BellaFenster_n notify BellaFenster {if ($EVENT eq "auf") {system "perl /opt/fhem/FHEM/99_KLF200.pl 12 &";;}else{system "perl /opt/fhem/FHEM/99_KLF200.pl 11 &";;}Log 1, "notify JoergFenster_aufzu: $NAME $EVENT";;}

attr BellaFenster_n room VELUX

define AlleRolladen dummy
attr AlleRolladen devStateIcon zu:shutter_closed auf:shutter_open
attr AlleRolladen room VELUX
attr AlleRolladen webCmd auf:zu

define AlleFenster dummy
attr AlleFenster devStateIcon zu:fts_window_roof auf:fts_window_roof_open_2
attr AlleFenster room VELUX
attr AlleFenster webCmd auf:zu

define BellaRolladen dummy
attr BellaRolladen devStateIcon 100:shutter_closed 50:shutter_3 0:shutter_open
attr BellaRolladen room VELUX
attr BellaRolladen webCmd 0:50:100

define BellaFenster dummy
attr BellaFenster devStateIcon zu:fts_window_roof auf:fts_window_roof_open_2
attr BellaFenster room VELUX
attr BellaFenster webCmd auf:zu

define JoergRolladen dummy
attr JoergRolladen devStateIcon 100:shutter_closed 50:shutter_3 0:shutter_open
attr JoergRolladen room VELUX
attr JoergRolladen webCmd 0:50:100

define JoergFenster dummy
attr JoergFenster devStateIcon zu:fts_window_roof auf:fts_window_roof_open_2
attr JoergFenster room VELUX
attr JoergFenster webCmd auf:zu
