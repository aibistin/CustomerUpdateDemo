use utf8;
package Mover::Schema::Result::Estimate;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mover::Schema::Result::Estimate

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<estimate>

=cut

__PACKAGE__->table("estimate");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 customer_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 estimator_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 estimate_date

  data_type: 'timestamp'
  is_nullable: 1

=head2 estimate_time

  data_type: 'timestamp'
  is_nullable: 1

=head2 move_date

  data_type: 'timestamp'
  is_nullable: 1

=head2 move_time

  data_type: 'timestamp'
  is_nullable: 1

=head2 from_address_1

  data_type: 'text'
  is_nullable: 1

=head2 from_address_2

  data_type: 'text'
  is_nullable: 1

=head2 from_city

  data_type: 'text'
  is_nullable: 1

=head2 from_state

  data_type: 'text'
  is_nullable: 1

=head2 from_zip

  data_type: 'text'
  is_nullable: 1

=head2 to_address_1

  data_type: 'text'
  is_nullable: 1

=head2 to_address_2

  data_type: 'text'
  is_nullable: 1

=head2 to_city

  data_type: 'text'
  is_nullable: 1

=head2 to_state

  data_type: 'text'
  is_nullable: 1

=head2 to_zip

  data_type: 'text'
  is_nullable: 1

=head2 comments

  data_type: 'text'
  is_nullable: 1

=head2 created

  data_type: 'timestamp'
  is_nullable: 1

=head2 created_by

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 updated

  data_type: 'timestamp'
  is_nullable: 1

=head2 updated_by

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "customer_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "estimator_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "estimate_date",
  { data_type => "timestamp", is_nullable => 1 },
  "estimate_time",
  { data_type => "timestamp", is_nullable => 1 },
  "move_date",
  { data_type => "timestamp", is_nullable => 1 },
  "move_time",
  { data_type => "timestamp", is_nullable => 1 },
  "from_address_1",
  { data_type => "text", is_nullable => 1 },
  "from_address_2",
  { data_type => "text", is_nullable => 1 },
  "from_city",
  { data_type => "text", is_nullable => 1 },
  "from_state",
  { data_type => "text", is_nullable => 1 },
  "from_zip",
  { data_type => "text", is_nullable => 1 },
  "to_address_1",
  { data_type => "text", is_nullable => 1 },
  "to_address_2",
  { data_type => "text", is_nullable => 1 },
  "to_city",
  { data_type => "text", is_nullable => 1 },
  "to_state",
  { data_type => "text", is_nullable => 1 },
  "to_zip",
  { data_type => "text", is_nullable => 1 },
  "comments",
  { data_type => "text", is_nullable => 1 },
  "created",
  { data_type => "timestamp", is_nullable => 1 },
  "created_by",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "updated",
  { data_type => "timestamp", is_nullable => 1 },
  "updated_by",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 created_by

Type: belongs_to

Related object: L<Mover::Schema::Result::Employee>

=cut

