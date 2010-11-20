#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use Stuff::Debug qw(&db_out);
use Stuff::Usage qw(&usage &long_usage &version_message);
use Stuff::Daemon qw(&logit &make_this_process_a_daemon $log_path);
use Sys::Hostname;

use constant STUFF_PROG_DESCRIPTION => "template stuff daemon perl script";
use constant STUFF_PROG_COPYRIGHT   => "(C) XXXX; released under the GNU GPL version 2";
use constant STUFF_PROG_VERSION     => "0.01";
use constant STUFF_PROG_AUTHOR      => "Matthew Gates";

BEGIN {
    db_out(1, "program starting");
}

END {
    logit("program exiting with status " . ($? || 0));
}

GetOptions(
	   'help'              => sub { long_usage(0) },
	   'version'           => sub { version_message(); exit 0; },
	   'debug=i'           => \$Stuff::Debug::debug_level{S},
	   )     or usage(1);

eval {
	make_this_process_a_daemon();
};
if ( $@ ) { 
	db_out(-1,"Cannot transform into a daemon: $@");
	exit(0);
}

logit("Daemon started");

exit(0);


