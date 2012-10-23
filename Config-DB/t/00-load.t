#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Config::DB' ) || print "Bail out!\n";
}

diag( "Testing Config::DB $Config::DB::VERSION, Perl $], $^X" );
