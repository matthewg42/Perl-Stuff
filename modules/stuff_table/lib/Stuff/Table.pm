package Stuff::Table;

=head1 NAME 

Stuff::Table - Fixed width character table printing class

=head1 SYNOPSIS

    use Stuff::Table;

    my $t = new Stuff::Table;
    $t->add_column('name' => "Column One", 'format' => "s" );
    $t->add_column('name' => "Column Two", 'format' => "d" );

    print $tab->title_str(); 
    print $tab->underline_str();
    print $tab->array_row(qw(line1 1));
    print $tab->array_row(qw(line2 2));

    # output:
    #Column One Column Two
    #---------- ----------
    #line1      1
    #line2               2

=head1 DESCRIPTION

Stuff::Table provides an alternative to perl form output for some
simple tabular formats.  A Stuff::Table object contains description of
table columns.  It may then be fed data and will return correctly
formatted rows of output for use as the programmer wishes.  Note that
this is only going to be useful for use on fixed-width-font terminals
and the like, and the output isn't exactly beautiful.  Still, it's
good for knocking together quick reports.

=head1 MEMBER FUNCTIONS

=cut

require Exporter;

@ISA       = qw(Exporter);
@EXPORT    = qw();
@EXPORT_OK = qw();

use strict;
use Carp;
use Stuff::Debug qw(db_out);
use Stuff::Column;
use Stuff::Text qw(delimit_data);
use constant STUFF_MODULE_VERSION => "0.02";

BEGIN {
    db_out(5, "Stuff::Table version " . &STUFF_MODULE_VERSION, "M");
}

=head2 new()

Creates a new table object.

=cut

sub new {
    my $that = shift;
    my $class = ref($that) || $that;
    my $self = bless {
	_gutter         => " ",
	_column_order   => [],       # array of names in order left -> right 
	_number_columns => 0,
	_null_desc      => "-",
	_line_append    => "\n",
    }, $class;
    
    db_out(8,"Stuff::Table->new OK", "M"); 
    
    return $self;
}

=head2 clear_columns()

Removes all colmns from an existing table object.

=cut

sub clear_columns {
    my $self = shift;
    my(@names) = @_;

    if ( $#names < 0 ) {
	$self->{_columns} = [];
	$self->{_number_columns} = 0;
    }
    else { 
	db_out(0, "Stuff::Table::clear_columns: selective mode TODO!", "M");
    }
}

=head2 add_column(%attributes)

Appends a column at the end of a table object.  %attributes must include the following:

=over

=item name, title or both

The name must be unique.  It can be used as the key to a data hash when
printing data.  If it is not defined but title is, it will take the value of
title.

The title is what is put in the column headers.  It need not be unique.  If it
is not defined but name is, it will take the value of name.

=item format

The format is like the "s" in printf style "%s" formats.

=back

Optionally these may also be defined:

=over

=item width

The width takes the length of the title by default, but it may be specified in
the %attributes has explicitly.

=item align

Youo can choose "left" or "right".  The default is left.

=back

=cut

sub add_column {
    my $self = shift;
    my %column_info = @_;
    my $col_object = Stuff::Column->new(%column_info);
    my $name = $col_object->name;

    if ( defined( $self->{_columns}{$name} ) ) {
	die "column named $name is already defined";
    }

    db_out(8, "Stuff::Table::add_column: column $name added", "M");

    $self->{_columns}{$name} = $col_object;
    $self->{_column_order}[$self->{_number_columns}] = $name;
    $self->{_number_columns} += 1;
}

=head2 get_columns()

Returns an array of Stuff::Column objects describing the columns that
exist in the table object.  If a parameter is passed, it is the name
of the column that is desited.

If the table object has no columns yet, or the requested column does
not exist, the result will be [].

=cut

sub get_columns {
    my $self = shift;
    if ( ! defined( $_[0] ) ) {
	return $self->{_columns};
    }
    else {
	die "Stuff::Table::get_columns by name is not implemented yet";
    }
}

=head2 set_columns(@set)

Takes as the parameter, an array of Stuff::Column objects describing the
columns to use set.

=cut

sub set_columns {
    my $self = shift;
    my %hash = @_;
    # use add_column for each memort of this to validate entries...

    db_out(0,"Stuff::Table::set_columns: TODO!", "M");
}


=head2 set_gutter($g)

Sets the gutter (the string that is used to separate the columns) to $g.

=cut

sub set_gutter {
    my $self = shift;
    my $newgut = shift;

    if ( ! defined($newgut) ) {
	die "you must specify a gutter, even if it is just an empty string";
    }

    $self->{_gutter} = $newgut;
}

=head2 gutter()

Returns the gutter string.

=cut

sub gutter {
    my $self = shift;
    return $self->{_gutter};
}

=head2 get_column_names()

