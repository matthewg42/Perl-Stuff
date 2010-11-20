package Stuff::Daemon;

=head1 NAME

Stuff::Daemon - convenient way to make a daemon process

=head1 SYNOPSIS

 use Stuff::Daemon qw(&set_log_path &make_this_process_a_daemon &logit &daemon_sighandler);

 # note the STUFF_LOG or STUFF_TMP env var will be used as the directory

 eval {
     make_this_process_a_daemon();
 };
 die "Error making daemon: $@\n" if ( $@ );
 
 # code to run in your daemon process
 logit("I'm all daemonic");

=head1 DESCRIPTION

For making quick and easy and properly detached daemon processes.  A daemon process must 
do a few different things to be considered "well behaved", including setting the working
directory to / (to prevent it from blocking umount commands), making itself the head
of a process group, setting the right umask and so on.  All this is done by Stuff::Daemon
so you don't have to bother.

Many signals which by default lead to process termination are trapped by a daemon 
process.  Specifically HUP INT QUIT USR1 USR2 USR2 ABRT and TERM.  A Stuff::Daemon will
call Stuff::Daemon::daemon_sighandler.  The default implementation of this function
writes a message to the log file and exits. 

=head1 EXPORTS

=head2 B<$log_path>

The user should set the $Stuff::Daemon::log_path if the default is not wanted.
The default directory is taken from the STUFF_LOG environment variable, or, if that is 
not set TMP, if that is not set then the literal string F</tmp> is used.  The default 
log file basename is F<${Stuff::Debug::this_script}.log>.

Note that setting the log path has no effect once make_this_process_a_daemon() has been 
called.

=cut


require Exporter;

@ISA       = qw(Exporter);
@EXPORT    = qw(
		$log_path
		&make_this_process_a_daemon 
		&logit 
		&daemon_sighandler
		);
@EXPORT_OK = qw();

use strict;
use vars qw($VERSION $log_path $in_daemon);
use Stuff::Debug qw(db_out $this_script);
use File::Basename;
use IO::Handle;
use POSIX qw(setsid strftime);

BEGIN {
    $VERSION = '0.01';
    $SIG{'HUP'}  = \&daemon_sighandler;
    $SIG{'INT'}  = \&daemon_sighandler;
    $SIG{'QUIT'} = \&daemon_sighandler;
    $SIG{'USR1'} = \&daemon_sighandler;
    $SIG{'USR2'} = \&daemon_sighandler;
    $SIG{'USR2'} = \&daemon_sighandler;
    $SIG{'ABRT'} = \&daemon_sighandler;
    $SIG{'USR2'} = \&daemon_sighandler;
    $SIG{'TERM'} = \&daemon_sighandler;
    $in_daemon = 0;
    $log_path = ($ENV{'STUFF_LOG'} || $ENV{'TMP'} || '/tmp') . "/" . $Stuff::Debug::this_script . ".log";
    db_out(5, "Stuff::Daemon version $VERSION", "M");
}

=head1 FUNCTIONS

=over

=head2 logit(I<message>)

Write I<message> to the log file like this:

 time program[pid]: message

Time is formatted according to the format described by $Stuff::Debug::debug_timefmt
which is itself a template to the strftime POSIX function.

Note that outputting to STDERR and STDOUT will fail because daemon processes
close these file handles.

=cut

sub logit {
    my($message) = @_;
    printf DAEMON_LOGFILE "%s %s[%d]:%s\n", 
		strftime($Stuff::Debug::debug_timefmt, localtime(time)), 
		$Stuff::Debug::this_script, 
		$$, 
		$message;
}

=head2 B<make_this_process_a_daemon()>

This function turns the current program into a daemon process.  This 
involves the following steps:

=over

=item fork a new process

=item become a process group and session group leader

=item fork again so the session group leader can exit

=item change working directory to /

=item set umask to 0

=item flush and close STDERR and STDOUT

=back

For each fork, the parent terminates.  The result of all this (if successful) if that
the remaining process is a proper daemon process.

Because there's a lot that can go wrong here in terms of requesting resources from
the kernel, I feel it's a good idea to do it in an eval { ... }, and trap errors
(as shown in the SYNOPSIS section, above).

=cut

