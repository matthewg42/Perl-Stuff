package Stuff::Range;

=head1 NAME 

Stuff::Range

=head1 SYNOPSIS

    use Stuff::Range;

    my $r1 = Stuff::Range->new(100,200);
    print "upper = " . $r1->upper() . "\n"; 


=head1 DESCRIPTION

Stuff::Range is an object module that models simple numeric ranges.
Each range has an upper and lower value.  Various things may be done
to ranges, including checking if a value falls with the range, merging
with other Stuff::Ranges, testing if a range is bound by another range
and so on.

=head1 MEMBER FUNCTIONS

=cut

require Exporter;

@ISA       = qw(Exporter);
@EXPORT    = qw();
@EXPORT_OK = qw();

use strict;
use Carp;
use Stuff::Debug qw(db_out);

BEGIN {
    $VERSION = '0.02';
    db_out(5, "Stuff::Range version $VERSION", "M");
}

=head2 new(I<v1>, I<v2>)

A new Stuff::Range is returned.  The lower and upper values of I<v1>
and I<v2> will be chosen automatically.  I<v1> and I<v2> must be
numeric or you're going to get problems.  There is presently no
checking in the new() function though - so you must check your own
numbers.  You'll soon find out of course.

=cut

sub new {
    my $that = shift;
    my $class = ref($that) || $that;
    my @values = sort { $a <=> $b } @_;
    croak "requires two arguments" unless (@values == 2);
    my $self = bless {
	_lower => $values[0],
	_upper => $values[1],
    }, $class;
    
    db_out(8,"Stuff::Range->new($values[0], $values[1]) OK", "M"); 
    
    return $self;
}

=head2 low()

Returns the lower value of the range.

=cut

sub low  { 
    $_[0]->{_lower}; 
}

=head2 high()

Returns the upper value of the range.

=cut

sub high { 
    $_[0]->{_upper}; 
}

=head2 diff()

Returns upper - lower.

=cut

sub diff { 
    $_[0]->{_upper} - $_[0]->{_lower};
}

=head2 in_range(I<value>

Returns 1 if I<value> is within the range. (lower <= I<value> <= upper).

=cut

sub in_range {
    my $self = shift;
    my $value = shift;
    if ( $value >= $self->low && $value <= $self->high ) {
	return 1;
    }
    else {
	return 0;
    }
}

=head2 bound_high(I<value>)

Returns a new range object that has the same lower value as the
existing range object, but upper is I<value> if I<value> falls within
the existing range.

BUG: Looking at this I suppose this should return an empty range is
I<value> is lower than the value of the existing range's lower value?

=cut

sub bound_high {
    my $self = shift;
    my $value = shift;
    
    if ( $self->in_range($value) ) {
	return $self->new($self->low, $value);
    }
    else {
	return $self->new($self->low, $self->high);
    }
}

=head2 bound_low(I<value>)

Like bound_high, except that the lower end of the original range is
moved up if I<value> is greater than it.

=cut

sub bound_low {
    my $self = shift;
    my $value = shift;
    
    if ( $self->in_range($value) ) {
	return $self->new($value, $self->high);
    }
    else {
	return $self->new($self->low, $self->high);
    }
}

=head2 bound_range(I<range>)

Returns a new range that is the intersection of the orinigal range and
I<range>.

=cut

sub bound_range {
    my $self = shift;
    my $range2 = shift;
    
    my $tmprange = $self->bound_low($range2->low);
    return $tmprange->bound_high($range2->high);
}

=head2 intersects_with(I<range>)

Returns 1 if there is an intersection of the two ranges, else 0.

=cut

sub intersects_with {
    my $self = shift;
    my $range2 = shift;
    
    if (    $self->high   < $range2->low
	    || $range2->high < $self->low    ) {
	return 0;
    }
    else {
	return 1;
    }
}

=head2 us_superset_of(I<range>)

Returns 1 if I<range> is a superset of the exsting range object.

=cut

sub is_superset_of {
    my $self = shift;
    my $range2 = shift;
    
    if (    $self->low < $range2->low 
	    && $self->high > $range2->high  ) {
	return 1;
    }
    else {
	return 0;
    }
}

=head2 is_subset_of(I<range>)

Returns 1 if I<range> is a subset of the exsting range object.

=cut

sub is_subset_of {
    my $self = shift;
    my $range2 = shift;
    
    if (    $self->low > $range2->low 
	    && $self->high < $range2->high  ) {
	return 1;
    }
    else {
	return 0;
    }
}

=head2 equal(I<range>)

Returns 1 if the two ranges are the same.

=cut

sub equal {
    my $self = shift;
    my $range2 = shift;
    
    if ( $self->low == $range2->low &&  $self->high == $range2->high ) {
	return 1;
    }
    else {
	return 0;
    }
}

=head2 consolidate(I<range>)

Returns the range from the lowest low value to the greatest upper
value of the two ranges.

=cut

sub consolidate {
    my $self = shift;
    my $range2 = shift;
    
    return $self->new( 	min( $self->low,  $range2->low  ),
			max( $self->high, $range2->high )  );
}

=head2 string()

Returns a string representation of the range.  The format
"{low,high}", e.g. "{4,8}".

=cut

sub string {
    my $self = shift;
    my $coderef = shift;
    
    if ( ! defined($coderef) ) {
	$coderef = sub { return $_[0]; }
    }
    
    return "{" . &$coderef( $self->low ) . " .. " . &$coderef( $self->high ) . "}";
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

Stuff(7)

=cut

