package Stuff::Debug;

=head1 NAME

Stuff::Debug - convenient debugging output for perl programs

=head1 SYNOPSIS

    use Stuff::Debug qw(&db_out);

    # If this is not set explicitly it will be set from 
    # $ENV{STUFF_S_DBLEVEL} if defined, or 0 otherwise
    # btw, the "S" is for "Script".  You may also choose
    # "M" for module, and "D" for database.
    $Stuff::Debug::debug_level{S} = 5;  
                                       
    # This is STDERR if not set explicitly          
    $Stuff::Debug::debug_handle = \*STDOUT;

    db_out(4,  "This will be displayed");
    db_out(5,  "This will be displayed");
    db_out(6,  "This will not be displayed");
    db_out(0,  "This will create a WARNING");
    db_out(-1, "This will create an ERROR");
    db_out(-1, "This will also create an ERROR");
    db_out(5,  "This would be used in a module", "M");
    db_out(5,  "This would be used in a database debug message", "D");

    print "The name this program was invoked with is: $Stuff::Debug::this_script\n";

=head1 DESCRIPTION

This module hold some state in the form of a set of debug levels.
These levels are categorized as "S" for script, "M" for module and "D"
for database.

The module provides a single function &db_out that is called to send
debugging messages to STDERR (or another handle if required) with a
nice format.  Messages are given a level.  If the level specified in
the call to &db_out is less than or equal to the current level held in
the module, the message will be printed, otherwise nothing will
happen.  

This is useful for peppering your programs with debugging output at
various levels of verbosity.  By setting the module debug level a few
or more or all of these messages may be turned on and off.

It is customary to set the debugging level from the command line
option B<--debug>=I<level> like this:

    use Stuff::Debug qw(&db_out);
    use Getopt::Long;

    my $optstatus = GetOptions(
                               "debug=i" => \$Stuff::Debug::debug_level{'S'},
                               ...
                              );

=head1 FUNCTIONS

=cut

require Exporter;
use POSIX;

@ISA=qw(Exporter);
@EXPORT     = qw (&db_out);
@EXPORT_OK  = qw(%debug_level $debug_handle $debug_timefmt $this_script);

use strict;
use vars qw(%debug_level $debug_handle $debug_timefmt $this_script $VERSION);
use File::Basename;

use constant STUFF_MODULE_VERSION => 0.02;

BEGIN {
    # set this to undef to omit time from debug message.  This will save a 
    # few processor cycles so it might be good if you have very verbose 
    # debugging output
    $debug_timefmt = "%Y%m%d-%T %z";

    foreach my $dbtype ( qw (D S M) ) {
	my $envname = "STUFF_" . $dbtype . "_DBLEVEL";
	$debug_level{$dbtype} = 0;
	if ( defined($ENV{$envname}) ) {
	    $debug_level{$dbtype} = $ENV{$envname};
	}
    }

    if ( defined($ENV{STUFF_DEBUG_HANDLE}) ) {
  	if ( $ENV{STUFF_DEBUG_HANDLE} =~ /stdout/i ) {
  	    $debug_handle = \*STDOUT;
  	}
	else {
	    $debug_handle = \*STDERR;
	}
    }
    else {
  	$debug_handle = \*STDERR;
    }

    $this_script = basename($0);

    # The one and only time we print our debugging message without using the db_out functio
    if ( $debug_level{"M"} >= 5 ) {
        my $timestr = "";
        if ( defined( $debug_timefmt ) ) {
	    $timestr = strftime($debug_timefmt, (localtime(time)) ) . " ";
        }
	    printf $debug_handle "%s%s[%d]/%s %s: %s\n", $timestr, $this_script, $$, "M", "DEBUG[5]", "Stuff::Debug::BEGIN: version is " . &STUFF_MODULE_VERSION;
        }

    return 0;
}

=head2 db_out(I<message_level>, I<message>, [I<message_type>])


If %Stuff::Debug::debug_level{I<message_type>} is greater than or
equal to I<message_level>, then I<message> will be printed on
$Stuff::Debug::debug_handle.

