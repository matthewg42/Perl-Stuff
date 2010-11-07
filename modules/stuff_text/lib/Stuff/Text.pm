package Stuff::Text;

=head1 NAME

Stuff::Text - text manipulation knick-knacks

=head1 DESCRIPTION

Text manipulation gubbins.

=head1 FUNCTIONS

=cut

use strict;
use Carp;
use POSIX;
use Stuff::Debug qw(db_out);
use constant STUFF_MODULE_VERSION => "0.02";

BEGIN {
    db_out(5, "Stuff::Text version " . &STUFF_MODULE_VERSION, "M");

    use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

    @ISA         = qw(Exporter);
    @EXPORT      = qw();
    %EXPORT_TAGS = qw();
    @EXPORT_OK   = qw(&delimit_data &delimited_data_to_array);

    1;
}

=head2 delimit_data ( I<hash> )

Return a delimited string with some data in it.  The argument to the
function is a hash.  The best way to illustrate it is with an example:

    my @data = ("one", "two", "three");
    my $delimited = delimit_data(
	 		         data => \@data,
				 delimiter => ","
				 quote => "'",
				 trim => 1
				 );


Only "data" and "delimiter" are required, the other keys are optional.

"trim" should evalue are true or false like any normal perl
expression.  Recommended values are: 0 and 1 or just leave it out
entirely if you do not want trimmming.

There is no ltrim / rtrim at this time.  So prune your own data if you
need that.

This will yield a value in $delimited: "'one','two','three'".  If the
delimiter is found in the data, it is escaped using the backslash
character if the quote is not defined.  Similarly, quotes are escaped
with a backslash if they exist in the data and quoting is on.

=cut

sub delimit_data {
    my %h = @_;
    my $retval = "";

    my $required_member;
    foreach $required_member (qw(delimiter data)) {
	if ( ! defined( $h{$required_member} ) ) {
	    die "delimit_array requires the member $required_member to work";
	}
    }

    my $delim = $h{"delimiter"};
    my $ar = $h{"data"};
    my @a  = @$ar;

    my $qt    = "";
    my $nvl = "";
    my $trim = 0;

    if ( defined($h{"quote"}) ) {
	$qt = $h{"quote"};
    }

    if ( defined($h{"null_value"}) ) {
	$nvl = $h{"null_value"};
    }

    if ( defined($h{"trim"}) ) {
	$trim = $h{"trim"};
    }

    # If we are not quoting, escape each delimiter in the data with a backslash
    # else, escape quotes in the data and quote each term
    my $i;
    for ( $i = 0 ; $i <= $#a; $i++ ) {
	# if we have "trim" selected, zap whitespace both ends of the data
	if ( $trim ) {
	    $a[$i] =~ s/^\s+//;
	    $a[$i] =~ s/\s+$//;
	}

	if ( $qt eq "" ) {
	    $a[$i] =~ s/$delim/\\$delim/g;
	}
	else {
	    $a[$i] =~ s/$qt/\\$qt/g;
	    $a[$i] = $qt . $a[$i] . $qt;
	}

	# Finally, append the term to the result and add the delimiter character
	$retval .= $a[$i] . $delim;
    }

    # and chop off the last delimiter character
    for(my $i=0; $i<length($delim); $i++) {
	chop $retval;
    }
  
    # and return the result!
    return $retval;
}

=head2 delimited_data_to_array(%data)

Takes a hash with the same sort of keyvalue pairs as delimit_data,
except \@data becomes $data - a scalar containing the string to be
exploded into an array, which is returned.

=cut

sub delimited_data_to_array {
    my %h = @_;
    my @retval;

    my $required_member;
    foreach $required_member (qw(delimiter data)) {
	if ( ! defined( $h{$required_member} ) ) {
	    die "delimit_array requires the member $required_member to work";
	}
    }

    my $delim = $h{"delimiter"};
    my $input = $h{"data"};

    my $qt    = "";
    my $nvl = "";
    my $trim = 0;

    if ( defined($h{"quote"}) ) {
	$qt = $h{"quote"};
    }

    if ( defined($h{"null_value"}) ) {
	$nvl = $h{"null_value"};
    }

    if ( defined($h{"trim"}) ) {
	$trim = $h{"trim"};
    }

    if ( $qt eq "" ) {
	# The data is not quoted.  We will split it on $delim, but must use a the 
	# negative look-behind extension so we can ignore escaped $delims without
        # non-escaped de-limiters having the previous character included in the
        # split expression.
	my @data = split( /(?<!\\)$delim/, 
			  $input );
	for(my $i=0; $i<=$#data; $i++) {
	    if ( $trim ) {
		$data[$i] =~ s/^\s*$qt//;
		$data[$i] =~ s/$qt\s*$//;
	    }

	    $data[$i] =~ s/\\$delim/$delim/g;
	    return @data;
	} 
    
    }
    else {
	# In the case of quoted values, $delim will not be escaped in each item
	# so we don't have to bother about that.  Makes things a bit easier,
	# but we have to remember to trim the quotes afterwards.
	my @quoted_data = split(/$delim/, $input);
	for(my $i=0; $i<=$#quoted_data; $i++) {
	    $quoted_data[$i] =~ s/^\s*$qt//;
	    $quoted_data[$i] =~ s/$qt\s*$//;
	    $quoted_data[$i] =~ s/\\$qt/$qt/g;
	} 
	return @quoted_data;
    }

}

1;

__END__

=head1 LICENSE

Stuff::StatSet is released under the GNU LGPL.

=head1 AUTHOR

Author: Matthew Gates <matthew@porpoisehead.net>

http://porpoisehead.net/

=head1 BUGS

Reports to the author please.

=head1 HISTORY

=over

=item on 2005-02-10 Better documentation, MNG

=item on 2004-01-13 Initial documentation, MNG

=item on 2003-11-?? Initial implementation, MNG

=back

=head1 SEE ALSO

=cut


