use utf8;
package Mover::Schema::Result::UserRole;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Mover::Schema::Result::UserRole

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

=head1 TABLE: C<user_role>

=cut

__PACKAGE__->table("user_role");

=head1 ACCESSORS

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 role_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "role_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</user_id>

=item * L</role_id>

=back

=cut

__PACKAGE__->set_primary_key("user_id", "role_id");

=head1 RELATIONS

=head2 role

Type: belongs_to

Related object: L<Mover::Schema::Result::Role>

=cut

__PACKAGE__->belongs_to(
  "role",
  "Mover::Schema::Result::Role",
  { id => "role_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 user

Type: belongs_to

Related object: L<Mover::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "Mover::Schema::Result::User",
  { id => "user_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07028 @ 2012-10-07 17:46:00
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:O1NdZz1ZpaGx1Gc9t120LA


# You can replace this text with custom code or comments, and it will be preserved on regeneration

#-------------------------------------------------------------------------------
#  Workspace Begins
#-------------------------------------------------------------------------------




















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
       return $self->role_id || '';
}


#-------------------------------------------------------------------------------
#  Workspace Ends
#-------------------------------------------------------------------------------


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
