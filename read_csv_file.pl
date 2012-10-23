#!/usr/bin/perl
#===============================================================================
#
#         FILE: read_csv_file.pl
#
#        USAGE: ./read_csv_file.pl
#
#  DESCRIPTION: Read and process a CSV file using DBD::CSV
#
#      OPTIONS: ---
# REQUIREMENTS: --- log.conf -- Log::Log4perl
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Austin Kenny (), aibistin.cionnaith@gmail.com
# ORGANIZATION: Carry On Coding
#      VERSION: 1.0
#      CREATED: 09/30/2012 12:39:17 PM
#     REVISION: ---
#===============================================================================

use Modern::Perl;
use autodie;
use Carp q/confess/;
use Config::General;

#------ Options
use Getopt::Long;
use Pod::Usage;

#------ logging
use Log::Log4perl;
use Try::Tiny;

#------ File Manipulation
use File::Spec;    #------ Portable file specifications
use File::Basename q/dirname/;
use Data::Dumper;
use Text::Table;
use FindBin qw($Bin);

#------Email
use MIME::Lite::TT::HTML;
use Email::Sender::Simple qw(sendmail);
use Email::Simple;
use Email::Simple::Creator;

#------ Local Library
my $bins_dad = dirname($Bin);                        #parent of $Bin directory
my $lib = File::Spec->catdir( $bins_dad, q/lib/ );
use lib File::Spec->catdir( $bins_dad, q/lib/ );

# My Modules
use Mover::Schema;
use Admin::Config;
use Config::DB;
use Config::DBD::CSV;
use Config::Email;
use Customer;

#-------------------------------------------------------------------------------
#  Globals
#-------------------------------------------------------------------------------
my $CURR_DIR;
my $CONFIG_FILE = q/config_read_csv_file.conf/;
my $ENV;
my $PROD = q/p/;
my $DEV  = q/d/;
my $WEBSITE_LINK = 'http://www.carryonmoving.com';

#-------------------------------------------------------------------------------
#  Set Up Logging
#-------------------------------------------------------------------------------
my $config_dir = File::Spec->catdir( $bins_dad, q/configs/ );
my $log_config_file = File::Spec->catfile( $config_dir, q/log.conf/ );
Log::Log4perl->init($log_config_file);
my $log = Log::Log4perl->get_logger(q/CSV::Files/);
$log->info("\n\n\nStart of the running of $0 \n");
$log->debug("Bin from Findbin is $Bin");

#-------------------------------------------------------------------------------
#  Call Configuration Subs
#-------------------------------------------------------------------------------
my $config_file = File::Spec->catfile( $config_dir, $CONFIG_FILE );
my $config_href = get_parsed_config($config_file);

#todo my $env_config_obj = create_env_config($Config_obj);
my $Csv_config_obj = create_csv_config($config_href);
my $Db_config_obj  = create_database_config($config_href);

#-------------------------------------------------------------------------------
#  Main
#-------------------------------------------------------------------------------
my ( $csv_dbh, $dbh, $Schema, $customer_rs, $estimates_rs, $employee_rs,
    $csv_result_set );

#-------------------------------------------------------------------------------
#  CSV Database Subroutine calls
#-------------------------------------------------------------------------------

$csv_dbh = connect_to_csv($Csv_config_obj);
my $required_columns_arref = create_list_of_required_fields();
my $sql = prepare_sql_statement( $csv_dbh, $required_columns_arref );
$csv_result_set = execute_sql_statement( $sql, $required_columns_arref );

#-------------------------------------------------------------------------------
#  Relational Database Subroutine calls
# (SQLite databse for now )
#-------------------------------------------------------------------------------

$Schema = connect_to_schema($Db_config_obj) if ( $Db_config_obj->dbd );

#-------------------------------------------------------------------------------
#  Send our results to ......
#-------------------------------------------------------------------------------

