package Stuff::ParseRange;

=head1 NAME 

Stuff::ParseRange - interpret numberic ranges

=head1 SYNOPSIS

    use Stuff::ParseRange;

    


=head1 DESCRIPTION

The idea here is to parse ranges on the command line.  For example,
something like:

  print_doc --pages="-6"
  print_doc --pages="15-24"
  print_doc --pages="28-"

You should get the idea from that.  Simple stuff.  Uses the
Stuff::Range object.

This was written a while ago, and now it seems weird that it wan't
coded as a member of Stuff::Range, like Stuff::Range::Parse(...).  I'm
not sure why!  Since there are no existing programs that use it, I
think it might be better to move this functionlity into Stuff::Range
in a future release.

=head1 MEMBER FUNCTIONS

=cut

require Exporter;

@ISA       = qw(Exporter);
@EXPORT    = qw();
@EXPORT_OK = qw($max_value $min_value);

use strict;
use Carp;
use vars qw($max_value $min_value);
use Stuff::Debug qw(db_out);
use Stuff::Range;

BEGIN {
    $VERSION = '0.02';
    db_out(5, "Stuff::ParseRange version $VERSION", "M");

    $min_value = -999999999;
    $max_value = 999999999;
}

=head2 new(I<rangestring>)

Return

=cut

sub new {
    my $that = shift;
    my $class = ref($that) || $that;
    my @values = @_;
    croak "requires 0 or 1 arguments" unless ($#values <= 0);
    my $self = bless {
	_ranges => [],
    }, $class;
    
    if ( $#values == 0 ) {
	db_out(8,"Stuff::ParseRange->new($values[0]) OK","M"); 
	$self->add_range_string($values[0]);
    }
    else {
	db_out(8,"Stuff::ParseRange->new() OK", "M"); 
    }

    return $self;
}

=head2 add_range_string()

=cut

sub add_range_string {
    my $self = shift;
    my $rangestring = shift;
    my $retval = 0;

    if ( ! defined( $rangestring ) ) {
	die "an argument must be specified";
    }

    db_out ( 8, "Stuff::ParseRange->add_range_string($rangestring)", "M" ); 

    foreach my $single_range ( split(/[,;:]/, $rangestring) ) {
	$self->add_range($single_range);
	$retval++;
    }

    return $retval;
}

=head2 add_range()

=cut

sub add_range {
    my $self = shift;
    my $rangestring = shift;

    my $therange;

    db_out(8,"Stuff::ParseRange->add_range($rangestring)", "M"); 

    if ( $rangestring =~ /^\s*(-?\d+)\s*$/ ) {
	db_out(9,"Stuff::ParseRange->add_range($1 .. $1)", "M"); 
	$therange = Stuff::Range->new($1,$1);
    }
    elsif ( $rangestring =~ /^\s*(-?\d+)\s*\.\.\s*$/ ) {
	db_out(9,"Stuff::ParseRange->add_range($1 .. $max_value)", "M"); 
	$therange = Stuff::Range->new($1,$max_value);
    }
    elsif ( $rangestring =~ /^\s*\.\.\s*(-?\d+)\s*$/ ) {
	db_out(9,"Stuff::ParseRange->add_range($min_value, $1)", "M"); 
	$therange = Stuff::Range->new($min_value,$1);
    }
    elsif ( $rangestring =~ /^\s*(-?\d+)\s*\.\.\s*(-?\d+)\s*$/ ) {
	db_out(9,"Stuff::ParseRange->add_range($1,$2)", "M"); 
	$therange = Stuff::Range->new($1,$2);
    }
    else {
	die "erk, invalid range string: $rangestring\n";
    }
    
    push @{$self->{_ranges}}, $therange;

}

=head2 contains_value(I<v>)

Returns true if I<v> is within the bounds of the range(s).

=cut

sub contains_value {
    my $self = shift;
    my $value = shift;

    db_out(8,"Stuff::ParseRange->contains_value($value)", "M");

    foreach my $rangeobject ( @{$self->{_ranges}} ) {
	if ( $rangeobject->in_range($value) ) {
	    return 1;
	}
    }

    return 0;
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

Stuff::Range(3).

=cut


