package Config::DB;
use Modern::Perl;
use autodie;
use Moose;
use Moose::Util::TypeConstraints;
use namespace::autoclean;
use File::Spec;
#use Data::Dumper;
use MooseX::Types::Common::Numeric qw(
  PositiveInt PositiveOrZeroInt
  SingleDigit);
use MooseX::Types::Common::String qw(SimpleStr
  NonEmptySimpleStr
  NumericCode
  LowerCaseSimpleStr
  UpperCaseSimpleStr
  Password
  StrongPassword
  NonEmptyStr
  LowerCaseStr
  UpperCaseStr);

use MooseX::Params::Validate;
use Config::Types qw(
  AdminConfigGeneral
  AdminDBD
  AdminConfigOption
  AdminConfigOptionsHashRef
);

use Log::Log4perl;

my $log_config_file = 'configs/log.conf';
Log::Log4perl->init($log_config_file);
my $log = Log::Log4perl->get_logger(q/CSV::Files/);

#-------------------------------------------------------------------------------
#  Recommended Settings for DBIx
#  Specific for my Admin Modules and Scripts
#-------------------------------------------------------------------------------
#------ Has the databse config options
has 'database'    => ( is => 'ro', isa => 'HashRef', required => 1 );
has 'schema_name' => ( is => 'rw', isa => 'Str',     required => 0 );

has 'db_name'      => ( is => 'ro', isa => 'Str', required => 1 );
has 'db_directory' => ( is => 'ro', isa => 'Str', required => 1 );
has 'username'     => ( is => 'ro', isa => 'Str', required => 0 );
has 'password' => ( is => 'ro', isa => StrongPassword, required => 0 );
has 'dbd'      => ( is => 'ro', isa => AdminDBD,       required => 1 );
has 'pragma_foreign_keys' =>
  ( is => 'ro', isa => PositiveOrZeroInt, default => 1 );

#------ DBI options
has 'options' => ( is => 'ro', isa => 'HashRef', required => 1, );

has 'FetchHashKeyName' => ( is => 'ro', isa => 'Str', default => 'Name_lc' );
has 'RaiseError' => ( is => 'ro', isa => PositiveOrZeroInt, required => 0 );
has 'PrintError' => ( is => 'ro', isa => PositiveOrZeroInt, required => 0 );
has 'ShowErrorStatement' =>
  ( is => 'ro', isa => PositiveOrZeroInt, required => 0 );
has 'ChopBlanks' => ( is => 'ro', isa => PositiveOrZeroInt, required => 0 );
has 'AutoCommit' => ( is => 'ro', isa => PositiveOrZeroInt, required => 0 );

#

#

=head1 NAME

Config::DB - The great new Config::DB!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Generic  Config General configuration object for 
validating the Config::General Parsed Hash.
It will extrapolate configuration data pertaining to
the database and databse options. 
d
Process Configuration Options for a Databse

    use Config::DB;

    my $Db_config_object = Config::DB->new(\%parsed_config_gen);
    ...


=head1 SUBROUTINES/METHODS
=cut

#-------------------------------------------------------------------------------

=head2 around BUILDARGS 
 When passed a parsed Config::General structure ,  around BUILDARGS  will
 grab the Hashrefs for the <database> and database <options> configurations. 
 It will put them into one "Flat" Hash of Attributes to pass to Config::Db
=cut

#-------------------------------------------------------------------------------
around BUILDARGS => sub {
    my ( $orig, $class, @attrs ) = @_;

    #------ When passed a Data Structure  which is Hash ref of hashes
    #      Get the Hash of hashRefs for {database} configs and convert to
    #      a flat hash.Also keep the original hash of hashrefs
    if (   @attrs == 1
        && ( ref $attrs[0] )
        && ( exists $attrs[0]->{database} ) )
    {
        my $db_attr = $attrs[0]->{database};
        my (%flat_hash);
        $flat_hash{database} = $db_attr;    # Keep the database Hashref
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

        return $class->$orig( \%flat_hash );
    }
    else {
        #----Oh,  passed a whole hash of attributes. How dedicated
        $log->debug("Returning the original Args from Buildargs: $_[0] ");
        return $class->$orig(@_);
    }
};

