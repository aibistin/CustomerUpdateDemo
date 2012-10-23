package Mover::Schema::ResultSet::Estimate;
use strict;
use warnings;
use Data::Dumper;
use base 'DBIx::Class::ResultSet';

#-------------------------------------------------------------------------------
#  Lots of pre defined searches to get estimate information
#-------------------------------------------------------------------------------

=d2 customer_estimates
   Get all the Estimates and their corresponding customer details.
=cut

sub customer_estimates {
    my ( $self, $c, $order_by ) = @_;
    my $rs = $self->search( {}, { 'prefetch' => 'customer', }, );
    return $rs;
}

#-------------------------------------------------------------------------------
# Create Estimates
# This is currently in the Schema result Estimate.pm
#-------------------------------------------------------------------------------

=head2 create_allowed_by
    Can the specified user create current estimates
=cut

#sub create_allowed_by {
#    my ( $self, $user ) = @_;
#    return $user->has_role('can_create_estimate');
#}

#-------------------------------------------------------------------------------
#  List Estimatesn matcing specific criteria.
#-------------------------------------------------------------------------------

=head2 created_after
     A predefined search for estimates created
     after a specific date.
=cut

sub created_after {
    my ( $self, $datetime, $want_customer_details ) = @_;
    my $date_str =
      $self->result_source->schema->storage->datetime_parser->format_datetime(
        $datetime);
    return ( $self->search( { created => { '>' => $date_str } } ) )
      if not $want_customer_details;
    return $self->search( { created => { '>' => $date_str } }, );
}

=head2 updated_after
     A predefined search for recently updatedEstimates
=cut

sub updated_after {
    my ( $self, $datetime, $want_customer_details ) = @_;
    my $date_str =
      $self->result_source->schema->storage->datetime_parser->format_datetime(
        $datetime);
    return ( $self->search( { updated => { '>' => $date_str } } ) )
      if not $want_customer_details;
}

#----------------------------------------------------------------------

=head2 created_on
     A predefined search for estimates 
     created on a particular day
=cut

sub created_on {
    my ( $self, $date, $want_customer_details ) = @_;
    my $date_str =
      $self->result_source->schema->storage->datetime_parser->format_datetime(
        $date);
    return ( $self->search( { created => { '=' => $date_str } } ) )
      if not $want_customer_details;
}

=head2 scheduled_on_date
     A predefined search for estimates scheduled or completed,
      on a particular day. Including the estimator
      Passed a DateTime date
=cut

sub scheduled_on_date {
    my ( $self, $date_time_obj ) = @_;

    #    $dt->datetime();
    #    $dt->ymd('-')
    my $dtf = $self->result_source->schema->storage->datetime_parser;
    my $rs  = $self->search(
        { 'estimate_date' => $dtf->format_datetime($date_time_obj), },
        {
            join       => 'estimator',
            'order_by' => [ 'estimates.estimate_time', 'me.last_name', ]
        },
    );
    return $rs;
}

=head2 scheduled_between_dates
     A predefined search for estimates scheduled 
      between specified dates 
=cut

sub scheduled_between_dates {
    my ( $self, $date_obj_1, $date_obj_2 ) = @_;
    my $dtf        = $self->result_source->schema->storage->datetime_parser;
    my $date_str_1 = $dtf->format_datetime($date_obj_1);
    my $date_str_2 = $dtf->format_datetime($date_obj_2);
    return $self->search(
        { estimate_date => { -between => [ $date_str_1, $date_str_2, ], } },
        {
            join       => 'estimator',
            'order_by' => [
                'estimates.estimate_date', 'estimates.estimate_time',
                'me.last_name',
            ]
        },
    );
}

#-------------------------------------------------------------------------------
# List Estimates by Customer along with other constraints.
#-------------------------------------------------------------------------------

=head2 with_customer_id
     A predefined search for all estimates scheduled or completed,
      for a particular customer.
      Pass the customer ID
      Returns list of estimates ResultsSet
=cut

sub with_customer_id {
    my ( $self, $customer_id ) = @_;
    my $rs = $self->search(
        { 'me.customer_id' => $customer_id, },
        {
            join       => 'estimator',
            'order_by' => [ 'me.estimate_date', 'me.estimate_time', ]
        },
    );
    return $rs;
}

#------ Matching Customer Names

=head2 customer last name like
   A predefined search for customer estimates with a 'LIKE' search in the string
=cut

sub last_name_like {
    my ( $self, $name_str ) = @_;
    return $self->search( { last_name => { 'like' => "%$name_str%" } },
        { join => 'customer', } );
}

#-------------------------------------------------------------------------------
# Permissions
#-------------------------------------------------------------------------------

=head2 viewing_permission
    Can the user see Estimate Info For 
    The Entire Resulset
=cut

sub viewing_permission {
    my ( $self, $user ) = @_;
    return $user->has_role('can_view_estimate');
}

#######################################################################
1;
