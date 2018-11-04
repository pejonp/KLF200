#!/usr/bin/perl

##############################################
# $Id: 99_KLF200.pl 0003 2018-10-16 10:10:10Z pejonp $
#
# nach der Umstellung des KLF200 auf die Version 0.2.0.0.71.0 hat sich die Schnittstelle geändert 
# das KLF200 wird jetzt über Port:51200 mit dem SLIP-Protokoll angesprochen
# die REST-API entfällt. 
# Dadurch sind laut API-Beschreibung https://www.velux.com/api/klf200 mehr Funktionen vorhanden 
#
# Autor: Jörg Köhn
# Datum: 13.10.2018
#
# 15.10.2018 pejonp
#

use warnings;
use strict;
#use utf8;
#use Digest::CRC qw(crc);
#use Digest::CRC qw(crc8);
use IO::Socket::INET;
use IO::Socket::SSL;
use Time::HiRes qw/usleep/;

 
use constant {
  SLIP_END => 'C0',
  SLIP_ESC => 'DB',
  SLIP_ESC_END => 'DC',
  SLIP_ESC_ESC => 'DD',
  GW_ACTIVATE_SCENE_REQ =>'0412',
  GW_ACTIVATE_SCENE_CFM =>'0413',
  GW_PASSWORD_ENTER_REQ =>'3000',
  GW_PASSWORD_ENTER_NTF =>'3001',
  LEER =>'00',
} ;

my $remote_host = "192.168.2.160";
my $remote_port = 51200;
my $passwd = "velux123"; 

################  
sub Login_PW($) {  
  my $password = shift;
  my $passwordleng = 32;
  my $charpw = uc(unpack "H*", $password);
  my $hlen = length($charpw);
  my $j = ($passwordleng) - $hlen/2 -1;
  my $i = 0;
  
  for ($i=0; $i <= $j; $i++) {
    $charpw = $charpw.(LEER);
  }

  $charpw = (GW_PASSWORD_ENTER_REQ).$charpw;
  $hlen = length($charpw)/2 +1 ;
  my $hex = sprintf("%04X", $hlen);
  my $crcsum = CRC_SUM( $hex.$charpw );
  my $alles =  $hex.$charpw.$crcsum;
  $alles =  SLIP_PACK($alles);
  return $alles; 
}

sub CRC_SUM($)
{
  my $h = shift;
  my $crc_t1 = pack( 'H*', $h );
  my $crcmein = Digest::CRC->new(width => 8, poly => 0x1);
  my $rr2 = $crcmein->add($crc_t1)->hexdigest;
  return $rr2;
}

sub SLIP_PACK($){
  my $h = shift;
  #$h = join( (SLIP_ESC).(SLIP_ESC_ESC), split((SLIP_ESC), $h) );
  #$h = join( (SLIP_ESC).(SLIP_ESC_END), split((SLIP_END), $h) );        
  return (SLIP_END).$h.(SLIP_END);
}

sub ACTIV_SCENE_CMD($){
               my $S_Id = shift;
               my $wSessionID    = '1234';
               my $CommandOriginator  = '01'; #  0x01: "USER",
               my $PriorityLevel      = '03';  #     3: 'User Level 2',
               my $bSceneID           =  sprintf("%02X", $S_Id);
               print " SceneID    : ".$S_Id."\n" ;
               print " SceneID hex: ".$bSceneID."\n" ;
               my $Velocity           = '00'; # 0: 'DEFAULT',
               my $hlen;
        my $string =  (GW_ACTIVATE_SCENE_REQ).$wSessionID.$CommandOriginator.$PriorityLevel.$bSceneID.$Velocity ;
        print " CMD: ".$string."\n";
        $hlen = length($string)/2 +1 ;
        print " lenght :".$hlen."\n";
        my $hex = sprintf("%04X", $hlen);
        my $crcsum = CRC_SUM( $hex.$string );
        my $alles =  $hex.$string.$crcsum;
        print " alles_CMD: ".$alles."\n";
        $alles =  SLIP_PACK($alles);
        print " Slip_Frame: ".$alles."\n"; 
        return $alles; 
       
}


sub SEND_CMD($) {
my $scene = shift;
my $response = "";
my $ubytes;


  my $socket = new IO::Socket::SSL (
    PeerAddr => $remote_host,
    PeerPort => $remote_port,
    Proto => 'tcp',
    Domain => AF_INET,
    SSL_verify_mode => 0,
    Reuse     => 1,
    Blocking  => 0 
    );

die "cannot connect to the server :$!: :$SSL_ERROR:\n" unless $socket;
print "connected to the server\n";

# check server cert.
my ($subject_name, $issuer_name, $cipher);
if( ref($socket) eq "IO::Socket::SSL") {
$subject_name = $socket->peer_certificate("subject");
$issuer_name = $socket->peer_certificate("issuer");
$cipher = $socket->get_cipher();
}
warn "cipher: $cipher.\n", "server cert:\n", 
"\t '$subject_name' \n\t '$issuer_name'.\n\n";

#########################    
$socket->autoflush();
#$socket->blocking(0);

my $login = Login_PW($passwd);
print " PW: ".$login."\n";
#$login =  SLIP_PACK($login);
#print " Slip_Frame: ".$login."\n"; 
my $bytes = pack("H*", $login);
my $size = $socket->print($bytes);

$socket->read($response, 1024);
$ubytes = unpack("H*", $response);
print "received response: $ubytes\n"; 


my $cmd_1= ACTIV_SCENE_CMD($scene);
print " CMD: ".$cmd_1."\n";
$bytes = pack("H*", $cmd_1);
$size = $socket->print($bytes);

$socket->read($response, 1024);
 $ubytes = unpack("H*", $response);
print "received response: $ubytes\n";


shutdown($socket, 1); 
$socket->close(); 
return $ubytes;
}    
#############

# main
##########

my $rc = eval
     {
      require Digest::CRC;
      Digest::CRC->import();
      1;
     };
 
 if($rc) # test ob  Digest::CRC geladen wurde
     {
         print "Digest::CRC:OK \n\n" ;
     }else
     {
         print "Modul Digest::CRC fehlt: cpan install Digest::CRC or apt-get install libdigest-crc-perl \n\n" ;
         exit;
     }
 
 $rc = eval
     {
      require IO::Socket::SSL;
      IO::Socket::SSL->import();
      1;
     };

if($rc) # test ob  IO::Socket::SSL geladen wurde
     {
         print "IO::Socket::SSL:OK \n\n" ;
     }else
     {
         print "Modul IO::Socket::SSL fehlt: cpan install IO::Socket::SSL or apt-get install libio-socket-ssl-perl \n\n" ;
         exit;
     }


my $Scene_ID;
my $num_of_params = @ARGV;

if ($num_of_params < 1)
{
    print "\nUsage: test.pl scene_ID \n";
    exit;
} else {
    $Scene_ID = $ARGV[0];
}


my $inf = SEND_CMD($Scene_ID) ;
print "  response: $inf\n"; 
