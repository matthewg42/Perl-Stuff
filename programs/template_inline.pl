#!/usr/bin/perl -w
#
# See POD docs at end of this file for genereal info

use strict;
use File::Basename;
use Getopt::Long;

use constant PROG_DESCRIPTION => "template stuff perl script";
use constant PROG_COPYRIGHT   => "(C) XXXX; released under the GNU GPL version 2";
use constant PROG_VERSION     => "0.01";
use constant PROG_AUTHOR      => "Matthew Gates";

my $this_script = basename($0);

GetOptions(
	   'help'              => sub { usage(0,1) },
	   'version'           => sub { version_message(); exit 0; },
	   )     or usage(1,0);

exit 0;

sub usage {
	my $level = shift || 0;
	my $verbose = shift || 0;

	if ( $level !~ /^\d+$/ ) { die "argument must be integer"; }

	my $cmd;
	if ( $verbose ) { $cmd = "pod2usage -verbose 1 $this_script"; }
	else { $cmd = "pod2usage $this_script"; }

	open(CMD, "$cmd|") || die "error executing $cmd: $!";
	while(<CMD>) { print; }
	close(CMD);
	exit($level);
}

sub version_message {
	if ( ! defined(&PROG_DESCRIPTION) ) {
		warn "You should define the constant PROG_DESCRIPTION in your program\n";
	} else {
		print &PROG_DESCRIPTION . " ";
	}

	if ( ! defined(&PROG_VERSION) ) {
		warn "You should define the constant PROG_VERSION in your program\n";
	} else {
		print &PROG_VERSION . "\n";
	}

	if ( ! defined(&PROG_COPYRIGHT) ) {
		warn "You should define the constant PROG_COPYRIGHT in your program\n";
	} else {
		print &PROG_COPYRIGHT . "\n";
	}

	if ( defined(&PROG_AUTHOR) ) {
		print "Written by " . &PROG_AUTHOR . "\n";
	}
}


__END__

=head1 NAME 

__S__ - tempate perl script for Stuff

=head1 SYNOPSIS

__S__ [options]

=head1 DESCRIPTION



=head1 OPTIONS

=over

=item B<--debug>=I<level>

Print diagnostic messages while executing.  The value of I<level> must be an
integer.  The higher the number, the more verbose the diagnostic output will
be.

=item B<--help>

Print the command line syntax an option details.

=item B<--version>

Print the program description and version.

=back

=head1 ENVIRONMENT

=over

=item STUFF_?_DBLEVEL

Sets debugging levels.  The ? can be D for database, M for module,
or S for script debugging messages.  Generally only S and D are
interesting for users, M is mostly just used during development.

=back

=head1 FILES

=over

=item filename

desc

=back

=head1 LICENSE

__S__ is released under the GNU GPL ((version 3, 29 June 2007).

=head1 AUTHOR

Matthew Gates <matthew@porpoisehead.net>

http://porpoisehead.net/

=head1 CHANGELOG

=over

=item Date:YYYY-MM-DD Created, Author MNG

Original version.

=back

=head1 BUGS

Please report bugs to the author.

=head1 SEE ALSO


=cut