if (   ( !defined $Schema )
    || ( !defined $csv_result_set )
    || ( !defined $required_columns_arref ) )
{

    $log->error('Missing some vital data');
    confess('Missing vital data');
}

#bulk_insert_to_customer_db( $Schema, $csv_result_set, $required_columns_arref );

insert_to_customer_db( $Schema, $csv_result_set, $required_columns_arref );

my $customer_text_table = create_text_table($csv_result_set);
my $customer_table_href = create_table($csv_result_set);
my $Email_config_obj    = create_email_config($config_href);

my $email_completed = email_results(
    {
        text_table    => $customer_text_table,
        table_data    => $customer_table_href,
        schema        => $Schema,
        config_object => $Email_config_obj,
    }
);

#todo
#    my $customer_csv = print_to_csv_file($customer_rs);
#    email_csv_file($customer_csv);
#-------------------------------  ALL DONE  ------------------------------------
1;

#-------------------------------------------------------------------------------
#       Subroutines
#-------------------------------------------------------------------------------

=head2 get_parsed_config
 Get Parsed Configuration Data
 Pass a configuration file
 Get the parsed configuration data from a config.gen file
 Returns a hashref of parsed config data. 
=cut

sub get_parsed_config {

    my ($cofig_file) = @_;
    error_bad_params(
        q/Must supply a configuration file to get configuration data!/)
      unless ( defined $config_file );

    my (%parsed_config) = try {
        Admin::Config->new(
            ConfigFile      => $config_file,
            ExtendedAccess  => 1,
            InterPolateVars => 1,
            AutoTrue        => 1,
            LowerCaseNames  => 0,
            UTF8            => 1,
        )->getall_admin;
    }
    catch {
        error_standard_disaster(
            "Unable to create the Test Admin::Config Object : $_ ");
    };

    #    $log->debug( "The Parsed Config Data is : " . Dumper(%parsed_config) );
    return \%parsed_config;
}

#-------------------------------------------------------------------------------

=head2 create_env_config
  Create Env Config  Object
  Passed a Hashref with the Config::General Config data
   Return an Object with the validated run Environment configuration 
=cut

#-------------------------------------------------------------------------------
sub create_env_config {
    my ($config_href) = @_;
    error_bad_params("No Configuration data sent.")
      unless ( ( defined $config_href )
        && ( ref($config_href) eq 'HASH' ) );

    #---- Validate the env Configs
    my ($env_config_obj) = try {
        Config::ENV->new($config_href);
    }
    catch {
        error_standard_disaster("Unable to create Config::ENV Object : $_ ");
    };

    #------ Set Environment to Production Or Dev
    $ENV = $env_config_obj->env;
    if ( ( $ENV ne $DEV ) && ( $ENV ne $PROD ) ) {
        error_standard_disaster(
            "Invalid Config File p or d environment
           setting"
        );
    }

    return $env_config_obj;

}

#-------------------------------------------------------------------------------
#  CSV Processing
#-------------------------------------------------------------------------------

=head2 create_csv_config
  Create CSV File Config Object
  Passed a Hashref with the Config::General Config data
  Return an Object with the Validated CSV file configuration 
=cut

#-------------------------------------------------------------------------------
sub create_csv_config {
    my ($config_href) = @_;
    error_bad_params("No Configuration data sent.")
      unless ( ( defined $config_href )
        && ( ref($config_href) eq 'HASH' ) );

    #    $log->debug(
    #        'Config before creating Csv_config_obj' . Dumper($config_href) );

    #---- Validate the csv Configs
    my ($Csv_config_obj) = try {
        Config::DBD::CSV->new($config_href);
    }
    catch {
        error_standard_disaster(
            "Unable to create Config::DBD::CSV Object CSV file: $_ ");
    };

    $log->debug('Created a Csv_config_obj');

    return $Csv_config_obj;
}

#-------------------------------------------------------------------------------

=head2
  Connect to the CSV file. No username or password needed for any CSV file.
  Pass the CSV configuration object, $Csv_config_obj.
  Return the $dbh.
