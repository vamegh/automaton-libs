package RCON;
#
##
##########################################################################
#                                                                        #
#       Automaton Framework                                              #
#                                                                        #
#       Forensic Auditing Toolkit                                        #
#                                                                        #
#       Forensic Auditing System - Designed to build an audit trail      #
#       and health check on all systems                                  #
#                                                                        #
#       Copyright (C) 2010 by Vamegh Hedayati                            #
#       vamegh@gmail.com                                                 #
#                                                                        #
#       Updated 2013 for o2 Wifi - Only using Net::OpenSSH now           #
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
# Modules
##
#use Getopt::Std;
use Switch '__';
use Term::ReadKey;
use Net::OpenSSH;
#################################################
# My Modules
##
# All provided in the ./libs directory
##
use LogHandle;
#################################################
# Local Internal Variables for this Module
##
my $myname="module RCON.pm";
#################################################
# Exporting variables out of module
##
use vars   qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
require Exporter;
@ISA = qw(Exporter);
#@EXPORT = qw(&ssh_rcon @ssh_commands);
#use vars qw(@ssh_commands);

sub ssh_rcon {
  my $subname="sub ssh_rcon";
  my $caller=$myname." :: ".$subname;

  my $err="none";
  my $ssh="none";
  my $cmd="none";
  my $debug_flag="none";
  my $debug_level="none";

  my %args=@_;
  my $rcon_method = $args{method};
  my $rcon_host = $args{host};
  my $rcon_port = $args{port};
  my $rcon_cmd = $args{rcon_cmd};
  my $rcon_cmds = $args{rcon_cmds};
  my $rcon_user = $args{user};
  my $rcon_key = $args{key};
  my $rcon_scp = $args{scp};
  my @ssh_commands=();
  my @ssh_output=();

  if (!defined($rcon_cmd)) {
    $rcon_cmd="none";
  }

  if (!defined($rcon_cmds)) {
    $rcon_cmds="none";
  } else {
    @ssh_commands = @$rcon_cmds;
  }

  if (!defined($rcon_scp)) {
    $rcon_scp="none";
  }

  LogHandle::log_it("rcon_method :: $rcon_method :: ".
                    "rcon_host :: $rcon_host :: ".
                    "rcon_port :: $rcon_port :: ".
                    "rcon_cmd :: $rcon_cmd :: ".
                    "rcon_cmds :: $rcon_cmds :: ".
                    "rcon_user :: $rcon_user :: ".
                    "rcon_key :: $rcon_key :: ",
                    "debug","3","$caller");

  switch ($rcon_method) {
    case "pass" {
      $ssh = Net::OpenSSH->new("$rcon_host",
                               "user"=>"$rcon_user",
                               "port"=>"$rcon_port",
                               "password"=>"$rcon_key",
                               "batch_mode" => "1",
                               "timeout" => "30",
                               master_opts => [-o => "StrictHostKeyChecking=no",
                                               -o => "UserKnownHostsFile=/dev/null"]);
    } case "key" {
      $ssh = Net::OpenSSH->new("$rcon_host",
                               "user"=>"$rcon_user",
                               "port"=>"$rcon_port",
                               "key_path" => "$rcon_key",
                               "batch_mode" => "1",
                               "timeout" => "30",
                               master_opts => [-o => "StrictHostKeyChecking=no",
                                               -o => "UserKnownHostsFile=/dev/null"]);
    } else {
      LogHandle::log_it("Rcon Method :: $rcon_method :: ".
                        "does not match key or pass, Bombing Out",
                        "error","1","$caller");
    }
  }

  switch ($rcon_scp) {
    $caller="$caller :: case $rcon_scp";
    case "put" {
      if ("$rcon_cmd" eq "none") {
        foreach my $ssh_cmd (@ssh_commands) {
          my $cmd_output=$ssh->scp_put({ recursive => 1,
                                         quiet => 0,
                                         glob => 1 }, "$ssh_cmd");
          $ssh->error and LogHandle::log_it("$rcon_host connect failed :: ".
                                            "remote command failed: ".$ssh->error,
                                            "debug","3","$caller");
          if ($ssh->error) {
           $cmd_output="ERROR";
           LogHandle::log_it("Output is ".$ssh->error."Error Condition Met :: ".
                             "Command :: $ssh_cmd :: ",
                             "debug","2","$caller");
          }
          push (@ssh_output, $cmd_output);
        }
        return \@ssh_output;
      } else {
        my $cmd_output=$ssh->scp_put({ recursive => 1,
                                       quiet => 0,
                                       glob => 1 }, "$rcon_cmd");
        $ssh->error and LogHandle::log_it("$rcon_host connect failed :: ".
                                          "remote command failed: ".$ssh->error,
                                          "debug","3","$caller");
        if ($ssh->error) {
         $cmd_output="ERROR";
         LogHandle::log_it("ERROR :: Output is ".$ssh->error." :: ".
                           "Command :: $rcon_cmd :: ",
                           "debug","2","$caller");
        }
        push (@ssh_output, $cmd_output);
        return \@ssh_output;
      }
    } case "get" {
      if ("$rcon_cmd" eq "none") {
        foreach my $ssh_cmd (@ssh_commands) {
          my $cmd_output=$ssh->scp_get({ recursive => 1,
                                         quiet => 0,
                                         glob => 1 }, "$ssh_cmd");
          $ssh->error and LogHandle::log_it("$rcon_host connect failed :: ".
                                            "remote command failed: ".$ssh->error,
                                            "debug","3","$caller");
          if ($ssh->error) {
           $cmd_output="ERROR";
           LogHandle::log_it("ERROR :: Output is ".$ssh->error." :: ".
                             "Command :: $ssh_cmd :: ",
                             "debug","2","$caller");
          }
          push (@ssh_output, $cmd_output);
        }
        return \@ssh_output;
      } else {
        my $cmd_output=$ssh->scp_get({ recursive => 1,
                                  quiet => 0,
                                  glob => 1 }, "$rcon_cmd");
        $ssh->error and LogHandle::log_it("$rcon_host connect failed :: ".
                                          "remote command failed: ".$ssh->error,
                                          "debug","3","$caller");
        if ($ssh->error) {
         $cmd_output="ERROR";
         LogHandle::log_it("ERROR :: Output is ".$ssh->error." :: ".
                           "Command :: $rcon_cmd :: ",
                           "debug","2","$caller");
        }
        push (@ssh_output, $cmd_output);
        return \@ssh_output;
      }
    } else {
      if ("$rcon_cmd" eq "none") {
        foreach my $ssh_cmd (@ssh_commands) {
          my $cmd_output=$ssh->capture({ tty => 1 }, "$ssh_cmd");
          $ssh->error and LogHandle::log_it("$rcon_host connect failed :: ".
                                            "remote command failed: ".$ssh->error,
                                            "debug","3","$caller");
          if ($ssh->error) {
           $cmd_output="ERROR";
           LogHandle::log_it("ERROR :: Output is ".$ssh->error." :: ".
                             "Command :: $ssh_cmd :: ",
                             "debug","2","$caller");
          }
          push (@ssh_output, $cmd_output);
        }
        return \@ssh_output;
      } else {
        my $cmd_output=$ssh->capture({ tty => 1 }, "$rcon_cmd");
        $ssh->error and LogHandle::log_it("$rcon_host connect failed :: ".
                                          "remote command failed: ".$ssh->error,
                                          "debug","3","$caller");
        if ($ssh->error) {
         LogHandle::log_it("ERROR :: Output is ".$ssh->error." :: ".
                           "Command :: $rcon_cmd :: ",
                           "debug","2","$caller");
         $cmd_output="ERROR";
        }
        push (@ssh_output, $cmd_output);
        return \@ssh_output;
      }
    }
  }
}


END { }       # Global Destructor

1;

