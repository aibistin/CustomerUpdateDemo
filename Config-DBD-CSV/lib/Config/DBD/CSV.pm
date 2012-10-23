package Config::DBD::CSV;
use Modern::Perl;
use autodie;
use Moose;
use Moose::Util::TypeConstraints;
use namespace::autoclean;
use File::Spec;
use Data::Dumper;
use DBI;
use MooseX::Types::Common::Numeric qw(
  PositiveInt PositiveOrZeroInt
  SingleDigit);
use MooseX::Types::Common::String qw(SimpleStr
  StrongPassword
);

use MooseX::Params::Validate;
use Config::Types v0.02 qw(
  AdminDBD
);

use Log::Log4perl;
my $log_config_file = "configs/log.conf";
Log::Log4perl->init($log_config_file);
my $log = Log::Log4perl->get_logger(q/CSV::Files/);

#-------------------------------------------------------------------------------
#  Recommended Settings DBD::CSV
#  Settings come from Config::General Config file
#  Specific for my Admin Modules and Scripts
#-------------------------------------------------------------------------------
#------ Is it an csv Config block <csv>
has 'csv' => ( is => 'ro', isa => 'HashRef', required => 1 );

#------ Connection Attributes block <attr>
has 'attr' => ( is => 'ro', isa => 'HashRef', required => 1 );

has 'f_dbd' => ( is => 'rw', isa => AdminDBD, default => 'CSV' );
has 'f_dir'    => ( is => 'rw', isa => 'Str', required => 0 );
has 'f_schema' => ( is => 'rw', isa => 'Str', required => 0 );
has 'f_ext'    => ( is => 'rw', isa => 'Str', default  => '.csv/r' );

#    0 = no lock,  1 =shared locks,  2 = exclusive locking
has 'f_lock' => ( is => 'rw', isa => PositiveOrZeroInt, required => 0 );
has 'f_encoding' => ( is => 'rw', isa => 'Str', default => 'utf8' );

#    Default for Linux is "\n" for windows "\r\n"
has 'csv_eol'      => ( is => 'rw', isa => 'Str', required => 0);
has 'csv_sep_char' => ( is => 'rw', isa => 'Str', required => 0 );

has 'csv_quote_char'  => ( is => 'rw', isa => 'Str', required => 0 );
has 'csv_escape_char' => ( is => 'rw', isa => 'Str', required => 0);

#     Useful for using    'Text::CSV_XS
has 'csv_class_char' => ( is => 'rw', isa => 'Str', required => 0 );

#       Distinguish between empty string " "  and empty cell "".Latter is
#       undef
has 'csv_null' => ( is => 'rw', isa => 'Str', required  => 0 );

#       Table specific csv options - deferrs to text::CSV_XS
has 'csv_tables' => ( is => 'rw', isa => 'HashRef', required => 0 );

#-------------------------------------------------------------------------------
#  DBI options <options>
#-------------------------------------------------------------------------------
has 'options' => ( is => 'ro', isa => 'HashRef', required => 0, );

has 'RaiseError' => ( is => 'rw', isa => PositiveOrZeroInt, required => 0 );
has 'PrintError' => ( is => 'rw', isa => PositiveOrZeroInt, required => 0 );

has 'FetchHashKeyName' => ( is => 'rw', isa => 'Str', default => 'Name_lc' );
has 'ShowErrorStatement' =>
  ( is => 'rw', isa => PositiveOrZeroInt, required => 0 );
has 'ChopBlanks' => ( is => 'rw', isa => PositiveOrZeroInt, required => 0 );
has 'AutoCommit' => ( is => 'rw', isa => PositiveOrZeroInt, default => 1 );

=head1 NAME

Config::DBD::CSV - The great new Config::DBD::CSV!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS
Passed the parsed Config::General data structure. 
Extrapolates the <csv> attributes and <csv> DBI
<options> for specified CSV file.

    use Config::DBD::CSV;

    my $Csv_config_object = Config::DBD::CSV->new(\%$parsed_config_general)


