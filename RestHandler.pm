package RestHandler;
#
##
##########################################################################
#                                                                        #
#       RestHandler SpaceWalk Connector Module                           #
#       using the :: Automaton Framework                                 #
#                                                                        #
#       Automaton Copyright (c) 2010-2012 Vamegh Hedayati                #
#                                                                        #
#       Vamegh Hedayati <vamegh AT gmail DOT com>                        #
#                                                                        #
#       Please see Copying for License Information                       #
#                             GNU/GPL v2 2010-2013                       #
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
#use Switch '__';
#################################################
# External Modules
##
# These will need to be installed on the system
# running this script
##
use REST::Client;
use JSON;
use Data::Dumper;
use MIME::Base64;
use Switch '__';
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

#@ISA = qw(Exporter);
#@EXPORT = qw(&sw_connect $sw_host $sw_user $sw_pass );
#use vars qw($sw_host $sw_user $sw_pass );
#################################################
# Variables Exported From Module - Definitions

#################################################
# Local Internal Variables for this Module
##
my $handle="none";
my $myname="module RestHandler.pm";

#################################################
#  Sub-Routines / Functions Definitions
##
# This is the actual Body of the module
##
################## READ_CFG #####################
#
##
#

sub api_connect {
  my $subname="sub api_connect";
  my $caller=$myname." :: ".$subname;

  my %args=@_;
  my $api_ref = $args{api_info};
  my ($user,$pass,$server,$port);
  if (defined($api_ref)) {
    $user = $api_ref->{username};
    $pass = $api_ref->{password};
    $server = $api_ref->{server};
    $port = $api_ref->{port};
  } else {
    $pass=$args{password};
    $server=$args{server};
    $port=$args{port};
    $user=$args{username};
  }

  my $encoded_auth = encode_base64("$user:$pass","");

  my $headers = {Accept => 'application/json', Authorization => 'Basic ' . $encoded_auth};

  my $client = REST::Client->new();
  $client->setHost('http://'.$server.":".$port);

  return $client,$headers;
}

sub api_get {
  my $subname="sub api_get";
  my $caller=$myname." :: ".$subname;
  my $output = "";
  my $json_out = "";

  my %args=@_;
  my $client = $args{client};
  my $headers = $args{headers};
  my $get = $args{cmd};

  my $data = $client->GET($get, $headers);
  my $head=$data->responseHeaders();
  my $code=$data->responseCode();
  my $content=$data->responseContent();
  eval { $json_out = JSON::from_json($content); };
  if ($@) {
    LogHandle::log_it("Error:: $@ ",
                      "error","2","$caller");
  }
  return ($json_out,$code,$head);
}

sub api_put {
  my $subname="sub api_put";
  my $caller=$myname." :: ".$subname;
  my $output = "";
  my $json_out = "";

  my %args=@_;
  my $client = $args{client};
  my $headers = $args{headers};
  my $object = $args{object};
  my $cmd_hash = $args{cmd_hash};

  $headers->{"Content-Type"}="application/json";
  $headers->{"Accept"}="application/json";

  my $data = $client->PUT($object,encode_json($cmd_hash), $headers);
  my $head=$data->responseHeaders();
  my $code=$data->responseCode();
  my $content=$data->responseContent();
  eval { $json_out = JSON::from_json($content); };
  if ($@) {
    LogHandle::log_it("Error:: $@ ",
                      "error","2","$caller");
  }
  return ($json_out,$code,$head);
}

sub build_update {
  my $subname="sub build_auto";
  my $caller=$myname." :: ".$subname;
  my $output = "";

  my %args=@_;
  my $client = $args{client};
  my $headers = $args{headers};
  my $query = $args{query};
  my $object = $args{object};
  my $cmd_hash = $args{cmd_hash};

  my ($content,$return_code,$return_head) = RestHandler::api_put(client => $client,
                                                                 headers => $headers,
                                                                 object => $object,
                                                                 cmd_hash => $cmd_hash);
  if ("$return_code" eq "500") {
    return "connection-fail";
  }
  switch ($query) {
    case "server_update" {
      print "Server update content = ".Dumper($content);
      print "Server update code = ".Dumper($return_code);
      print "Server update header = ".Dumper($return_head);
    }
  }
  return $content;
}

