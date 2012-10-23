#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Admin::Config' ) || print "Bail out!\n";
}

diag( "Testing Admin::Config $Admin::Config::VERSION, Perl $], $^X" );
