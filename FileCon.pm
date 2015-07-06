package FileCon;
#
##
##########################################################################
#                                                                        #
#       File Controller / Handler                                        #
#                                                                        #
#       Copyright (C) 2012 by Vamegh Hedayati                            #
#       vamegh@gmail.com                                                 #
#                                                                        #
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
use File::Copy;
use File::Path;
#################################################
# External Modules
##
# These will need to be installed on the system
# running this script
#
# Rrefer to the installation directory which will
# provide auto installation scripts for all
# required perl modules
##
#################################################
# My Modules
##
# All provided in the ./libs directory
##
use GenDate;
use LogHandle;
#use CMDHandle;
#use libs::FileHandler;
#################################################
# Exporting variables out of module
##
use vars   qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
require Exporter;
@ISA = qw(Exporter);
@EXPORT   = qw(&create_dirs &move_files &copy_files &diff_files);
use vars qw();

#################################################
# Variables Exported From Module - Definitions
##
#################################################
# Local Internal Variables for this Module
##
my $myname="module FileCon.pm";

#################################################
#  Sub-Routines / Functions Definitions
###
# This is the actual Body of the module
##

sub create_dirs {
  my $subname="sub create_dirs";
  my $caller=$myname." :: ".$subname;

  my %args=@_;
  my $dir2create=$args{dir_name};

  #my $dir2create = shift(@_);

  if ( ! -d "$dir2create") {
    eval { mkpath("$dir2create" ,1, 0750) }
      or &log_it("Unable to make path :: ".
                 "$dir2create :: $!",
                 "error","1","$caller");
  } else {
    &log_it("Path :: $dir2create ".
            "Already Exists :: ".
            "SKIPPING CREATION",
            "debug","1","$caller");
  }
}

sub copy_files {
  my $subname="sub copy_files";
  my $caller=$myname." :: ".$subname;
  my $file2cp = "none";
  my $final_pwd = "none";
  my $mode = "none";

  if ("@_" ne '') {
    $file2cp = shift(@_);
  } if ("@_" ne '') {
    $final_pwd = shift(@_);
  } if ("@_" ne '') {
    $mode = shift(@_);
  }

  &log_it("File being copied :: $file2cp \n".
          "Final path :: $final_pwd \n".
          "mode :: $mode","debug","2","$caller");

  eval { copy("$file2cp","$final_pwd") }
        or &log_it("Unable to copy file :: ".
                   "From $file2cp to $final_pwd :: $!",
                   "error","1","$caller");

  if ("$mode" ne "none") {
    chmod oct($mode), "$final_pwd" or
      &log_it("Could Not chmod :: ".
              "$final_pwd to $mode :: $!",
              "error","1","$caller");
  }
}


sub new_copy {
  my $subname="sub new_copy";
  my $caller=$myname." :: ".$subname;

  my %args=@_;
  my $orig_file = $args{orig_file};
  my $new_file = $args{new_file};
  my $mode = $args{mode};

  LogHandle::log_it("File being copied :: $orig_file \n".
                    "Final path :: $new_file \n".
                    "mode :: $mode","debug","2","$caller");

  eval { copy("$orig_file","$new_file") }
        or LogHandle::log_it("Unable to copy file :: ".
                             "From $orig_file to $new_file :: $!",
                             "error","1","$caller");

  if ("$mode" ne "none") {
    chmod oct($mode), "$new_file" or
      LogHandle::log_it("Could Not chmod :: ".
                        "$new_file to $mode :: $!",
                        "error","1","$caller");
  }
}


sub move_files {
  my $subname="sub move_files";
  my $caller=$myname." :: ".$subname;
  #my $file2mv = "none";
  #my $final_pwd = "none";
  #my $mode = "none";
  #if ("@_" ne '') {
  #  $file2mv = shift(@_);
  #} if ("@_" ne '') {
  #  $final_pwd = shift(@_);
  #} if ("@_" ne '') {
  #  $mode = shift(@_);
  #}

  my %args=@_;
  my $file2mv=$args{orig_file};
  my $final_pwd=$args{dest_file};
  my $mode=$args{mode};

  eval { move("$file2mv","$final_pwd") }
        or &log_it("Unable to move file :: ".
                   "From $file2mv to $final_pwd :: $!",
                   "error","1","$caller");

  if ("$mode" ne "none") {
    chmod oct($mode), "$final_pwd" or
      &log_it("Could Not chmod :: ".
              "$final_pwd to $mode :: $!",
              "error","1","$caller");
  }
}

#sub diff_files {
#  my $subname="sub diff_files";
#  my $caller=$myname." :: ".$subname;
#  my $orig_file = shift(@_);
#  my $old_file = shift(@_);
#  my $diff_name = shift(@_);
#  my $diff_store="$file_store/diffs";
#
#  &create_dirs("$diff_store");
#  system("diff -duwB $orig_file $old_file >> $diff_store/$diff_name.diff.$date");
#}


END { }  #  Global Destructor

1;

#################################################
#
################################### EO PROGRAM #######################################################
#
################################ MODULE HELP / DOCUMENTATION SECTION #################################
##
##
# To access documentation please use perldoc LocSorter.pm, This will provide
# the formatted help file for this specific module
##
#################################################
#
__END__

=head1 NAME

LocSorter.pm -

=head1 SYNOPSIS

This is the main core of the locsorter program

=head1 DESCRIPTION

This a module that provides 4 subroutines all of which are exported as follows:

* create_dirs()

This calls make path but is called via eval and catches errors.

* diff_files ()

This does the actual comparison and calls the system diff function (proper classy right ? ... Not :), but it does the job)

* copy_files ()

This calls eval around file::copy so as to catch errors cleanly and also sets file permissions.

* move_files ()

This calls eval around file::copy move function so as to catch errors cleanly and also sets file permissions.

This Module has to be called by a perl script or module and requires File::Path and File::Copy

This Module also requires the following automaton libs ::

* libs::LogHandle

* libs::CMDHandle

* libs::FileHandler

* libs::GenDate


=head1 AUTHOR

=over

=item Vamegh Hedayati <vamegh AT gmail DOT com>

=back

=head1 LICENSE

Copyright (C) 2012  Vamegh Hedayati <vamegh AT gmail DOT com>

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

Please refer to the COPYING file which is distributed with vFATS
for the full terms and conditions

=cut
#
#################################################
#
######################################### EOF  #######################################################

