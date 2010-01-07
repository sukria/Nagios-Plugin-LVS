use Test::More tests => 2;
use strict;
use warnings;

use Nagios::Plugin::LVS;
my $np = Nagios::Plugin::LVS->new( shortname => "my plugin");

isa_ok $np, 'Nagios::Plugin::LVS';
can_ok $np, qw(new test_page retrieve_page);

