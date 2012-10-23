use utf8;
package Mover::Schema::Result::Employee;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mover::Schema::Result::Employee

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

=head1 TABLE: C<employee>

=cut

__PACKAGE__->table("employee");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 job_title

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 reports_to

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 last_name

  data_type: 'text'
  is_nullable: 1

=head2 first_name

  data_type: 'text'
  is_nullable: 1

=head2 m_i

  data_type: 'text'
  is_nullable: 1

=head2 prefix

  data_type: 'text'
  is_nullable: 1

=head2 suffix

  data_type: 'text'
  is_nullable: 1

=head2 alias

  data_type: 'text'
  is_nullable: 1

=head2 address_1

  data_type: 'text'
  is_nullable: 1

=head2 address_2

  data_type: 'text'
  is_nullable: 1

=head2 city

  data_type: 'text'
  is_nullable: 1

=head2 state

  data_type: 'text'
  is_nullable: 1

=head2 zip

  data_type: 'text'
  is_nullable: 1

=head2 phone_1

  data_type: 'text'
  is_nullable: 1

=head2 phone_2

  data_type: 'text'
  is_nullable: 1

=head2 phone_3

  data_type: 'text'
  is_nullable: 1

=head2 email_1

  data_type: 'text'
  is_nullable: 1

=head2 email_2

  data_type: 'text'
  is_nullable: 1

=head2 department

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 status

  data_type: 'integer'
  is_foreign_key: 1
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
  "job_title",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "reports_to",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "last_name",
  { data_type => "text", is_nullable => 1 },
  "first_name",
  { data_type => "text", is_nullable => 1 },
  "m_i",
  { data_type => "text", is_nullable => 1 },
  "prefix",
  { data_type => "text", is_nullable => 1 },
  "suffix",
  { data_type => "text", is_nullable => 1 },
  "alias",
  { data_type => "text", is_nullable => 1 },
  "address_1",
  { data_type => "text", is_nullable => 1 },
  "address_2",
  { data_type => "text", is_nullable => 1 },
  "city",
  { data_type => "text", is_nullable => 1 },
  "state",
  { data_type => "text", is_nullable => 1 },
  "zip",
  { data_type => "text", is_nullable => 1 },
  "phone_1",
  { data_type => "text", is_nullable => 1 },
  "phone_2",
  { data_type => "text", is_nullable => 1 },
  "phone_3",
  { data_type => "text", is_nullable => 1 },
  "email_1",
  { data_type => "text", is_nullable => 1 },
  "email_2",
  { data_type => "text", is_nullable => 1 },
  "department",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "status",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
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

=head2 customers_created_by

Type: has_many

Related object: L<Mover::Schema::Result::Customer>

=cut