=cut

#-------------------------------------------------------------------------------
sub connect_to_csv {
    my ($Csv_config_obj) = @_;
    error_bad_params("No Configuration Obj sent.")
      unless ( ( defined $Csv_config_obj )
        && ( ref($Csv_config_obj) ) );

    my ($dbh) = try {
        $Csv_config_obj->connect_to_csv;
    }
    catch {
        $log->error('Error connecting to DBI::CSV');
        error_shhh("Unable to connect to DBI::CSV : $_");
    };

    $log->debug( 'New CSV database Handle ' . ref($dbh) );

    return $dbh;
}

#-------------------------------------------------------------------------------

=head2 prepare_sql_statement 
   Prepare SQL Statement to Access CSV DB
   Passed CSV database handle,  and orderd list of required 
   fields as a reference to an array.
   Returns the Statement Handle
=cut

#-------------------------------------------------------------------------------
sub prepare_sql_statement {

    my ( $csv_dbh, $list_of_fields ) = @_;

    error_bad_params("No DBH sent for DBD::CSV sent.")
      unless ( ( defined $csv_dbh ) && ( defined $list_of_fields ) );

    my $request = 'SELECT ' . ( join ', ', @$list_of_fields ) . ' FROM
    customer ORDER BY last_name,  first_name';

    my ($sth) = try {
        $csv_dbh->prepare($request);
    }
    catch {
        error_shhh("Error preparing SQL on DBD:CSV database: $_ ");
    };

    $log->debug( 'New prepared request' . ref($sth) );

    return $sth;
}

#-------------------------------------------------------------------------------

=head2 execute_sql_statement 
  Ececute the prepared SQL statement on CSV file.
  Passed the SQL Stetement handlle and a list of column names.
  Returns the Resultset as Array Ref of HashRefs ( Or an ArrayRef with Slice )
=cut

#-------------------------------------------------------------------------------
sub execute_sql_statement {
    if ( scalar(@_) != 2 ) {
        confess "\n Incorrect Attributes sent by Caller: "
          . ( caller(0) )[3] . ". \n";
    }
    my ( $sth, $required_col_list ) = @_;

    $log->debug( 'The statement to be executed is: ' . ref($sth) );
    try {
        $sth->execute();
    }
    catch {
        $log->error( 'Error executing SQL on DBD:CSV database. ' . $_ );
        error_shhh("Error executing SQL on DBD:CSV database: $_ ");
    };

    #----- Fetch the required Record columns as an arrayref of HashRefs
    my %req_cols = map { $_ => 1 } @$required_col_list;
    my $res = $sth->fetchall_arrayref( \%req_cols, );

    $log->debug('Completed the Fetchall arrayref statement')
      if defined $res;

    return $res;
}

#-------------------------------------------------------------------------------
#  Database Processing
#-------------------------------------------------------------------------------

=head2 create_database_config
  Create Database Config Object
  Passed a Hashref with the Config::General Config data
   Return an Object with the validated database configuration 
=cut

#-------------------------------------------------------------------------------
sub create_database_config {
    my ($config_href) = @_;
    error_bad_params("No Configuration data sent.")
      unless ( ( defined $config_href )
        && ( ref($config_href) eq 'HASH' ) );

    #---- Validate the Database Configs
    my ($Db_config_obj) = try {
        Config::DB->new($config_href);
    }
    catch {
        $log->error( 'Unable to create Config::DB Object : ' . $_ );
        error_standard_disaster("Unable to create Config::DB Object : $_ ");
    };

    return $Db_config_obj;

}

#-------------------------------------------------------------------------------

=head2 connect_to_schema
  Connect to the Database DBIx Schema
  Passed the database configuration object
  Return the $Schema Object
=cut

