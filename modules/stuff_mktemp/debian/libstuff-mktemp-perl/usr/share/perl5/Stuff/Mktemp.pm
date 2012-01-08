package Stuff::Mktemp;

=head1 NAME

Stuff::Mktemp

=head1 SYNOPSIS

    use Stuff::Mktemp qw(&mktemp &cleanup_temp_files 
                         @temp_files 
                         $tempfile_prefix $temp_dir $tempfile_tries);

    my $tf1 = mktemp();
    my $tf2 = mktemp();

    ...

    cleanup_temp_files();

=head1 DESCRIPTION

This module began life as a habit of writing my own mktemp function in
shell scripts on some old Solaris boxen where the system mktemp was
buggy.  Since then I got addicted to auto-cleanup of temp files, and
so this module continues that suspect practise.

The module keeps track of temporary files that are created by calling
the mktemp() function.  When cleanup_temp_files() is called they are
unlinked if they still exist.  It's probably a good idea to trap
various signals that might kill you program and have your sigtrap
function call cleanup_temp_files().

The location and name of the temp files is determined by some
environment varaibles.  See the ENVIRONMENT section below for more
details.

=head1 FUCTIONS

=cut

require Exporter;

@ISA        = qw(Exporter);
@EXPORT     = qw();
@EXPORT_OK  = qw(&mktemp $temp_dir @temp_files &cleanup_temp_files $tempfile_prefix $tempfile_tries);

use strict;
use vars qw(@temp_files $temp_dir $tempfile_prefix $tempfile_tries $VERSION);
use Stuff::Debug qw(db_out);

BEGIN {
    $VERSION = '0.03';
    db_out(5, "Stuff::Mktemp version $VERSION", "M");

    @temp_files = ();
    if ( defined($ENV{TMP}) ) {
	$temp_dir = $ENV{TMP};
    }
    elsif ( defined($ENV{TEMP}) ) {
	$temp_dir = $ENV{TEMP};
    }
    else {
	foreach my $candidate (qw(/var/tmp /tmp .)) {
	    if ( -d $candidate ) {
		$temp_dir = $candidate;
		last;
	    } 
	}
    }
    if ( ! -w $temp_dir || ! -r $temp_dir || ! -d $temp_dir ) {
	die "coudn't get a readable, writable directory for temp files.  Please set TMP or TEMP env var properly";
    }

    if ( defined($ENV{STUFF_TMPFILE_PREFIX}) ) {
	$tempfile_prefix = $ENV{STUFF_TMPFILE_PREFIX};
    }
    else {
	$tempfile_prefix = "stuff";
    }

    if ( defined($ENV{STUFF_TMPFILE_TRIES}) ) {
	if ( ! /^\d+$/ ) {
	    $tempfile_tries = $ENV{STUFF_TMPFILE_TRIES};
	}
	else {
	    die "env var Stuff_TMPFILE_TRIES must be an integer";
	}
    }
    else {
	$tempfile_tries = 100;
    }
}

END {
    cleanup_temp_files()
}

=head2 mktemp([I<suffix>])

Tries to create a temporary file in $Stuff::Mktemp::temp_dir.  If
I<suffix> is provided, the filename will have a .suffix ending.  This
is provided for fussy programs that just MUST have the correct
extension on the filename (e.g. sqlplus).

The name of the temp file is determined by
$Stuff::Mktemp::tempfile_prefix, pid, timestamp, some random component
and the I<suffix> is defined.  If the file already exists, another try
will be made.  This will be repeated until
$Stuff::Mktemp::tempfile_tries tries have been made, at which point
mktemp will give up and the exception "couldn't get tempfile" will be
thrown.  Note that this may also occur if the value of TMP is a
non-writable directory, so you better be ready to catch those
exceptions!

On success, the filename will be returned.  This will point to an
empty file.

=cut

sub mktemp {
    my ($suffix);
    if ( ! defined( $_[0] ) ) { $suffix = "." . $_[0]; }
    else { $suffix = ""; }

    my $try=1;
    my $candidate;
    my $timestamp = time();

    while ($try <= $tempfile_tries) {
	$candidate = sprintf( "%s/%s%05d%d%d%s", 
				 $temp_dir, 
				 $tempfile_prefix,
				 $$,
				 $timestamp,
				 int(rand() * 65536),
				 $suffix );
	
	if ( ! -e $candidate ) {
	    last;
	}
	else {
	    db_out(6,"Stuff::Mktemp::mktemp--candiate already exists: $candidate", "M");
	}               
	$try++;
    }

    if ( ! -e $candidate ) {
	push @temp_files, $candidate;
	open(TMP,">$candidate") || die "cannot create empty tempfile: $!";
	close(TMP);
	chmod 0600, ($candidate);
	db_out(3,"Stuff::Mktemp::mktemp--OK, we thought $candidate was good...", "M");
	return $candidate;
    }
    else {
	die "couldn't get tempfile";
    }
}

=head2 cleanup_temp_files()

ALl tempfiles thaty were created by calling Stuff::Mktemp::mktemp()
will be unlinked when this function is called.  It's intended use is
that the end of a program.  You might want to put it in the SIGs for
KILL, HUP, USR?, and __DIE__.  It's not returning anything.

=cut

sub cleanup_temp_files {
    if ( defined( $ENV{STUFF_TMPFILE_DIRTY} ) ) {
	db_out(2,"Stuff_TMPFILE_DIRTY is set - will NOT clean up temp files: @temp_files", "M");
    }
    else {
	db_out(2,"Cleaning up tempfiles: @temp_files", "M");
	unlink @temp_files;
    }
}

1;

__END__

=head1 AUTHOR

Matthew Gates E<lt>matthew@porpoisehead.netE<gt>

=head1 COPYRIGHT & LICENSE

Copyright (C) 2010 by Matthew Gates

This library is released under the terms of the GNU LGPL Version 3, 29 June 2007.
A copy of this license should have been provided with this software (filename
LICENSE.LGPL).  The license may also be found at 
http://www.gnu.org/licenses/lgpl.html

=head1 BUGS

Reports to the author please.

=head1 SEE ALSO

=cut

