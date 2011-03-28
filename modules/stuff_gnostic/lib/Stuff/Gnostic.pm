package Stuff::Gnostic;

=head1 NAME 

Stuff::Gnostic - format data for parsing by Gnostic visualization tool

=head1 SYNOPSIS

    use Stuff::Gnostic;

    my $g = new Stuff::Gnostic();
    print $g->item($label, $value, [$timestamp]);


=head1 DESCRIPTION

Stuff::Gnostic is used to format data for output to the Gnostic data visualization
tool.  

See also: http://porpoisehead.net/mysw/gnostic

=head1 MEMBER FUNCTIONS

=cut

require Exporter;

@ISA       = qw(Exporter);
@EXPORT    = qw();
@EXPORT_OK = qw();

use strict;
use vars qw($VERSION);
use Carp;
use Date::Manip;
use Time::HiRes;
use Stuff::Debug qw(db_out);

BEGIN {
    $VERSION = '0.01';
    db_out(5, "Stuff::Gnostic version $VERSION", "M");
}

=head2 new(I<%params>)

A new Stuff::Gnostic is returned.  The parameters are in hash form.  Valid parameters:

=over

=item B<Delimiter> (I<string>)

The default is ';'.

=item B<Format> (I<string>)

Specify the format of the numeric part of the output.  By default this is "%.5f".

=back

=cut

sub new {
    my $that = shift || croak 'object fail';
    my $class = ref($that) || $that;
    my %params = @_;
    my $self = {};

    if (defined($params{'Delimiter'})) { $self->{'_delimiter'} = $params{'Delimiter'}; } 
    else { $self->{'_delimiter'} = ';'; }

    if (defined($params{'Format'})) { $self->{'_format'} = $params{'Format'}; }
    else { $self->{'_format'} = '%.5f'; }

    $self->{'_header_printed'} = 0;

    bless $self, $class;
    
    db_out(8,"Stuff::Gnostic->new(Delimiter => " . $self->{'_delimiter'} . ") OK", "M"); 
    
    return $self;
}

1;

=head2 item($label, $value, [$timestamp])

Add items to the Gnostic.

=cut

sub item {
    my $self = shift || croak 'object fail';
    my $label = shift || return  "";
    my ($value, $timestamp);
    if (!defined($_[0])) {
   	return "";
    }
    else {
        $value = shift;
    }
   
    if (!defined($_[0])) {
   	$timestamp = Time::HiRes::time;
    }
    else {
        my $dt = ParseDate($_[0]);
        if ($dt eq "") {
	    $timestamp = Time::HiRes::time;
	} 
	else {
	    $timestamp = UnixDate($dt, "%s");
	    if ($_[0] =~ /:\d\d(\.\d+)$/) {
		$timestamp .= $1;
	    }
        }
    }
    $timestamp = int($timestamp * 1000);

    my $f = $self->{'_format'};
    my $d = $self->{'_delimiter'};

    my $h = $self->header();
    return sprintf "$h%s%s${f}%s%s\n", $timestamp, $d, $value, $d, $label;
}

=head2 header($force)

Returns the Gnostic header.  Unless force is defined and is not 0, this function
will only return something the first time it is called.  Subsequent calls without
$force set will return "".  You probably never need to call this yourself as the
first call to item() will include the output of this call.

=cut

sub header {
    my $self = shift || croak 'object fail';
    my $force;
    if (defined($_[0])) {
	$force = 1;
    }
    if (!$self->{'_header_printed'} || $force) {
        my $res = "";
	$res .= "GNOSTIC-DATA-PROTOCOL-VERSION=1.0\n";
	$res .= "DELIMITER=" . $self->{'_delimiter'} . "\n";
	$res .= "END-HEADER\n";
	$self->{'_header_printed'} = 1;
	return $res;
    }
    else {
	return "";
    }
}

1;

__END__

=head1 AUTHOR

Matthew Gates E<lt>matthew@porpoisehead.netE<gt>

=head1 COPYRIGHT & LICENSE

Copyright (C) 2011 by Matthew Gates

This library is released under the terms of the GNU LGPL Version 3, 29 June 2007.
A copy of this license should have been provided with this software (filename
LICENSE.LGPL).  The license may also be found at 
http://www.gnu.org/licenses/lgpl.html

=head1 BUGS

Reports to the author please.

=head1 SEE ALSO

Stuff(7)

=cut