#-------------------------------------------------------------------------------
sub connect_to_schema {
    my ($Db_config_obj) = @_;
    error_bad_params("No configuration data sent.")
      unless ( ( defined $Db_config_obj )
        && ( ref($Db_config_obj) ) );

    $log->debug('Inside Connect to Schema.');

    my ($Schema) = try {
        $Db_config_obj->connect_to_schema();
    }
    catch {
        $log->error( 'Unable to connecti to Schema: ' . $_ );
        error_shhh( 'Error Connecting to Schema ' . $_ );
    };

    $log->debug('Got New Database Schema');
    return $Schema;
}

#-------------------------------------------------------------------------------

=head2 bulk_insert_to_customer_db
  Insert CSV Data to the Customer Database  Table(s)
  Pass the Schema and the Data to be inserted(ArrayRef of HashRefs)
=cut

#-------------------------------------------------------------------------------

sub bulk_insert_to_customer_db {
    my ( $Schema, $csv_result_set, $required_cols_arref ) = @_;
    error_bad_params("Incorrect params sent to bulk_insert_to_customer_db.")
      unless ( ( defined $Schema )
        && ( defined $csv_result_set )
        && ( defined $required_cols_arref ) );

    my $Customer_rs = $Schema->resultset("Customer");

    my $guard = $Schema->txn_scope_guard;

    $Customer_rs->populate( $csv_result_set, );

    $guard->commit;

    $log->debug( 'Completed bulk insert of '
          . ( scalar @$csv_result_set )
          . ' Customer records to  Schema.' );

    return;
}    ## --- end sub bulk_insert_to_customer_db

#-------------------------------------------------------------------------------

=head2 insert_to_customer_db
  Insert CSV Data to the Customer Database Table(s)
  Pass the Schema and the Data to be inserted (ArrayRef of Hashrefs)
=cut

#-------------------------------------------------------------------------------

sub insert_to_customer_db {
    my ( $Schema, $csv_result_set, $required_cols_arref ) = @_;
    error_bad_params("Incorrect params sent to bulk_insert_to_customer_db.")
      unless ( ( defined $Schema )
        && ( defined $csv_result_set )
        && ( defined $required_cols_arref ) );

    my $Customer_rs = $Schema->resultset("Customer");

    #----- Add or update the Customers  from the CSV Data
    #      based on the Primary Telephone Number
    #todo Do a find_or_new to keep track of what is created and what is not.
    my $count = 0;
    my $guard = $Schema->txn_scope_guard;
    for my $cust_rec_href (@$csv_result_set) {
        $Customer_rs->find_or_create( $cust_rec_href,
            { key => 'phone_1_unique' } );
        $count++;
    }

#todo use this version after altering Customer table    $Customer_rs->find_or_create( $csv_result_set, { key => 'phone_1', }
#    );

    $guard->commit;

    $log->debug( 'Completed find or create  of '
          . $count
          . ' Customer records to  Schema.' );

    return;
}    ## --- end sub insert_to_customer_db

#-------------------------------------------------------------------------------
#  Output
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------

=head2 create_text_table
   Create A Text Table With The Output From The CSV File
   Pass A Result Set of Data (ArrayRef of HashRefs)
   Return the text table.
=cut

#-------------------------------------------------------------------------------
sub create_text_table {
    my ($csv_result_set) = @_;
    error_bad_params("Not enough data sent to create text table function")
      unless ( defined $csv_result_set );

    my @print_fields = qw/ last_name first_name city state phone_1  /;

    my $tb = Text::Table->new(
        \'| ',
        {
            title       => 'Last Name',
            align       => 'center',
            align_title => 'center'
        },
        \' | ',
        {
            title       => 'First Name',
            align       => 'center',
            align_title => 'center'
        },
        \' | ',
        {
            title       => 'City',
            align       => 'center',
            align_title => 'center'
        },
        \' | ',
        {
            title        => 'State',
            align        => 'center',
            align_titlei => 'center'
        },
        \' | ',
        {
            title       => 'Primary Phone',
            align       => 'center',
            align_title => 'center'
        },
        \' |',
    );

    $tb->warnings('on');

    #------ Load the required result set into the table as column data
    my (@rows);
    for my $result_href (@$csv_result_set) {
        push @rows,
          [
            $result_href->{last_name}, $result_href->{first_name},
            $result_href->{city},      $result_href->{state},
            $result_href->{phone_1}
          ];
    }

    $tb->load(@rows);

    #------ 1970's pretty formatting and table print
    my $rule = $tb->rule(qw/- +/);
    my @arr  = $tb->body;

    print $rule, $tb->title, $rule;

    for my $tb_row (@arr) {
        print $tb_row . $rule;
    }

    return $tb;
}    # End - Create Text Table

