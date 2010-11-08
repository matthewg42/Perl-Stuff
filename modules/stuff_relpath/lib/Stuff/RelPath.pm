package Stuff::RelPath;

=head1 NAME Stuff::RelPath

=head1 SYNOPSIS

    use Stuff::RelPath qw(&relative_path);
    my $path_of_file = "some/file/you/have";
    my $path_of_link = "another/path/you/have"

    my $relative_path = relative_path($path_of_file, $ENV{PWD});
    system("ln -s $relative_path $path_of_link");

=head1 DESCRIPTION

Stuff::RelPath is used to generate relative paths for the creation of
symbolic links.  It does no filesystem checking at all - it is simply
processing strings.  Therefore it doesn't know if the paths you
provide are existing or not on the system - you need to mkdir -p the
dirname of the symlink if it doesn't exist, and all that good stuff.

=head1 FUNCTIONS

=cut

require Exporter;

@ISA        = qw(Exporter);
@EXPORT     = qw ();
@EXPORT_OK  = qw(&relative_path $directory_serarator);

use strict;
use File::Basename;
use Stuff::Debug qw(&db_out $this_script);
use Stuff::Text qw(&delimit_data);
use constant STUFF_MODULE_VERSION => "0.01";

BEGIN {
    db_out(5, "Stuff::ByteSize version " . &STUFF_MODULE_VERSION, "M");
}

=head2 relative_path(I<$masterpath>, I<$linkpath>)

The first argument is the I<master> file (i.e.  the one you will be
creating a link B<to>.  The second argument is name of the file that 
you want to be a link to the I<master>.

Both arguments are assumed to include the file/linkfile name, so 
don't omit the link filename and assume it will be returned as the
same as the master file name.

=cut

sub relative_path {
    my $masterpath = shift || die "Stuff::RelPath::relpath - not enough parameters - expect (masterpath, linkpath)";
    my $linkpath   = shift || die "Stuff::RelPath::relpath - not enough parameters - expect (masterpath, linkpath)";

    my @master_parts = split("/", $masterpath);
    my @link_parts = split("/", $linkpath);

    # 1. Remove un-necessary ./ from beginning of paths...
    while ($master_parts[0] eq ".") { @master_parts = @master_parts[1..$#master_parts] }
    while ($link_parts[0] eq ".") { @link_parts = @link_parts[1..$#link_parts] }

    # abort if the cleaned up paths lead to the same location
    if ( arrays_are_the_same(\@master_parts, \@link_parts) ) {
	die "Stuff::RelPath::relative_path: masterpath and linkpath lead to the same place";
    }


    # 2. When master and link share terms at the beginning of the path, they can be
    # ignored.  e.g. in linking one/two/three/four/file to one/two/ayy/bee
    # we don't need to create one/two/three/four/file/../../../../../one/two/ayy/bee
    # we can ignore the ../../one/two
    my $common_path_depth = 0;
    while( $master_parts[0] eq $link_parts[0] 
	   && $#master_parts >= 1
	   && $#link_parts >= 1 ) {
	db_out(9, "Stuff::RelPath::relative_path: common_path_depth: removing common first element $common_path_depth: " . $master_parts[0], "M"); 
	@master_parts = @master_parts[1..$#master_parts];
	@link_parts = @link_parts[1..$#link_parts];
	$common_path_depth++;
    }

    db_out(9, "Stuff::RelPath::relative_path: common_path_depth is $common_path_depth", "M"); 
    db_out(8,"Stuff::RelPath::relative_path: cleaned up master_parts is: " . ( delimit_data("data" => \@master_parts, "delimiter" => "/") ), "M");
    db_out(8,"Stuff::RelPath::relative_path: cleaned up link_parts is: "   . ( delimit_data("data" => \@link_parts, "delimiter" => "/") ),   "M");
	
    my $retval = "";
    # add one ".." for each non-basename component of the prefix-removed link_parts
    for(my $i=0; $i<$#link_parts; $i++) {
	$retval = "../" . $retval;
    }

    # now append all the othe prefix-removed master_parts
    $retval .= delimit_data("data" => \@master_parts, "delimiter" => "/");
    
    return $retval;
}

sub arrays_are_the_same {
    my ($ar1, $ar2) = @_;
    return ( delimit_data("data" => $ar1, "delimiter" => "/") eq delimit_data("data" => $ar2, "delimiter" => "/") );
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

Only "/" supported as directory separator.

Reports to the author please.

=head1 SEE ALSO

=cut