#-------------------------------------------------------------------------------
#  Methods
#-------------------------------------------------------------------------------

=head1 SUBROUTINES/METHODS
=cut

#-------------------------------------------------------------------------------

=head2 around BUILDARGS 
 When passed a parsed Config::General structure ,around BUILDARGS  will
 grab the Hashrefs for the <csv> and CSV file <options>.
 It will put them into one "Flat" Hash of Attributes to pass to
 Config::DBD::CSV
=cut

#-------------------------------------------------------------------------------
around BUILDARGS => sub {
    my ( $orig, $class, @attrs ) = @_;

    #------ When passed a Data Structure  which is Hash ref of hashes
    #      Get the Hash of hashRefs for {csv} configs and convert to
    #      a flat hash.Also keep the original hash (s) of hashrefs

    if (   @attrs == 1
        && ( ref $attrs[0] )
        && ( exists $attrs[0]->{csv} ) )
    {
        my $db_attr = $attrs[0]->{csv};
        my (%flat_hash);
        $flat_hash{csv} = $db_attr;    # Keep the csv Hashref
        for my $dbk ( keys %$db_attr ) {
            $flat_hash{$dbk} = $db_attr->{$dbk};
            if ( ref( $db_attr->{$dbk} ) eq 'HASH' ) {
                my $dbk_jr = $db_attr->{$dbk};
                for my $opt ( keys(%$dbk_jr) ) {
                    $flat_hash{$opt} = $dbk_jr->{$opt};
                }
            }
        }

  #        $log->debug( "Returning Flat Hash:  " . join "\n", keys %flat_hash );
        $log->debug('Returning a Flat hash of attributes for Config::DBD');

        return $class->$orig( \%flat_hash );
    }
    else {
        #----Oh,  passed a whole hash of attributes. How dedicated
        $log->debug("Returning the original Args from Buildargs: $_[0] ");
        return $class->$orig(@_);
    }
};

#-------------------------------------------------------------------------------

=head2 get_connection_attributes
Get the DBD::CSV connection attributes and options and return them as a HashRef.
=cut

#-------------------------------------------------------------------------------

sub get_connection_attributes {
    my ($self) = @_;
    my %conn_attr;

    my $meta = $self->meta();

    for my $attr ( $meta->get_all_attributes ) {
        my $attr_name = $attr->name();

        #----- Get the Scalar attributes only
        ( !ref( $self->$attr_name() ) )
          && ( defined $self->$attr_name() )
          && ( $conn_attr{$attr_name} = $self->$attr_name() );
    }

    #    $log->debug(
    #        "Returning the Attributes made by Meta : " . Dumper(%conn_attr) );

    return \%conn_attr;
}

#-------------------------------------------------------------------------------

=head2
  Connect to the DBD::CSV . 
  No username or password for any CSV file.
  Return $dbh for the CSV::DBI
=cut

#-------------------------------------------------------------------------------
sub connect_to_csv {
    my $self = shift;

    my $csv_attr = $self->get_connection_attributes;
    my $csv_dbd  = $self->f_dbd;

#    $log->debug( "Inside DBD::CSV. Csv attributes are. " . Dumper($csv_attr) );

    my ($dbh) = DBI->connect(
        "dbi:$csv_dbd:", undef, undef,
        $csv_attr,    #Hashref with attributes
    );

    $log->debug("Returning the dbh from connect to csv.");

    return $dbh;
}

#-------------------------------------------------------------------------------

=head1 AUTHOR

Austin Kenny, C<< <aibistin_cionnaith at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-config-dbd-csv at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Config-DBD-CSV>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Config::DBD::CSV


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Config-DBD-CSV>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Config-DBD-CSV>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Config-DBD-CSV>

=item * Search CPAN

L<http://search.cpan.org/dist/Config-DBD-CSV/>

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
1;    # End of Config::DBD::CSV
