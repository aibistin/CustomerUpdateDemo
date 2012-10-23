package Admin::Config;
use Modern::Perl;
use Moose;
use Moose::Util::TypeConstraints;
use Config::General;
use namespace::autoclean;
use Data::Dumper;
use Config::Types qw(
  AdminConfigGeneral
);

use Log::Log4perl;
my $log_config_file = 'configs/log.conf';
Log::Log4perl->init($log_config_file);
my $log = Log::Log4perl->get_logger(q/CSV::Files/);

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#  Attrs
#-------------------------------------------------------------------------------
has 'AdminConfig'     => ( is => 'rw', isa => 'Object', required => 0 );
has 'ConfigFile'      => ( is => 'rw', isa => 'Str',    required => 0 );
has 'ExtendedAccess'  => ( is => 'rw', isa => 'Int',    default  => 1 );
has 'InterPolateVars' => ( is => 'rw', isa => 'Int',    default  => 1 );
has 'AutoTrue'        => ( is => 'rw', isa => 'Int',    required => 0 );
has 'LowerCaseNames'  => ( is => 'rw', isa => 'Int',    default  => 1 );
has 'UTF8'            => ( is => 'rw', isa => 'Int',    default  => 1 );
has 'UTF8'            => ( is => 'rw', isa => 'Int',    default  => 1 );

#Dont Use this yet
#has 'config_data' => (
#    is       => 'rw',
#    isa      => AdminConfigGeneral,
#    required => 0,
#    coerce   => 1,
#);

#-------------------------------------------------------------------------------
#  Methods
#-------------------------------------------------------------------------------

=head1 NAME

Admin::Config - Flexible Config::General object typr for Admin Scripts

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Creates a Configure::General Object for Administation 
scripts. 

Perhaps a little code snippet.

    use Admin::Config;

    my $admin_config = Admin::Config->new();
    ...


=head1 SUBROUTINES/METHODS


=head2 around BUILDARGS 
=cut

=head2 BUILD
  Create a Config::General (AdminConfig) object passing it all the 
  options and file names.
  Create parsed Config::General datai HashRef.
=cut

sub BUILD {
    my $self = shift;

    my $Config =
        Config::General->new(
            -ConfigFile      => $self->ConfigFile,
            -ExtendedAccess  => $self->ExtendedAccess,
            -InterPolateVars => $self->InterPolateVars,
            -AutoTrue        => $self->AutoTrue,
            -LowerCaseNames  => $self->LowerCaseNames,
            -UTF8            => $self->UTF8,
        );
        $self->AdminConfig($Config);
}

=head2 getall_admin
    Returns a Hash With the Parsed Config Data
=cut

sub getall_admin {
    my $self = shift;
    return $self->AdminConfig->getall;
}

=head1 AUTHOR

Austin Kenny, C<< <aibistin_cionnaith at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-admin-config at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Admin-Config>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Admin::Config


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Admin-Config>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Admin-Config>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Admin-Config>

=item * Search CPAN

L<http://search.cpan.org/dist/Admin-Config/>

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
1;    # End of Admin::Config