#-------------------------------------------------------------------------------

=head2 create_table
  Create table data TML Table With The Output From The CSV File
  Pass A Result Set of Data (ArrayRef of HashRefs)
   Return a Hashref of Headings and Table data
=cut

#-------------------------------------------------------------------------------
sub create_table {
    my ($csv_result_set) = @_;
    error_bad_params("Not enough data sent to create table")
      unless ( defined $csv_result_set );

    #------ Create title row
    my %table_data = (
        table_heading => {
            heading_last_name     => 'Last Name',
            heading_first_name    => 'First Name',
            heading_address       => 'Address',
            heading_primary_phone => 'Phone Number',
        },
    );

    #------ Rows of data
    my (@rows);
    for my $result_href (@$csv_result_set) {
        push @rows,
          {
            last_name     => $result_href->{last_name},
            first_name    => $result_href->{first_name},
            city          => $result_href->{city},
            state         => $result_href->{state},
            primary_phone => $result_href->{phone_1},
          };
    }
    $table_data{table_rows} = \@rows;

    $log->debug(
            'Created array of table data,  with '
          . @rows
          . ' rows of data
        including the heading.'
    );
    return \%table_data;
}    # End - Create Table

#-------------------------------------------------------------------------------
#  EMAIL
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#  Email Table
#-------------------------------------------------------------------------------

=head2 create_email_config
  Create Email Config Object
  Passed a Hashref with the Config::General Config data
   Return an Object with the validated Email configuration 
=cut

#-------------------------------------------------------------------------------
sub create_email_config {
    my ($config_href) = @_;
    error_bad_params("No Configuration data sent.")
      unless ( ( defined $config_href )
        && ( ref($config_href) eq 'HASH' ) );

    #---- Validate the Email Configs
    my ($Email_config_obj) = try {
        Config::Email->new($config_href);
    }
    catch {
        $log->error( 'Unable to create Config::Email Object : ' . $_ );
        error_standard_disaster("Unable to create Config::Email Object : $_ ");
    };

    $log->debug( 'Created Email Config Object: ' . ref $Email_config_obj );
    return $Email_config_obj;

}

#-------------------------------------------------------------------------------

=head2 email_results
  Email the stuff to whomever really wants to read it.... 
  Pass a hashref of parameters.
  email_results({
    table_data => $table_href,
    text_table => $customer_text_table,
    schema => $Schema,
    config_object => $Email_config_obj
   });
=cut

