package Stuff::Column;

=head1 NAME 

  Stuff::Column - models a table column for fixed font use

=head1 SYNOPSIS

Intended for use within Stuff::Table.  See the code there for
examples.

=head1 DESCRIPTION

Stuff::Column is an object module that models a table column.  It was
created for use by Stuff::Table.

Columns have the following properties: 

=over

=item align

This is "left" or "right".

=item width

This is the width of the column in characters.

=item name

This is the column name.  Some string value here.  This is intended as
a unique identifier for the column.

=item title

The column title.  This is a textual description of the column.  In a
Stuff::Table it does not have to be unique.

This is the column title.  

=item format

This is the non-width component of a printf style format string.
E.g. "f" for floating point number.

=back


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
    db_out(5, "Stuff::Column version " . &STUFF_MODULE_VERSION, "M");
}

=head2 new(%properties)

Creates a new Stuff::Column object.  %properties contains the values
of "name", "format" etc.

=cut

sub new {
    my $that = shift;
    my $class = ref($that) || $that;
    my %details = @_;
    my $self = bless { }, $class;
    
    $self->init(%details);

    db_out(8,"Stuff::Column->new OK", "M");     

    return $self;
}


sub init {
    my $self = shift;
    my %column_info = @_;

    # do some validation...
    if (    ! defined( $column_info{title} )  
	 && ! defined( $column_info{name}  )   ) {
	die "you must specify at least a name or title";
    }
    elsif (  ! defined( $column_info{title} ) 
	    && defined( $column_info{name}  )  ) {
	$column_info{title} = $column_info{name};
    }
    elsif (  ! defined( $column_info{name} ) 
	    && defined( $column_info{title}  )  ) {
	$column_info{name} = $column_info{title};
    }

    if ( ! defined( $column_info{align} ) ) {
	$column_info{align} = "-";
    }
    elsif ( lc($column_info{align}) eq "left" ) {
	$column_info{align} = "-";
    }
    elsif ( lc($column_info{align}) eq "right" ) {
	$column_info{align} = "";
    }
    else {
	die "column align $column_info{align} is not valid (left or right please)";
    }

    if ( ! defined( $column_info{width} ) ) {
	$column_info{width} = length($column_info{title});
    }
    elsif ( $column_info{width} !~ /^[\d\.]+$/ ) {
	die "column width spec must be numeric";
    }
    else {
	$column_info{width} =~ /^(\d+)/;
	my $len = $1;
	if ( $len < length($column_info{title}) ) {
	    $column_info{width} = length($column_info{title});
	    db_out(0,"Stuff::Column::init: column $column_info{name} title is wider then the column ($column_info{width} > $len), setting to title width", "M");
	}
    }

    $self->{_align}  = $column_info{align};
    $self->{_width}  = $column_info{width};
    $self->{_name}   = $column_info{name};
    $self->{_title}  = $column_info{title};
    $self->{_format} = $column_info{format};

    db_out(8, "Stuff::Column::init: $column_info{name} (title => $self->{_title}, %$self->{_align}$self->{_width}$self->{_format})", "M");

    $self->{_number_columns} += 1;
}

=head2 format()

Returns a printf style format string for the column.

=cut

sub format {
    my $self = shift;

    "%$self->{_align}$self->{_width}$self->{_format}";
}

=head2 format_no_pad  ()

Same as format(), but does not pad with whitespace.

=cut

sub format_no_pad {
    my $self = shift;

    "%$self->{_format}";
}

sub format_string {
    my $self = shift;

    $self->{_width} =~ /^(\d+)/;

    my $width = $1;

    "%$self->{_align}${width}s";
}

=head2 title()

Returns the column title.

=cut

sub title {
    $_[0]->{_title};
}

=head2 name

Returns the column name.

=cut

sub name {
    $_[0]->{_name};
}

=head2 width

Returns the column width.

=cut

sub width {
    $_[0]->{_width} =~ /^(\d+)/;
    $1;
}

1;

__END__

=head1 LICENSE

Stuff::Column is released under the GNU LGPL.

=head1 AUTHOR

Author: Matthew Gates <matthew@porpoisehead.net>

http://porpoisehead.net/

=head1 BUGS

Reports to the author please.

=head1 SEE ALSO

=cut
