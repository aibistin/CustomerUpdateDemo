use utf8;
package Mover::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mover::Schema::Result::User

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

=head1 TABLE: C<user>

=cut

__PACKAGE__->table("user");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 username

  data_type: 'text'
  is_nullable: 1

=head2 password

  data_type: 'text'
  is_nullable: 1

=head2 employee_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 email_address

  data_type: 'text'
  is_nullable: 1

=head2 status

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 comments

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "username",
  { data_type => "text", is_nullable => 1 },
  "password",
  { data_type => "text", is_nullable => 1 },
  "employee_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "email_address",
  { data_type => "text", is_nullable => 1 },
  "status",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "comments",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 employee

Type: belongs_to

Related object: L<Mover::Schema::Result::Employee>

=cut

__PACKAGE__->belongs_to(
  "employee",
  "Mover::Schema::Result::Employee",
  { id => "employee_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 status

Type: belongs_to

Related object: L<Mover::Schema::Result::UserStatus>

=cut

__PACKAGE__->belongs_to(
  "status",
  "Mover::Schema::Result::UserStatus",
  { id => "status" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 user_roles

Type: has_many

Related object: L<Mover::Schema::Result::UserRole>

=cut

__PACKAGE__->has_many(
  "user_roles",
  "Mover::Schema::Result::UserRole",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 roles

Type: many_to_many

Composing rels: L</user_roles> -> role

=cut

__PACKAGE__->many_to_many("roles", "user_roles", "role");


# Created by DBIx::Class::Schema::Loader v0.07028 @ 2012-10-07 17:46:00
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:s5QUlAWqUCA3n6Pltut8RQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
#################################################################################
#####                       WORKSPACE BEGINS                                 ####
#################################################################################
#-------
# many_to_many():
#   args:
#     1) Name of relationship, DBIC will create accessor with this name
#     2) Name of has_many() relationship this many_to_many() is shortcut for
#     3) Name of belongs_to() relationship in model class of has_many() above
#   You must already have the has_many() defined to use a many_to_many().
#__PACKAGE__->many_to_many(roles => 'user_roles', 'role');

#-------------------------------------------------------------------------------
#  Have the 'password' column use a SHA-1 hash and 20-byte salt
#  with RFC 2307 encoding; Generate the 'check_password" method
#-------------------------------------------------------------------------------

=head2 add_columns
  Have the 'password' column use a SHA-1 hash and 20-byte salt
  with RFC 2307 encoding; Generate the 'check_password" method
=cut

__PACKAGE__->add_columns(
    'password' => {
        passphrase       => 'rfc2307',
        passphrase_class => 'SaltedDigest',
        passphrase_args  => {
            algorithm   => 'SHA-1',
            salt_random => 20.
        },
        passphrase_check_method => 'check_password',
    },
);

=head2 has_role
    Check if a user has the specified role
=cut

use Perl6::Junction qw/any/;

sub has_role {
    my ( $self, $role ) = @_;

    # Does this user posses the required role?
    return any( map { $_->role } $self->roles ) eq $role;
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
    my $self = shift;
    return $self->username || '';
}

#################################################################################
#####                       WORKSPACE ENDS                                   ####
#################################################################################

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
########################################################################################
1;