#-------------------------------------------------------------------------------
#  Important Note: This works without setting up an Email Server.
#  Use ssmtp . Edit the /etc/ssmtp config file to send the email via Hotmail
#  or some other web based mail.
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
sub email_results {
    my ($email_attr_href) = @_;
    error_bad_params("Parameters not sent to Email results")
      unless ( ( defined $email_attr_href ) && ( ref $email_attr_href ) );

    my $table_href       = $email_attr_href->{table_data};      #For HTML table
    my $table_of_info    = $email_attr_href->{text_table};      #For text table
    my $Schema           = $email_attr_href->{schema};
    my $Email_config_obj = $email_attr_href->{config_object};

    my $table_string = $table_of_info->stringify();

    # $Email_config_obj->email_template;
    # $Email_config_obj->email_template_dir;
    # $Email_config_obj->email_from;
    # $Email_config_obj->email_to;
    # $Email_config_obj->email_cc;
    # $Email_config_obj->email_bcc;
    # $Email_config_obj->email_subject;
    # $Email_config_obj->email_body;
    # $Email_config_obj->email_signed;

    my %template_params = (
        person_to              => $Email_config_obj->email_person_to,
        customer_table_heading => $table_href->{table_heading},
        customer_table_rows    => $table_href->{table_rows},
        link_to_website        => $WEBSITE_LINK,
        #        text_table => $table_string,
        signed => $Email_config_obj->email_signed,
    );

    #my $email = Email::Simple->create(
    #    header => [
    #            To       => $Email_config_obj->email_to,
    #            From     => $Email_config_obj->email_from,
    #            Subject  => $Email_config_obj->email_subject,
    #              ],
    #              body => $Email_config_obj->email_body,
    #            );
    #        ]);

    my %template_options =
      ( INCLUDE_PATH => $Email_config_obj->email_template_dir, );

    my $msg = try {
        MIME::Lite::TT::HTML->new(
            From        => $Email_config_obj->email_from,
            To          => $Email_config_obj->email_to,
            CC          => $Email_config_obj->email_cc // '',
            CC          => $Email_config_obj->email_bcc // '',
            Subject     => $Email_config_obj->email_subject,
            Template    => { html => $Email_config_obj->email_template, },
            TimeZone    => 'America/New_York',
            TmplOptions => \%template_options,
            TmplParams  => \%template_params,
        );
    }
    catch {
        $log->error( "Got an error trying to compose the email " . $_ );
        error_shhh( "Got an error composing the email. " . $_ );
    };

    my $rc = try {

        $msg->send;
    }
    catch {
        $log->error("Unable to send the Email: $_");
        error_standard_disaster("Unable to send the Email: $_");
    };

    $log->debug( 'Message Sent with Return code: ' . $rc );
    return $rc;
}

#-------------------------------------------------------------------------------
#      Create An Orderd List Which Can Be Passed Fetch
#      Data From The Result Set In Whatever Order Specified
#      Pass The Customer Input Record otherwise the default
#      Customer Fields Will be used
#-------------------------------------------------------------------------------
sub create_list_of_required_fields {
    my $input_record_arref = shift @_;
    my %customer_fields_order_h;

    #------ This Array Specifies the Required Fields
    #       in their correct order
    #      id         last_name  first_name      m_i
    my @customer_fields_arr = qw (
      last_name  first_name      m_i
      prefix     suffix     alias           address_1
      address_2  city       state           zip
      phone_1    phone_2    phone_3         email_1
      email_2    recommended_by repeat      type
      comments   created    created_by      updated
      updated_by
    );

    $log->debug( "Orderd list of required fields: "
          . print join( '-> ', @customer_fields_arr ) );

    return \@customer_fields_arr;

}

#-------------------------------------------------------------------------------
#  Standard Error Routines
#-------------------------------------------------------------------------------
#----- Log and confess this error
sub error_bad_params {
    my ($extra_msg) = @_;
    $log->error(
        'Missing or bad parameters passed to subroutine' . ( caller(1) )[3] );
    $log->error($extra_msg);
    confess "\n Incorrect Params  sent to " . ( caller(1) )[3] . ". \n";
}

#----- Log and confess standard error
sub error_standard_disaster {
    my ($extra_msg) = @_;
    $log->error( 'Error found at ' . ( caller(1) )[3] );
    $log->error($extra_msg);
    confess "\n Got an error at " . ( caller(1) )[3] . ". \n";

}

#----- Log but don't confess this error
sub error_shhh {
    my ($extra_msg) = @_;
    $log->error( 'Error found at ' . ( caller(1) )[3] );
    $log->error($extra_msg);
}

#-------------------------------------------------------------------------------

__END__
