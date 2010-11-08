package Stuff::StatSet;

=head1 NAME 

  Stuff::StatSet - simple statistical operations on sets of numbers

=head1 SYNOPSIS

    use Stuff::StatSet;

    my $ss = Stuff::StatSet->new(1,2,3);
    $ss->add_members(4,5);   # now has members 1,2,3,4,5
    print "max is    " . $ss->max();
    print "min is    " . $ss->min();
    print "count is  " . $ss->count();
    print "median is " . $ss->median();
    print "mean is   " . $ss->mean();
    my @numbers = $ss->members();

=head1 DESCRIPTION

Provides adn object for storing numbers and performing some basic
statistical operations on them.

=head1 MEMBER FUNCTIONS

=cut

require Exporter;

@ISA       = qw(Exporter);
@EXPORT    = qw();
@EXPORT_OK = qw();

use strict;
use Carp;
use Stuff::Debug qw(db_out);
use constant STUFF_MODULE_VERSION => "0.02";

BEGIN {
    db_out(5, "Stuff::StatSet version " . &STUFF_MODULE_VERSION, "M");
}

=head2 new(I<@values>)

Creates a new StatSet containing @values, if defined.

=cut

sub new {
    my $that = shift;
    my $class = ref($that) || $that;
    my @values = @_;

    db_out(8,"Stuff::StatSet->new() got " . ($#values + 1) . " elements in argument to new...", "M");

    my $self = bless {
	_members => \@values,
    }, $class;
    
    db_out(8,"Stuff::StatSet->new() OK", "M"); 
    
    return $self;
}

=head2 count()

Returns the number of elements contained in the StatSet.

=cut

sub count {
    my $self = shift;
    my @data = @{$self->{_members}};

    return $#data + 1;
}

=head2 sum()

Returns the sum of values contained within the StatSet

=cut

sub sum {
    my $self = shift;
    my @data = @{$self->{_members}};
    my $sum = 0;

    foreach my $i (@data) 
    {
	$sum += $i;
    }

    return $sum;
}

=head2 min()

Returns the least value within the StatSet.

=cut

sub min {
    my $self = shift;
    my @data = @{$self->{_members}};
    my $min;

    if ( $#data < 0 ) 
    {
	return undef;
    }
    else
    {
	$min = $data[0];
    }
    
    for (my $i = 1; $i <= $#data; $i++)
    {
	if ( $data[$i] < $min )
	{
	    $min = $data[$i];
	}
    }

    return $min;
}

=head2 min()

Returns the greatest value within the StatSet.

=cut

sub max {
    my $self = shift;
    my @data = @{$self->{_members}};
    my $max;

    if ( $#data < 0 ) 
    {
	return undef;
    }
    else
    {
	$max = $data[0];
    }
    
    for (my $i = 1; $i <= $#data; $i++)
    {
	if ( $data[$i] > $max )
	{
	    $max = $data[$i];
	}
    }

    return $max;
}

=head2 min()

Returns the mean (average) value within the StatSet.

=cut

sub mean {
    my $self = shift;

    return $self->sum / $self->count;
}

=head2 median()

Returns the median value within the StatSet.

=cut

sub median {
    my $self = shift;
    my @data = sort {$a <=> $b} @{$self->{_members}};

    my $median_index = int($self->count / 2);
    db_out( 8, "Stuff::StatSet::median_index = $median_index", "M");

    return $data[$median_index];
}

=head2 add_members(@values)

Adds @values to the StatSet.

=cut

sub add_members {
    my $self = shift;
    my @new_members = @_;
    push ( @{$self->{_members}}, @new_members ) ;
}

=head2 members()

Returns the members of the StatSet.

=cut

sub members {
    my $self = shift;
    return @{$self->{_members}};
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
