package Config::Types;
use 5.006;
use Moose;
use Moose::Util::TypeConstraints;
use Config::General;
use Email::Valid;
use namespace::autoclean;

use MooseX::Params::Validate;

#use MooseX::Types::Common::Numeric qw(
#  PositiveNum PositiveOrZeroNum
#  PositiveInt PositiveOrZeroInt
#  NegativeNum NegativeOrZeroNum
#  NegativeInt NegativeOrZeroInt
#  SingleDigit);
#
#qw(
#    ArrayRefOfPositiveInt
#    ArrayRefOfAtLeastThreeNegativeInts
#    LotsOfInnerConstraints
#    StrOrArrayRef
#    MyDateTime
use MooseX::Types -declare => [
    qw(
      AdminConfigGeneral
      AdminDBD
      AdminConfigOption
      AdminConfigOptionsHashRef
      AdminEmail
      MoverDay
      )
];

use Log::Log4perl;
my $log_config_file = 'configs/log.conf';
Log::Log4perl->init($log_config_file);
my $log = Log::Log4perl->get_logger(q/CSV::Files/);

#------  Import Moose types as Constants
use MooseX::Types::Moose qw/Object Str Int HashRef FileHandle ScalarRef/;

#-------------------------------------------------------------------------------
#  String Types
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#          ConfigGeneral Type
#-------------------------------------------------------------------------------
subtype AdminConfigGeneral, as Object,
  where { $_->isa('Config::General') },
  message { "ConfigGeneral dosent look too much like a General or a Config." };

#
#----- Coerce for 1] File Handle,  2] Literal or 3] File Name as a string
#      4] Hashref
coerce AdminConfigGeneral, from FileHandle, via {
    Config::General->new( { -ConfigFile, \$_ } );
}

=> from ScalarRef,
  via {
    $log->debug( "Inside Coerce Scalarref" . $_ );
    Config::General->new( { -String, $_ } );
}

=> from Str,
  via {
    $log->debug( "Inside Coerce String  Configfile " . $_ );
    Config::General->new( { -ConfigFile => $_, } );
  } => from Str,
  via {
    $log->debug( "Inside Coerce String " . $_ );
    Config::General->new($_);
}

, from HashRef, via {
    $log->debug( "Inside Coerce Hashref " . $_ );
    Config::General->new($_);
};

#-------------------------------------------------------------------------------
#         DBD types
#todo   Add More DBD's
#-------------------------------------------------------------------------------
subtype AdminDBD, as Str,
  where { $_ ~~ [qw/ SQLite mysql mSQL CSV Oracle SQLAnywhere  Pg /] },
  message {
"Config processing does not recognise $_ DBD name. Check name and add to list of DBs if necessary.";
  };

#-------------------------------------------------------------------------------
#  Config General Options
#-------------------------------------------------------------------------------

enum AdminConfigOption, qw(
  -ConfigFile
  -String
  -ConfigHash
  -AllowMultiOptions
  -ExtendedAccess
  -AutoTrue
  -LowerCaseNames
  -InterPolateVars
  -UTF8
  -SaveSorted
  -ApacheCompatible
  -StrictObjects
);

#-----  Hash of Valid Config Options
subtype AdminConfigOptionsHashRef, as HashRef,
  where { $_ ~~ AdminConfigOption },
  message { "$_ contains invalid Config::General Options" };

#-------------------------------------------------------------------------------
#  Email
#-------------------------------------------------------------------------------

subtype AdminEmail ,  as Str ,  where { Email::Valid->address($_) } , 
  message { "$_ is not a valid email address" };
#-------------------------------------------------------------------------------

=head1 NAME

Config::Types - The great new Config::Types!

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02';

=head1 SYNOPSIS

Create attribute types that other configuration modules can use.

Perhaps a little code snippet.

    use Config::Types;

    my $config_types = Config::Types->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2  mover_number_to_day
 Given an integer,  returns the corresponding day of week. 
 0 => monday ...... 6 => sunday
=cut

#sub mover_number_to_day {
#    if( ref $_[0]){
#    return $number_to_day{$_[1]};
#    }
#    else{
#    return $number_to_day{$_[0]};
#    };
#    undef;
#}

=head2 function2

=cut

sub function2 {
}

=head1 AUTHOR

Austin Kenny, C<< <aibistin_cionnaith at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-config-types at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Config-Types>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Config::Types


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Config-Types>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Config-Types>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Config-Types>

=item * Search CPAN

L<http://search.cpan.org/dist/Config-Types/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Austin Kenny.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

__PACKAGE__->meta->make_immutable;
1;    # End of Config::Types
