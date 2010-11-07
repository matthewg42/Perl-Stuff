package Stuff::Chart;

=head1 NAME 

Stuff::Chart - base class for ASCII charts

=head1 SYNOPSIS

    use Stuff::Chart;

=head1 DESCRIPTION

Stuff::Chart is an object module that contains the ganeric chart
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
use constant STUFF_MODULE_VERSION => "0.01";

BEGIN {
    db_out(5, "Stuff::Chart version " . &STUFF_MODULE_VERSION, "M");
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

=head1 LICENSE

Stuff::Chart is released under the GNU LGPL.

=cut
