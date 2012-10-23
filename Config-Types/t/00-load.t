#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Config::Types' ) || print "Bail out!\n";
}

diag( "Testing Config::Types $Config::Types::VERSION, Perl $], $^X" );