__PACKAGE__->has_many(
  "customers_created_by",
  "Mover::Schema::Result::Customer",
  { "foreign.created_by" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 customers_updated_by

Type: has_many

Related object: L<Mover::Schema::Result::Customer>

=cut

__PACKAGE__->has_many(
  "customers_updated_by",
  "Mover::Schema::Result::Customer",
  { "foreign.updated_by" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 department

Type: belongs_to

Related object: L<Mover::Schema::Result::Department>

=cut

__PACKAGE__->belongs_to(
  "department",
  "Mover::Schema::Result::Department",
  { id => "department" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 employee_reports_to

Type: has_many

Related object: L<Mover::Schema::Result::Employee>

=cut

__PACKAGE__->has_many(
  "employee_reports_to",
  "Mover::Schema::Result::Employee",
  { "foreign.reports_to" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 employees_created_by

Type: has_many

Related object: L<Mover::Schema::Result::Employee>

=cut

__PACKAGE__->has_many(
  "employees_created_by",
  "Mover::Schema::Result::Employee",
  { "foreign.created_by" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 employees_updated_by

Type: has_many

Related object: L<Mover::Schema::Result::Employee>

=cut

__PACKAGE__->has_many(
  "employees_updated_by",
  "Mover::Schema::Result::Employee",
  { "foreign.updated_by" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 estimate_estimators

Type: has_many

Related object: L<Mover::Schema::Result::Estimate>

=cut

__PACKAGE__->has_many(
  "estimate_estimators",
  "Mover::Schema::Result::Estimate",
  { "foreign.estimator_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 estimates_created_by

Type: has_many

Related object: L<Mover::Schema::Result::Estimate>

=cut

__PACKAGE__->has_many(
  "estimates_created_by",
  "Mover::Schema::Result::Estimate",
  { "foreign.created_by" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 estimates_updated_by

Type: has_many

Related object: L<Mover::Schema::Result::Estimate>

=cut

__PACKAGE__->has_many(
  "estimates_updated_by",
  "Mover::Schema::Result::Estimate",
  { "foreign.updated_by" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 job_title

Type: belongs_to

Related object: L<Mover::Schema::Result::JobTitle>

=cut

__PACKAGE__->belongs_to(
  "job_title",
  "Mover::Schema::Result::JobTitle",
  { id => "job_title" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 report_to

Type: belongs_to

Related object: L<Mover::Schema::Result::Employee>

=cut

__PACKAGE__->belongs_to(
  "report_to",
  "Mover::Schema::Result::Employee",
  { id => "reports_to" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 status

Type: belongs_to

Related object: L<Mover::Schema::Result::EmployeeStatus>

=cut

__PACKAGE__->belongs_to(
  "status",
  "Mover::Schema::Result::EmployeeStatus",
  { id => "status" },
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

=head2 users

Type: has_many

Related object: L<Mover::Schema::Result::User>

=cut

__PACKAGE__->has_many(
  "users",
  "Mover::Schema::Result::User",
  { "foreign.employee_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07028 @ 2012-10-07 17:46:00
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:eJU455Teg2mg2lRySHEfYA

# You can replace this text with custom code or comments, and it will be preserved on regeneration
#################################################################################
#####                       WORKSPACE BEGINS                                 ####
#################################################################################

#-------------------------------------------------------------------------------
# Enable automatic date handling
#-------------------------------------------------------------------------------

=head2 add_columns
 Enable automatic date handling
=cut

__PACKAGE__->add_columns(
    "created", { data_type => 'timestamp', set_on_create => 1 },
    "updated",
    { data_type => 'timestamp', set_on_create => 1, set_on_update => 1 },
);

=head2 department

Type: belongs_to

This will be done automatically the next time I update the database

Related object: L<mover::Schema::Result::Department>

=cut

__PACKAGE__->belongs_to(
    "department",
    "mover::Schema::Result::Department",
    { id => "department" },
    {
        is_deferrable => 1,
        join_type     => "LEFT",
        on_delete     => "RESTRICT",
        on_update     => "RESTRICT",
    },
);

#-------------------------------------------------------------------------------
#  Row-level helper methods
#-------------------------------------------------------------------------------

=head2 full_name
   Create full employee name from the name element columns.
   Join first name with last name, including prefix and suffix
   Uppercase the first initial
=cut

sub full_name {
    my ($self) = @_;

    #    return
    my $full_name =
      ( length $self->prefix )
      ? ucfirst( $self->prefix ) . ' '
      . ucfirst( $self->first_name ) . ' '
      . ucfirst( $self->last_name )
      : ucfirst( $self->first_name ) . ' ' . ucfirst( $self->last_name );
    return (
        length $self->suffix
        ? $full_name . ' ' . ucfirst $self->suffix
        : $full_name
    );
}

=head2 first_last_name
   Create employee first last name combination from name element columns.
   Join first name with last name, NOT including prefix and suffix
   Uppercase the first initial
=cut

sub first_last_name {
    my ($self) = @_;
    return
        ucfirst( $self->first_name // "Unknown" ) . ' '
      . ucfirst( $self->last_name  // "Unknown" );
}


=head2 full_name_initcaps
   Gets the employees full namer,  complete with
   Prefix,   First,  MI, Last,  Suffix
   Added Initcaps for completeness
=cut

sub full_name_initcaps {
    my ($self) = @_;

    #    return
    my $full_name =
      ( defined $self->prefix )
      ? ucfirst $self->prefix . ' '
      . ucfirst $self->first_name . ' '
      . ucfirst $self->last_name
      : ucfirst $self->first_name . ' ' . ucfirst $self->last_name;
    return (
        defined $self->suffix
        ? $full_name . ' ' . ucfirst $self->suffix
        : $full_name
    );
}

#-------------------------------------------------------------------------------
#   Matching Names
#-------------------------------------------------------------------------------

=head2 employee last name like
   A predefined search for employees with a 'LIKE' search in the string
=cut

sub last_name_like {
    my ( $self, $name_str ) = @_;

    return $self->search( { last_name => { 'like' => "%$name_str%" } } );
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
    return $self->full_name || '';
}

#-------------------------------------------------------------------------------
#  Permissions
#-------------------------------------------------------------------------------

=head2 create_allowed_by
    Can the specified user create employees
=cut

sub create_allowed_by {
    my ( $self, $user ) = @_;

    return ( $user->has_role('can_create_employee') );
}

=head2 delete_allowed_by
    Can the specified user delete the current employee
=cut

sub delete_allowed_by {
    my ( $self, $user ) = @_;

    return ( $user->has_role('can_delete_employee') );
}

=head2 update_allowed_by
    Can the specified user edit the current employee
=cut

sub update_allowed_by {
    my ( $self, $user ) = @_;

    return ( $user->has_role('can_update_employee') );
}

=head2 display_allowed_by
    Can the specified list the employees
=cut

sub display_allowed_by {
    my ( $self, $user ) = @_;

    return ( $user->has_role('can_view_employee') );
}

#################################################################################
#####                       WORKSPACE ENDS                                   ####
#################################################################################

__PACKAGE__->meta->make_immutable;

1;