sub make_this_process_a_daemon {
    autoflush STDOUT 1;
    autoflush STDERR 1;
    $Stuff::Debug::debug_handle->autoflush();

    # OK, so we want a daemon.  We need to do all this:
    #  1. 'fork()' so the parent can exit, this returns control to the command
    #     line or shell invoking your program.  This step is required so that
    #     the new process is guaranteed not to be a process group leader. The
    #     next step, 'setsid()', fails if you're a process group leader.

    my $fork_result = fork();

    if (!defined($fork_result)) {
        db_out(-1,"Stuff::Daemon::make_this_process_a_daemon: fork() failed - probably some horrible system problem.  ABORTING", "M");
        exit(2);
    }
    elsif ( $fork_result > 0 ) {
        # We are in the parent
        db_out(1,"Stuff::Daemon::make_this_process_a_daemon: forked a child process: $fork_result.  Parent will now terminate...", "M");
        exit(0);
    }

    $in_daemon = 1;
    STDOUT->autoflush();
    STDERR->autoflush();
    $Stuff::Debug::debug_handle->autoflush();

    #  2. 'setsid()' to become a process group and session group leader. Since a
    #     controlling terminal is associated with a session, and this new
    #     session has not yet acquired a controlling terminal our process now
    #     has no controlling terminal, which is a Good Thing for daemons.

    if ( ! setsid ) {
        db_out(-1,"Stuff::Daemon::make_this_process_a_daemon: Could not create new sessiob group and become group leader.  Will ABORT.", "M");
        exit(2);
    }

    #  3. 'fork()' again so the parent, (the session group leader), can exit.
    #     This means that we, as a non-session group leader, can never regain a
    #     controlling terminal.

    $fork_result = fork();

    if ( ! defined ( $fork_result ) ) {
        db_out(-1,"Stuff::Daemon::make_this_process_a_daemon: fork() failed - probably some horrible system problem.  ABORTING", "M");
        exit(2);
    }
    elsif ( $fork_result > 0 ) {
        # We are in the parent
        db_out(1,"Stuff::Daemon::make_this_process_a_daemon: forked a child process: $fork_result.  Parent will now terminate...", "M");
        exit(0);
    }

    STDOUT->autoflush();
    STDERR->autoflush();
    $Stuff::Debug::debug_handle->autoflush();

    #  4. 'chdir("/")' to ensure that our process doesn't keep any directory in
    #     use. Failure to do this could make it so that an administrator
    #     couldn't unmount a filesystem, because it was our current directory.
    #
    #     [Equivalently, we could change to any directory containing files
    #     important to the daemon's operation.]

    if (!chdir(dirname($log_path))) {
        db_out(-1,"Stuff::Daemon::make_this_process_a_daemon: Could not cd ".dirname($log_path)." ABORTING", "M");
        exit(0);
    }

    #  5. 'umask(0)' so that we have complete control over the permissions of
    #     anything we write. We don't know what umask we may have inherited.
    #
    umask 0;

    #
    #  6. 'close()' fds 0, 1, and 2. This releases the standard in, out, and
    #     error we inherited from our parent process. We have no way of knowing
    #     where these fds might have been redirected to. Note that many daemons
    #     use 'sysconf()' to determine the limit '_SC_OPEN_MAX'.  '_SC_OPEN_MAX'
    #     tells you the maximun open files/process. Then in a loop, the daemon
    #     can close all possible file descriptors. You have to decide if you
    #     need to do this or not.  If you think that there might be
    #     file-descriptors open you should close them, since there's a limit on
    #     number of concurrent file descriptors.

    # 6a.  Open the logfile and set $Stuff::Debug::debug_handle to point at it.
    if ( ! open(DAEMON_LOGFILE,">>$log_path") ) {
        db_out(-1, "Stuff::Daemon::make_this_process_a_daemon: Could not open log: $log_path for appending: $!, ABORTING", "M");
        exit(2);
    }

    DAEMON_LOGFILE->autoflush();
    $Stuff::Debug::debug_handle = \*DAEMON_LOGFILE;

    if ( ! close(STDIN) ) {
        db_out(-1,"Stuff::Daemon::make_this_process_a_daemon: Could not close STDIN", "M");
        exit(2);
    }

    if ( ! close(STDOUT) ) {
        db_out(-1,"Stuff::Daemon::make_this_process_a_daemon: Could not close STDOUT", "M");
        exit(2);
    }

    if ( ! close(STDERR) ) {
        db_out(-1,"Stuff::Daemon::make_this_process_a_daemon: Could not close STDERR", "M");
        exit(2);
    }

    #  7. Establish new open descriptors for stdin, stdout and stderr. Even if
    #     you don't plan to use them, it is still a good idea to have them open.
    #     The precise handling of these is a matter of taste; if you have a
    #     logfile, for example, you might wish to open it as stdout or stderr,
    #     and open '/dev/null' as stdin; alternatively, you could open
    #     '/dev/console' as stderr and/or stdout, and '/dev/null' as stdin, or
    #     any other combination that makes sense for your particular daemon.

    if ( ! open(STDOUT,">>$log_path") ) {
        db_out(-1,"Stuff::Daemon::make_this_process_a_daemon: Could not assign STDOUT to the logfile: $!, ABORTING", "M");
        exit(2);
    }

    if ( ! open(STDERR,">>$log_path") ) {
        db_out(-1,"Stuff::Daemon::make_this_process_a_daemon: Could not assign STDERR to the logfile: $!, ABORTING", "M");
        exit(2);
    }

    STDOUT->autoflush();
    STDERR->autoflush();
    DAEMON_LOGFILE->autoflush();

    if (!$in_daemon) {
        db_out(1,"Stuff::Daemon::make_this_process_a_daemon: daemon process appending log: $log_path", "M"); 
    }
}

=head2 daemon_sighandler()

Writes the message:

 Signal caught: {signal} - terminating

To the logfile, and exits with error level 10.

=cut

sub daemon_sighandler {
    my($signame) = shift;

    logit("Signal caught: $signame - terminating");
    exit(10);
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

Stuff::Debug(3pm), POSIX(3pm)

=cut