sub build_auto {
  my $subname="sub build_auto";
  my $caller=$myname." :: ".$subname;
  my $output = "";

  my %args=@_;
  my $client = $args{client};
  my $headers = $args{headers};
  my $get = $args{cmd};
  my $query = $args{query};

  my ($jcon,$return_code,$head) = RestHandler::api_get(client => $client,
                                                       headers => $headers,
                                                       cmd => $get);
  if ("$return_code" eq "500") {
    return "connection-fail";
  }

  switch ($query) {
    case "server_info" {
      if ("$return_code" ne "200") {
        return "none";
      }
      foreach my $data (keys %$jcon) {
        $output = $jcon->{$data}->[0];
        $output->{'srv_name'} = delete $output->{'server_name'};
        $output->{'server_id'} = delete $output->{'id'};
        $output->{'srv_domain'} = delete $output->{'domain'};
        $output->{'srv_loc'} = delete $output->{'loc'};
        $output->{'srv_gw'} = delete $output->{'gateway'};
        $output->{'srv_type'} = delete $output->{'type'};
        $output->{'srv_env'} = delete $output->{'env'};
        $output->{'srv_role'} = delete $output->{'role'};
        $output->{'srv_group_role'} = delete $output->{'group_role'};
        $output->{'srv_os'} = delete $output->{'os'};
        $output->{'srv_cpus'} = delete $output->{'cpus'};
        $output->{'srv_ram'} = delete $output->{'ram'};
        $output->{'srv_hdd'} = delete $output->{'disk'};
        $output->{'assign_ip'} = delete $output->{'auto_ip'};
        $output->{'srv_timer'} = delete $output->{'build_timer'};
        $output->{'build_user'} = delete $output->{'build_user'};
        $output->{'pxe_mac'} = delete $output->{'pxe_mac'};
        $output->{'use_mail'} = delete $output->{'send_email'};
        #$output{'  '} = delete $output{'build_date'};
        #$output{'use_spacewalk'} = delete $output{'use_spacewalk'};
        #$output{'srv_installed'} = delete $output{'installed'};
        #$output{'srv_destroy'} = delete $output{'destroy'};
        #$output{'srv_build'} = delete $output{'build'};
        #print "Data is ".Dumper($output);
      }
      return $output;
    } case "net_info" {
      if ("$return_code" ne "200") {
        return "none";
      }
      my %net_ifaces=();
      my %net_bonds=();
      my @bond_nets=();
      my $old_bond="";
      foreach my $data (keys %$jcon) {
        $output = $jcon->{$data};
        foreach my $net_ref (@$output) {
          my $net_id = $net_ref->{id};
          my $net_dev = $net_ref->{net_device};
          my $net_role = $net_ref->{network_role};
          my $net_ip = $net_ref->{net_ip};
          my $net_mask = $net_ref->{netmask};
          my $iface_vlan = $net_ref->{vlan};
          my $srv_id = $net_ref->{server_id};
          my $bond_name = $net_ref->{bond_name};
          my $bond_opts = $net_ref->{bond_options};

          if (!defined($iface_vlan)) {
              $iface_vlan=0;
          } elsif ($iface_vlan eq "none") {
              $iface_vlan=0;
          }

          if ($net_ref->{bond_name} eq "none") {
            LogHandle::log_it("Interface is not Bonded :: ",
                              "debug","3","$caller");
            my $net_key="$net_role-$net_dev";
            push(@{$net_ifaces{$net_key}},$net_role,
                                          $net_dev,
                                          $net_ip,
                                          $net_mask,
                                          $iface_vlan);
          } else {
            next if ($bond_name eq $old_bond) ;
            my $bond_get = 'autobuilder/api/v0.3/bond?server_id='
                           .$srv_id.'&bond_name='.$bond_name;
            my ($bjson,$auth_code,$auth_header) = RestHandler::api_get(client => $client,
                                                                       headers => $headers,
                                                                       cmd => $bond_get);
            foreach my $bjdata (keys %$bjson) {
              my $ifarref = $bjson->{$bjdata};
              foreach my $ifref (@$ifarref) {
                while (my ($key,$net_name) = each(%$ifref)) {
                  push(@bond_nets,$net_name);
                }
              }
            }
            my $net_devs=join(",",@bond_nets);
            push (@{$net_bonds{$bond_name}},$net_devs,
                                            $bond_opts);

            my $net_key="$net_role-$bond_name";
            push(@{$net_ifaces{$net_key}},$net_role,
                                          $bond_name,
                                          $net_ip,
                                          $net_mask,
                                          $iface_vlan);

            undef @bond_nets;
            $old_bond = $bond_name;
          }
        }
      }
      return (\%net_ifaces,\%net_bonds);
    } case "vmware_info" {
      foreach my $data (keys %$jcon) {
        $output = $jcon->{$data}->[0];
        $output->{'vm_id'} = delete $output->{'id'};
        $output->{'server'} = delete $output->{'vm_host'};
        $output->{'dc'} = delete $output->{'vmware_dc'};
        $output->{'srv_type'} = delete $output->{'server_type'};
        $output->{'srv_env'} = delete $output->{'server_env'};
        $output->{'guest_id'} = delete $output->{'vmguest_id'};
      }

      my $auth_get = 'autobuilder/api/v0.3/login?vmware_id='.$output->{vm_id};
      my ($auth_json,$auth_code,$auth_header) = RestHandler::api_get(client => $client,
                                                                     headers => $headers,
                                                                     cmd => $auth_get);
      foreach my $authref (keys %$auth_json) {
        my $auth = $auth_json->{$authref}->[0];
        $output->{user} = $auth->{user};
        $output->{pass} = $auth->{pass};
      }
      return $output
    } case "spacewalk_info" {
      foreach my $data (keys %$jcon) {
        $output = $jcon->{$data}->[0];
        $output->{'sw_id'} = delete $output->{'id'};
        $output->{'sw_server'} = delete $output->{'server'};
        $output->{'sw_proxy'} = delete $output->{'proxy'};
      }
      my $auth_get = 'autobuilder/api/v0.3/login?spacewalk_id='.$output->{sw_id};
      my ($auth_json,$auth_code,$auth_header) = RestHandler::api_get(client => $client,
                                                                     headers => $headers,
                                                                     cmd => $auth_get);
      foreach my $authref (keys %$auth_json) {
        my $auth = $auth_json->{$authref}->[0];
        $output->{user} = $auth->{user};
        $output->{pass} = $auth->{pass};
      }
      return $output
    } case "rack_info" {
      foreach my $data (keys %$jcon) {
        $output = $jcon->{$data}->[0];
        $output->{'rack_id'} = delete $output->{'id'};
        $output->{'db_dbi'} = delete $output->{'dbi'};
      }
      my $auth_get = 'autobuilder/api/v0.3/login?rack_id='.$output->{rack_id};
      my ($auth_json,$auth_code,$auth_header) = RestHandler::api_get(client => $client,
                                                                     headers => $headers,
                                                                     cmd => $auth_get);
      foreach my $authref (keys %$auth_json) {
        my $auth = $auth_json->{$authref}->[0];
        $output->{db_user} = $auth->{user};
        $output->{db_pass} = $auth->{pass};
      }
      return $output
    } case "mail_info" {
      foreach my $data (keys %$jcon) {
        $output = $jcon->{$data}->[0];
      }
      return $output
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
# To access documentation please use perldoc RestHandler.pm, This will provide
# the formatted help file for this specific module
##
#################################################
#
__END__

=head1 NAME

RestHandler.pm - RestHandler
              using the Automaton Framework

=head1 SYNOPSIS

RestHandler.pm
A Module to handle Restful API Calls / Information

=head1 DESCRIPTION

=head1 AUTHOR

=over

=item Vamegh Hedayati <vamegh AT gmail DOT com>

=back

=head1 LICENSE

Copyright (c) 2013  Vamegh Hedayati <vamegh AT gmail DOT com>

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

Please refer to the COPYING file which is distributed with
the Automaton Framework for the full terms and conditions

=cut
#
#################################################
#
######################################### EOF  #######################################################