__PACKAGE__->belongs_to(
  "created_by",
  "Mover::Schema::Result::Employee",
  { id => "created_by" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 customer

Type: belongs_to

Related object: L<Mover::Schema::Result::Customer>

=cut

__PACKAGE__->belongs_to(
  "customer",
  "Mover::Schema::Result::Customer",
  { id => "customer_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 estimator

Type: belongs_to

Related object: L<Mover::Schema::Result::Employee>

=cut

__PACKAGE__->belongs_to(
  "estimator",
  "Mover::Schema::Result::Employee",
  { id => "estimator_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 updated_by

Type: belongs_to

Related object: L<Mover::Schema::Result::Employee>

=cut

__PACKAGE__->belongs_to(
  "updated_by",
  "Mover::Schema::Result::Employee",
  { id => "updated_by" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07028 @ 2012-10-07 17:46:00
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:nnX8+xA6Cxkf7nR1VTutPg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
#################################################################################
#####                       WORKSPACE BEGINS                                 ####
#################################################################################
#use Log::Log4perl qw(:easy);
#-------------------------------------------------------------------------------
#  Set Up Logging
#-------------------------------------------------------------------------------
#my $LOG_CONFIG_FILE = 'log_mover.conf';

#Log::Log4perl->init($LOG_CONFIG_FILE);
#my $log = Log::Log4perl->get_logger("Log::Mover");

use Regexp::Common qw(time);
use lib '../../Model/Valid/';
use MyDate;

#------- Constant types

#todo Get list of valid time zone strings.
my $LOCAL_TZ   = 'America/New_York';
my $DEFAULT_TZ = 'UTC';

#-------------------------------------------------------------------------------
#   Enable automatic date handling
#   Stored in UTC time zone. Can display in Local Time Zone
#-------------------------------------------------------------------------------
__PACKAGE__->add_columns(
    "created",

    {
        data_type     => 'timestamp',
        set_on_create => 1 },
    "updated",
    {
        data_type     => 'timestamp',
        set_on_create => 1,
        set_on_update => 1
    },
);

#-------------------------------------------------------------------------------
#   Format the estimate date into DateTime object
#-------------------------------------------------------------------------------

=head2 estimate_date_datetime
   Format the estimate date into DateTime object
   Always Local Time Zone 
=cut

sub estimate_date_datetime {
    my ($self) = @_;
    return undef if ( not defined $self->estimate_date );
    return ( MyDate->format_date_time_tz( $self->estimate_date, $LOCAL_TZ ) )
      ->set_time_zone($LOCAL_TZ);
}

=head2 estimate_time_datetime
   Convert the estimate date and time to datetime
   Return a DateTime object with estimate Time
   (Called by tt)
   Always Local Time Zone 
=cut

sub estimate_time_datetime {
    my ($self) = @_;
    return undef if ( not defined $self->estimate_time );

    return ( MyDate->format_date_time_tz( $self->estimate_time, $LOCAL_TZ ) )
      ->set_time_zone($LOCAL_TZ);
    undef;
}

=head2 move_date_datetime
   Convert the move date to datetime format
   Always Local Time Zone 
=cut

sub move_date_datetime {
    my ($self) = @_;
    return undef if ( not defined $self->move_date );

    return ( MyDate->format_date_time_tz( $self->move_date, $LOCAL_TZ ) )
      ->set_time_zone($LOCAL_TZ);
    undef;
}

=head2 move_time_datetime
   Convert the move time to datetime format
   Always Local Time Zone 
=cut

sub move_time_datetime {
    my ($self) = @_;
    return undef if ( not defined $self->move_time );

    return ( MyDate->format_date_time_tz( $self->move_time, $LOCAL_TZ ) )
      ->set_time_zone($LOCAL_TZ);
    undef;
}

=head2 created_datetime
   Convert the Estimate created date to datetime format
   Stored in UTC time zone. Display in Local Time Zone
=cut

sub created_datetime {
    my ($self) = @_;
    return undef if ( not defined $self->created );

    return ( MyDate->format_date_time_tz( $self->created, $DEFAULT_TZ ) )
      ->set_time_zone($LOCAL_TZ);
    undef;
}

=head2 updated_datetime
   Convert the Estimate Updated date to datetime format
   Stored in UTC time zone. Display in Local Time Zone
=cut

sub updated_datetime {
    my ($self) = @_;
    return undef if ( not defined $self->updated );

    return ( MyDate->format_date_time_tz( $self->updated, $DEFAULT_TZ ) )
      ->set_time_zone($LOCAL_TZ);
    undef;
}
###############################################################
# Create Estimates
###############################################################

###############################################################
# List Estimates
###############################################################

=head2 author_count
    
    Return the number of estimates
    
=cut

sub estimate_count {
    my ($self) = @_;

# Use the 'many_to_many' relationship to fetch all of the authors for the current
# and the 'count' method in DBIx::Class::ResultSet to get a SQL COUNT
    return $self->estimate->count;
}

#-------------------------------------------------------------------------------
#  Permissions
#-------------------------------------------------------------------------------

=head2 create_allowed_by
    Can the specified user create estimates
=cut

sub create_allowed_by {
    my ( $self, $user ) = @_;

    #    return ($user->has_role('admin');
    return ( $user->has_role('can_create_estimate') );

    #    return undef;
}

=head2 delete_allowed_by
    Can the specified user delete the current estimate
=cut

sub delete_allowed_by {
    my ( $self, $user ) = @_;

    #    return ($user->has_role('admin');
    return ( $user->has_role('can_delete_estimate') );

    #    return undef;
}

=head2 update_allowed_by
    Can the specified user edit the current estimate
=cut

sub update_allowed_by {
    my ( $self, $user ) = @_;

    return ( $user->has_role('can_update_estimate') );

    #    return $user->has_role('admin');
    #    return undef;
}

=head2 display_allowed_by
    Can the specified list the estimates
=cut

sub display_allowed_by {
    my ( $self, $user ) = @_;

    return ( $user->has_role('can_view_estimate') );

    #    return $user->has_role('admin');
    #    return undef;
}

#-------------------------------------------------------------------------------
#  Displays more detailed information about this record
#  when using Autocrud
#-------------------------------------------------------------------------------

=head2 display_name
    AUTOCRUD 
    Better displaying of columns that reference other tables with Autocrud
=cut

sub display_name {
    my ($self) = @_;
    return $self->estimator()->full_name() || '';
}

###############################################################
# Formatting
###############################################################

#
#################################################################################
#####                       WORKSPACE ENDS                                   ####
#################################################################################
#------
__PACKAGE__->meta->make_immutable;
1;