#-------------------------------------------------------------------------------

=head2 validate_database_attr_hash
Validate the configuration attributes for our Database.
Returns a Hashref of validated database config attributes.
=cut

#-------------------------------------------------------------------------------

sub validate_database_attr_hash {

    my ( $self, %params ) = validated_hash(
        \@_,
        'db_name'      => { is => 'ro', isa => 'Str',          required => 1 },
        'db_directory' => { is => 'ro', isa => 'Str',          required => 1 },
        'username'     => { is => 'ro', isa => 'Str',          required => 0 },
        'password'     => { is => 'ro', isa => StrongPassword, required => 0 },
        'dbd'          => { is => 'ro', isa => AdminDBD,       required => 1 },
        'pragma_foreign_keys' =>
          { is => 'ro', isa => PositiveOrZeroInt, default => 1 },
        MX_PARAMS_VALIDAE_ALLOW_EXTRA => 1,    # Allow extra Params

    );
    return \%params;
}

#-------------------------------------------------------------------------------

=head2 validate_database_options_hash
Validate the configuration options for our Database.
Returns a Hashref of validated database config paramaters.
=cut

#-------------------------------------------------------------------------------

sub validate_database_options_hash {

    my ( $self, %options ) = validated_hash(
        \@_,
        'FetchHashKeyName' =>
          { is => 'ro', isa => 'Str', default => 'Name_lc' },
        'RaiseError' => { is => 'ro', isa => PositiveOrZeroInt, required => 0 },
        'PrintError' => { is => 'ro', isa => PositiveOrZeroInt, required => 0 },
        'ShowErrorStatement' =>
          { is => 'ro', isa => PositiveOrZeroInt, required => 0 },
        'ChopBlanks' => { is => 'ro', isa => PositiveOrZeroInt, required => 0 },
        'AutoCommit' => { is => 'ro', isa => PositiveOrZeroInt, required => 0 },
        MX_PARAMS_VALIDATE_ALLOW_EXTRA => 1,    # Allow extra Params

    );
    return \%options;
}

#-------------------------------------------------------------------------------

=head1 connect_to_schema
       Pass the DBIx schema_name Class Name or use the Class DBIx schema_name
       Connect to the database schema.
       Returns the schema object.
       my $schema_obj = 
           $ConfigDB->connect_to_schema("My::Schema")
       my $schema_obj =
           $ConfigDB->connect_to_schema()
=cut

#-------------------------------------------------------------------------------
sub connect_to_schema {
    my $self = shift;
    my $schema = shift if (@_);
    my $Schema =
         ( defined $_[0] )
      && ( length $_[0] )
      ? $self->schema_name( $_[0] )
      : $self->schema_name;
    confess "Must supply a Schema name."
      unless ( ( defined $Schema )
        && ( length($Schema) ) );

    $log->debug('Database Directory is : ' . $self->db_directory);
    $log->debug('Database name is : ' .  $self->db_name);

    my $fq_db_name = File::Spec->catdir( $self->db_directory, $self->db_name );
    my $Schema_obj =
         $Schema->connect('dbi:'. $self->dbd.':'.$fq_db_name)
     || confess( 'Error Connecting to Schema. '. $!  );

    return $Schema_obj;

}

#-------------------------------------------------------------------------------

=head1 AUTHOR

Austin Kenny, C<< <aibistin_cionnaith at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-config-db at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Config-DB>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Config::DB


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Config-DB>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Config-DB>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Config-DB>

=item * Search CPAN

L<http://search.cpan.org/dist/Config-DB/>

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

1;    # End of Config::DB
