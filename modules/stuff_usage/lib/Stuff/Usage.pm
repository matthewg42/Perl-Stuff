package Stuff::Usage;

=head1 NAME Stuff::Usage

=head1 SYNOPSIS

    use Stuff::Usage qw(&usage &long_usage);

    if ( $verbose ) {
        long_usage($error_level);
    else {
        usage($error_level);
    }

=head1 DESCRIPTION

This is for extracting long and short help messages from embedded POD
documentation in a program.  The aim is to allow all documantation to
be in POD format - even the usage information given to the user on
usage error or help requests from the command line.

=head1 FUNCTIONS

=cut

require Exporter;

@ISA        = qw(Exporter);
@EXPORT     = qw ();
@EXPORT_OK  = qw(&usage &long_usage &version_message);

use strict;
use File::Basename;
use Stuff::Debug qw(db_out $this_script);
use constant STUFF_MODULE_VERSION => "0.02";

BEGIN {
    db_out(5, "Stuff::Usage version " . &STUFF_MODULE_VERSION, "M");
}

=head2 usage(I<$lev>)

Prints a fairly brief usage message.  The message is the output of
pod2usage for the program that is currently executing.

=cut

sub usage {
    my $level = shift;

    if ( ! defined( $level) ) {
	$level = 0;
    }
    elsif ( $level !~ /^\d+$/ ) {
	die "argument must be integer";
    }

    db_out(6, "Stuff::Usage::usage: level = $level", "M");

    # open this_script and extract POD documentation.
    my $cmd = "pod2usage $this_script";

    db_out(6, "Stuff::Usage::usage: command is $cmd", "M");

    open(THISSCRIPT, "$cmd|") || die "error executing $cmd: $!";

    while(<THISSCRIPT>) {
	print;
    }

    exit($level);
}

=head2 usage(I<$lev>)

Prints a fairly brief usage message.  The message is the output of
pod2usage --verbose 1 for the program file that is currently
executing.

=cut

sub long_usage {
    my $level = shift;

    if ( ! defined( $level) ) {
	$level = 0;
    }
    elsif ( $level !~ /^\d+$/ ) {
	die "argument must be integer";
    }

    db_out(6, "Stuff::Usage::long_usage: level = $level", "M");

    # open this_script and extract POD documentation.
    my $cmd = "pod2usage -verbose 1 $this_script";

    db_out(6, "Stuff::Usage::long_usage: command is $cmd", "M");

    open(THISSCRIPT, "$cmd|") || die "error executing $cmd: $!";

    while(<THISSCRIPT>) {
	print;
    }

    exit($level);
}

=head2 version_message()

This function prints the program description and version on one line
and then the program copyright information on a second line. Note that
the values for this output comes from constants that should be defined
in the main:: package:

=over

=item main::STUFF_PROG_DESCRIPTION

This should be set to a one line description of the functionality of
the program.

=item main::STUFF_PROG_VERSION

This should be set to the version number of the program. The preferred
format is a string in decimal format, e.g. "1.02".

=item main::STUFF_PROG_COPYRIGHT

This should be set to describe the copyright status of the program,
e.g. "(C) M N Gates, 2006; Released under the GNU GPL version 2".

=back

=cut

sub version_message {
    if ( ! defined(&main::STUFF_PROG_DESCRIPTION) ) {
	warn "You should define the constant STUFF_PROG_DESCRIPTION in your program\n";
    } else {
	print &main::STUFF_PROG_DESCRIPTION . " ";
    }

    if ( ! defined(&main::STUFF_PROG_VERSION) ) {
	warn "You should define the constant STUFF_PROG_VERSION in your program\n";
    } else {
	print &main::STUFF_PROG_VERSION . "\n";
    }

    if ( ! defined(&main::STUFF_PROG_COPYRIGHT) ) {
	warn "You should define the constant STUFF_PROG_COPYRIGHT in your program\n";
    } else {
	print &main::STUFF_PROG_COPYRIGHT . "\n";
    }

    if ( defined(&main::STUFF_PROG_AUTHOR) ) {
	print "Written by " . &main::STUFF_PROG_AUTHOR . "\n";
    }
}

1;

__END__

=head1 AUTHOR

Matthew Gates E<lt>matthew@porpoisehead.netE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Matthew Gates

This library is released under the terms of the GNU LGPL Version 3, 29 June 2007.
A copy of this license should have been provided with this software (filename
LICENSE.LGPL).  The license may also be found at 
http://www.gnu.org/licenses/lgpl.html

=head1 BUGS

Reports to the author please.

=head1 SEE ALSO

=cut


