package Nagios::Plugin::LVS;

use strict;
use warnings;

use Nagios::Plugin; # needed for the constants import
use base 'Nagios::Plugin';

my $ipvsadm = '/sbin/ipvsadm';

sub retrieve_page {
    my ($self) = @_;
    my $page = `$ipvsadm`;
    return $page;
}
 
# If LVS is running fine, we should not have a table with 0 active connection
sub test_page {
    my ($self, $page) = @_;
    my ($total_active, $total_inactive, $stats) = $self->parse_page($page);

    if ($total_active == 0) {
        $self->nagios_exit( CRITICAL, "0 active connection" );
    }
    $self->nagios_exit( OK, "LVS is running ($stats)" );
}

# We should have something like this in $page
#
# IP Virtual Server version 1.2.1 (size=4096)
# Prot LocalAddress:Port Scheduler Flags
# -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
# TCP  vip.domain.com:protocol wlc persistent 50
# -> xxx.domain.com:protocol       Route   1      2          1         
# -> yyy.domain.com:protocol       Local   2      0          0         
# TCP  vip.domain.com:www wlc persistent 50
# -> xxx.domain.com:www            Route   1      99         200       
# -> yyy.domain.com:www            Local   2      191        374      
sub parse_page {
    my ($self, $page) = @_;
    
    my $total_conn = 0;
    my $total_active = 0;
    my $total_inactive = 0;

    foreach my $line (split /\n/, $page) {
        if ($line =~ /^\s*\-\>\s+(\S+:\S+)\s+\w+\s+(\d+)\s+(\d+)\s+(\d+)/) {
            my ($host, $weight, $active, $inactive) = ($1, $2, $3, $4);
            $total_active   += $active;
            $total_inactive += $inactive;
        }
    }
    
    my $stats = "conn: $total_active active, $total_inactive inactive";
    return ($total_active, $total_inactive, $stats);
}

1;