If I<message_type> is not specified, "S" is used.

The format of the message depends on the values of I<message_level>,
I<message_type> and $Stuff::Debug::debug_timefmt.

The most notable difference is that if I<message_level> is greater
than 0 the message will be a DEBUG, if it is equal to 0, the message
will be a WARNING, and if it less than 0 the message with be an ERROR.

The type of the message is also in there, and a formatted time is
added at the front if $Stuff::Debug::debug_timefmt is defined.  

See the EXAMPLE section for actual formatting.

NOTE: if you have a very large number of debugging messages in your
code (e.g. in very tight loops), but you don't want to display them,
you'd be best off commenting them out to remove the overhead of a the
call to the funtion.  The next best thing is to set
$Stuff::Debug::debug_level{type} to undef.  It'll only save a little
though. 

If you wish to improve the performance of debugging output itself, try
turning off the date/time by setting $Stuff::Debug::debug_timestr =
undef.  You'll not get the time in the output, but it will save a few
CPU cycles.

=cut

sub db_out {
    if ( $#_ < 1 ) {
	die "usage: db_out([type],level,message...)"; 
    }

    my($type);
    if ( $#_ >= 2 ) { $type = $_[2];    }
    else            { $type = "S";     }

    # This shouldn't happen unless  someone has messed up 
    # %Stuff::Debug::debug_level
    if ( ! defined( $debug_level{$type} ) ) { return; }

    my($level) = shift @_;

    # OK we test the level now before we go any further to minimize the 
    # impact of verbose calls to db_out when db_out won't display anything.

    # OK, die horribly on bad usage.  That'll learn 'em.
    if ( $level !~ /^-?\d+$/ ) { 
	die "db_out: level must be numeric: $level";
    }

    # do nothing more if $level is above the current threshhold for this 
    # type of debugging output.
    if ( $debug_level{$type} < $level ) { return; }

    # Get the message
    my($message) = shift @_;

    # print "db_out internal debug: type    is $type\n";
    # print "db_out internal debug: level   is $level\n";
    # print "db_out internal debug: message is $message\n";

    # Stick any remaining parameters in the message too.  Hopefully there 
    # shouldn't be any, but you never know
    while ( $#_ >= 0 ) {
	$message .+ " " . shift @_;
    }

    my $timestr = "";
    # get nicely formatted time if $Stuff::Debug::debug_timefmt is defined
    if ( defined( $debug_timefmt ) ) {
	$timestr = strftime($debug_timefmt, (localtime(time)) ) . " ";
    }
    
    # Finally do the output
    printf $debug_handle "%s%s[%d]/%s %s: %s\n", $timestr, $this_script, $$, $type, level_type($level), $message;
}

# Not exported.
# Just returns a nice description of the debugging level.
sub level_type {
    if ( $_[0] == 0 ) { "WARNING"; }
    elsif ( $_[0] > 0 ) { "DEBUG[$_[0]]"; }
    else { "ERROR[$_[0]]"; } 
}

1;

__END__

=head1 EXAMPLES

Here we see some examples of calls to &db_out and the expected output.
We are assuming the debug levels are set so the message will be
visible.  The 12345 is the PID.

    db_out(1,"This is a test message");
    # output: 20050210-21:28:42 testprog[12345]/S DEBUG[1]: This is a test message

    db_out(8,"This is a test message too", "M");
    # output: 20050210-21:28:53 testprog[12345]/M DEBUG[8]: This is a test message too

    db_out(0,"This is a test warning");
    # output: 20050210-21:29:22 testprog[12345]/S WARNING: This is a test warning

    db_out(-1,"This is a test error", "M");
    # output: 20050210-21:30:02 testprog[12345]/S ERROR[-1]: This is a test error

=head1 LICENSE

Stuff::Debug is released under the GNU LGPL.

=head1 AUTHOR

Author: Matthew Gates <matthew@porpoisehead.net>

http://porpoisehead.net/

=head1 BUGS

Reports to the author please.

=head1 SEE ALSO

=cut



