package Stuff::Chart;

=head1 NAME 

Stuff::Chart - base class for ASCII charts

=head1 SYNOPSIS

    use Stuff::Chart;

=head1 DESCRIPTION

Stuff::Chart is an object module that contains the generic chart
options that are extended in modules such as Stuff::HBarChart.  It
will probably never be needed by the end user, unless they want to
write their own chart style.

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
    db_out(5, "Stuff::Chart version $VERSION", "M");
}

=head2 new(I<%options>)

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
    
    db_out(8,"Stuff::Chart->new($values[0], $values[1]) OK", "M"); 
    
    return $self;
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
