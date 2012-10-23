package Mover::Schema::ResultSet::Employee;
use strict;
use warnings;
use Data::Dumper;
use Log::Log4perl qw(:easy);
use base 'DBIx::Class::ResultSet';

=head2 created_after

A predefined search for recently added books

=cut

###############################################################
# Create Employee
###############################################################

=head2 create_allowed_by
    Can the specified user create the current employee>
=cut
sub create_allowed_by {
    my ($self, $user) = @_;

    #------ Only allow create if user has 'admin' (or 'super_admin' role)
    return $user->has_role('admin');
    return undef;
}

=head2 list_employees_order_by
    Get a list of all office staff
    Pass an array ref of order_by columns.
    Return result set. 
=cut

sub list_employees_order_by {
    my ($self, $order_by) = @_;
    
    return $self->search(
    {},
    {  order_by => $order_by}, 
    );
}

=head2 list_sales_department_order_by
    Get a list of estimators orderd by fields.
    Pass an array ref of order_by columns.
    Return result set. 
=cut

sub list_sales_department_order_by {
    my ($self, $order_by) = @_;
    return
        $self->search({ 'job_title.name' => 'estimator' },
                      {  join     => 'job_title',
                         order_by => $order_by,
                      },
        );
}

=head2 list_office_staff_order_by
    Get a list of all office staff
    Include (100) for obsqure personell
    Pass an array ref of order_by columns.
    Return result set. 
=cut

sub list_office_staff_order_by {
    my ($self, $order_by) = @_;
    return
        $self->search(-or => [ 'department.id' => { '<' => '60' },
                               'department.id' => '100',
                      ],
                      { join     => 'department',
                        order_by => $order_by,
                      },
        );
}

###############################################################
# Permissions
###############################################################
=head2 display_allowed_by
    Can the user see  Info
=cut

sub viewing_permission {
    my ($self, $user) = @_;

    # Only allow create if user has 'admin' (or 'super_admin' role)
    return $user->has_role('admin');
    return undef;
}
################################################################################
1;