returns an array with the names of each column.  Note this is not necessarily
the same as the column titles.

=cut

sub get_column_names {
    my $self = shift;
    return @{$self->{_column_order}};
}

=head2 format()

Returns a string that can be used with printf to print an array of data.

=cut

sub format {
    my $self = shift;
    my $str = "";
    my $gut = $self->gutter;
    foreach my $name ( @{$self->{_column_order}} ) {
	$str .= $self->{_columns}{$name}->format . $gut;
    }

    $str =~ s/$gut$//;
    return $str . $self->{_line_append};
}

=head2 title_str()

Returns the titles formatted in such a way that they are aligned with column
data.  The gutter string separates the columns.

=cut

sub title_str {
    my $self = shift;
    my $str = "";
    my $gut = $self->gutter;
    my @titles = ();
    foreach my $name ( @{$self->{_column_order}} ) {
	$str .= $self->{_columns}{$name}->format_string . $gut;
	@titles = (@titles , $self->{_columns}{$name}->title);
    }

    $str =~ s/$gut$//;
    return sprintf( $str . $self->{_line_append}, @titles );
}

=head2 title_str_delim($c)

Returns a string of which is a delimited list of column titles.

=cut

sub title_str_delim {
    my $self = shift;
    my $char = shift;
    if ( ! defined( $char ) ) {
	die "you must specify a delimiting string...";
    }
    
    my @cols = $self->get_column_names();
    return delimit_data( 'data' => \@cols, 'delimiter' => $char );
}

=head2 underline_str()

Returns a string which is the underline for the column titles as returned by
title_str().

=cut

sub underline_str {
    my $self = shift;
    my $char = shift;
    my $gut = $self->gutter;
    if ( ! defined( $char ) ) {
	$char = "-";
    }

    my $str = "";
    foreach my $name ( @{$self->{_column_order}} ) {
	for(my $i=0; $i < $self->{_columns}{$name}->width; $i++) {
	    $str .= $char;
	} 
	$str .= $gut; 
    }

    $str =~ s/$gut$//;

    return $str . $self->{_line_append};
}

=head2 array_row(@d)

Takes an array of data items and return a string which is aligned with the
column headers and separated by the gutter string.

=cut

sub array_row {
    my $self = shift;
    my @data = @_;
    my $str = "";
    my $i=0;
    my $gut = $self->gutter;

    foreach my $name ( @{$self->{_column_order}} ) {
	if ( defined( $data[$i] ) ) {
	    $str .= $self->{_columns}{$name}->format . $gut;	    
	}
	else {
	    $str .= $self->{_columns}{$name}->format_string . $gut;
	    $data[$i] = $self->{_null_desc};
	}

	$i++;
    }

    $str =~ s/$gut$//;

    sprintf( $str . $self->{_line_append},  @data );
}

=head2 array_row_delim($c, @d)

Takes an array of data and returns a delimited string (delimited by $c).  Note
that as with the title_str_delim, be careful about expansion on special
characters in the delimiter, e.g. "|".

=cut

sub array_row_delim {
    my $self = shift;
    my $char = shift;
    my @data = @_;
    my $str = "";
    my $i=0;

    foreach my $name ( @{$self->{_column_order}} ) {
	if ( defined( $data[$i] ) ) {
	    $str .= $data[$i] . $char;	    
	}
	else {
	    $str .= $self->{_null_desc} . $char;
	}

	$i++;
    }

    $str =~ s/$char$//;

    $str .= $self->{_line_append};

    $str;
}

=head2 hash_row(%d)

Takes a hash where the keys are the column names, and the value are the values
to be returned in the normal formmatted way.

=cut

sub hash_row {
    my $self = shift;
    my %data = @_;
    my @line = ();
    my $str = "";
    my $gut = $self->{_gutter};

    foreach my $name ( @{$self->{_column_order}} ) {
	if ( defined( $data{$name} ) ) {
	    $str .= $self->{_columns}{$name}->format . $gut;	    
	    @line = (@line, $data{$name});
	}
	else {
	    $str .= $self->{_columns}{$name}->format_string . $gut;	    
	    @line = (@line, $self->{_null_desc});
	}
    }

    sprintf($str . $self->{_line_append}, @line);
}

=head2 hash_row_delim($c, %h)

Takes a de-limiter character $c, and a hash where the keys are the names of
the columns, and the value are the value to be returned in a dlimited string.

=cut

sub hash_row_delim {
    my $self = shift;
    my $char = shift;
    my %data = @_;
    my $str = "";

    foreach my $name ( @{$self->{_column_order}} ) {
	if ( defined( $data{$name} ) ) {
	    $str .= $data{$name} . $char;	    
	}
	else {
	    $str .= $self->{_null_desc} . $char;
	}

    }

    $str =~ s/$char$//;

    $str .= $self->{_line_append};

    $str;
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
