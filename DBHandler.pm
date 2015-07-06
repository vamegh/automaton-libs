package DBHandler;
#
##
##########################################################################
#                                                                        #
#       Automaton Framework  / Google Authenticator Automator            #
#                                                                        #
#       Copyright (C) 2010 / 2012 by Vamegh Hedayati                     #
#       vamegh@gmail.com                                                 #
#                                                                        #
#       Please see Copying for License Information                       #
#                               GNU/GPL v2 2010                          #
##########################################################################
##
#
#################################################
# Integrity Checks
##
use strict;
use warnings;
#################################################
# Builtin Modules
##
# These should be available by default
##
use Getopt::Std;
use Switch '__';
use File::Path;
use File::Copy;
use Net::Netmask;
#################################################
# External Modules
##
# These will need to be installed on the system
# running this script
##
use DBI;
#################################################
# My Modules
##
# All provided in the ./libs directory
##
use LogHandle;
use CMDHandle;
use GenDate;
use FileHandler;
#################################################
# Exporting variables out of module
##
use vars   qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
require Exporter;
@ISA = qw(Exporter);
#@EXPORT = qw(&db_connect);
#use vars qw($db_call);
#################################################
# Variables Exported From Module - Definitions
##
## DataBase Values
#################################################
# Local Internal Variables for this Module
##
my $myname=":: module DBHandler.pm";
#################################################
#  Sub-Routines / Functions Definitions
##

## connect to the database
sub db_connect {
  my $subname="sub db_connect";
  my $caller=$myname." :: ".$subname;
  my $vlan_dom="none";
  my $dsn="none";
  my $db_port="3306";
  my $srv_fdomain="none";

  my %args=@_;
  my $db_ref = $args{db_ref};
  my $srv_ref = $args{server_info};
  my $net_ref = $args{net_info};
  my $bond_ref = $args{bond_info};
  my $db_call = $args{db_call};
  my $db_table = $args{db_table};
  my $error_status = $args{error_status};

  my $sw_ref = $args{spacewalk_info};
  my $mail_ref = $args{email_info};

  if (!defined $error_status) {
    $error_status="1";
  }

  my $dbi=$db_ref->{'db_dbi'};
  my $use_mysql_ssl=$db_ref->{'use_ssl'};
  my $ssl_ca=$db_ref->{'ssl_ca'};
  my $ssl_cert=$db_ref->{'ssl_cert'};
  my $ssl_key=$db_ref->{'ssl_key'};
  my $db_name=$db_ref->{'db_name'};
  my $db_host=$db_ref->{'db_host'};
  my $db_user=$db_ref->{'db_user'};
  my $db_pass=$db_ref->{'db_pass'};
  my $use_db=$db_ref->{'use_db'};

  my $srv_role=$srv_ref->{'srv_role'};

  if ($use_db eq "no") {
    LogHandle::log_it("Database Usage has been Disabled :: ".
                      "Stopping Processing and Returning :: ".
                      "use_db = $use_db !",
                      "debug","1","$caller");
    return;
  }

  if ($use_mysql_ssl eq "yes") {
    $dsn = "dbi:$dbi:database=$db_name;
            host=$db_host;
            port=$db_port;
            mysql_ssl=1;
            mysql_ssl_client_key=$ssl_key;
            mysql_ssl_client_cert=$ssl_cert;
            mysql_ssl_ca=$ssl_ca";
  } else {
    $dsn = "dbi:$dbi:database=$db_name;
            host=$db_host;
            port=$db_port";
  }
  my $dbh = DBI->connect($dsn,$db_user,$db_pass)
    or LogHandle::log_it("cant connect :: $! $DBI::errstr ",
                         "error","1","$caller");

  switch ($db_call) {
    $caller=$myname." :: ".$subname." :: case $db_call";
    case None:
    } else {
    }
  }
}

END { }       # Global Destructor

1;

#################################################
#
################################### EO PROGRAM #######################################################
#
################################ MODULE HELP / DOCUMENTATION SECTION #################################
##
# Original implementation idea from linblock.pl http://www.dessent.net/linblock/ (c) Brian Dessent GNU/GPL
# This actually uses no code from linblock.pl, but the implementation was learnt by studying the above script
##
# To access documentation please use perldoc DBHandler.pm, This will provide
# the formatted help file for this specific module
##
#################################################
#
__END__

=head1 NAME

DBHandler.pm - Automaton Framework: Forensic Auditing Toolkit
         - Major updates for Google Authenticator Automator

=head1 SYNOPSIS

 Database Connection Handler

=head1 DESCRIPTION

This consists of 3 main functions,

        1. db_connect
           This connects to the database, using either the command line options passed to it,
           or the information from /opt/rackconverter/rackconverter.cfg
           Currently this is Connecting to a local Sqlite DB, which it creates, future revisions will bring back MySQL connectivity.
        2. db_read

The db_connect function should only ever be called from a script or another module.

=head1 AUTHOR

=over

=item Vamegh Hedayati <vamegh AT gmail DOT com>

=back

=head1 LICENSE

Copyright (C) 2010  Vamegh Hedayati <vamegh AT gmail DOT com>

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.


=cut
#
#################################################
#
######################################### EOF  #######################################################
