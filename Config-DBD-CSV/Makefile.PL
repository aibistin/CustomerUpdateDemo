use inc::Module::Install;

name     'Config-DBD-CSV';
all_from 'lib/Config/DBD/CSV.pm';
author   q{Austin Kenny <aibistin_cionnaith@gmail.com>};
license  'perl';

build_requires 'Test::More';
requires 'Moose';

requires 'Modern::Perl';
requires 'Moose::Util::TypeConstraints';
requires 'Config::General';
requires 'namespace::autoclean';
requires 'Data::Dumper';
requires 'Config::Types' qw(AdminConfigGeneral);
requires 'Log::Log4perl';

auto_install;

WriteAll;

