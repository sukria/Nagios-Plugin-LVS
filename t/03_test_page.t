use Test::More tests => 2;
use strict;
use warnings;

use Nagios::Plugin::LVS;
my $np = Nagios::Plugin::LVS->new( shortname => "my plugin");
my $page = '
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  194.yoolink.fr:https wlc persistent 50
  -> 193.yoolink.fr:https         Route   1      2          1         
  -> web2.weborama.fr:https       Local   2      0          0         
TCP  194.yoolink.fr:www wlc persistent 50
  -> 193.yoolink.fr:www           Route   1      99         200       
  -> web2.weborama.fr:www         Local   2      191        374   
';
my ($nb_active, $nb_inactive, $stats) = $np->parse_page($page);

is $nb_active, 292, "nb active is OK";
is $nb_inactive, 575, "nb inactive is OK";

