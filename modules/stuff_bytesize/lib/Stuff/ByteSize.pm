package Stuff::ByteSize;

=head1 NAME

Stuff::ByteSize - convert numbers to n-byte sizes (e.g. KiB)

=head1 SYNOPSIS

    use Stuff::ByteSize qw(&bytes2sz);

    my $size = int(rand() * 100000000000);
    printf( "%d bytes = %s\n", $size, bytes2sz($size) ); 

=head1 DESCRIPTION

Here you can convert from a [possibly very large] number of bytes into
some more managable unit such as Gigi-bytes.  Well, almost.  Many
programmers are guilty of doing the calculation incorrrectly, and
almost all don't use the proper nomenclature.

The proper (SI standardized) names and quantities are described here:
http://physics.nist.gov/cuu/Units/binary.html.  This module inplements
convertsion between quantities of bytes and some confortable binary
multiples.  

So now you know!

=cut

require Exporter;

@ISA=qw(Exporter);
@EXPORT     = qw (&bytes2sz);
@EXPORT_OK  = qw();

use strict;
use Stuff::Debug;

use constant STUFF_MODULE_VERSION => "0.02";

BEGIN {
    db_out(5, "Stuff::ByteSize version " . &STUFF_MODULE_VERSION, "M");
}

=head1 FUNCTIONS

=head2 bytes2sz(I<num_bytes>, [I<fmt>])

Converts an integer number of bytes to a string describing the size in 
terms of KiB, MiB, GiB, TiB, PiB, where: 

    1 KiB = 2^10 bytes (kibibyte), 
    1 MiB = 2^20 bytes (mebibyte)
    1 GiB = 2^30 bytes (gibibyte),
    1 TiB = 2^40 bytes (tebibyte),
    1 PiB = 2^50 bytes (pebibyte),
    1 EiB = 2^60 bytes (exbibyte).

The denomination is chosen so that the numerical part is always < 1000
(or 1024 for bytes) so you should never see a result like "5200
bytes", or "9234 MiB" - the unit will be knocked up to the next
multiple in each case.

The parameter I<num_bytes> is an integer number of bytes to convert to
a byte size.

The optional I<fmt> parameter is a printf style format string for the
numerical part of the result.  E.g. %.3f to limit the result to 3
decimal places.  Note that bytes will always be shown as an integer
regardless of the value of I<fmt>

Examples:

    Parameters           Return Value
    1                    1 byte
    12                   12 bytes
    123                  123 bytes
    1234                 1.205078125 KiB
    12345                12.0556640625 KiB
    123456               120.5625 KiB
    1234567              1.17737483978271 MiB
    12345678             11.7737560272217 MiB
    123456789            117.737568855286 MiB
    1234567890           1.1497809458524 GiB
    12345678901          11.4978094594553 GiB
    123456789012         114.978094596416 GiB
    1234567890123        1.12283295504585 TiB
    12345678901234       11.2283295504621 TiB
    123, ".3f"           123 bytes
    1234567890, ".3f"    1.150 GiB

=cut

sub bytes2sz {
    my($size, $precision) = @_;
    my $format_string;

    if ( ! defined( $precision) ) 
    {
	$format_string = "%f";
    }
    else 
    {
	$format_string = $precision;
    }

    if ( $size < 1024 ) 
    {
	return "$size bytes";
    }

    my @descriptions = (qw(bytes KiB MiB GiB TiB PiB EiB));
    my $desc_number;

    for ( $desc_number = 0; ($size >= 1000 && $desc_number < $#descriptions) ; $size /= 1024 ) 
    {
	db_out(7, "Stuff::ByteSize::bytes2sz, folded over 1000 barrier: now $size", "M");
	$desc_number++;
    }

    db_out(5, "Stuff::ByteSize::bytes2sz, finished folding, size is $size, index = $desc_number ( $descriptions[$desc_number] ))", "M");

    return sprintf("$format_string %s", $size, $descriptions[$desc_number]); 
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


