#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Config::DBD::CSV' ) || print "Bail out!\n";
}

diag( "Testing Config::DBD::CSV $Config::DBD::CSV::VERSION, Perl $], $^X" );
