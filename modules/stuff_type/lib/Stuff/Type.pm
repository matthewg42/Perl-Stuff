package Stuff::Type;

=head1 NAME

Stuff::Type

=head1 DESCRIPTION

TODO!

=cut

use vars qw($VERSION);
use Stuff::Debug qw(db_out);
use overload ('+'  => "add",
	      '-'  => "subtract",
	      '*'  => "multiply",
	      '/'  => "divide",
	      '""' => "formatted",
	      '>'  => "greater_than",
	      '<'  => "less_than",
	      '==' => "equal_to",
	      '>=' => "greater_than_or_equal_to",
	      '<=' => "less_than_or_equal_to");

BEGIN {
    $VERSION = '0.03';
    db_out(5, "Stuff::Type version $VERSION", "M");
    use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $null_desc);

    @ISA         = qw(Exporter);
    @EXPORT      = qw();
    %EXPORT_TAGS = qw();
    @EXPORT_OK   = qw($null_desc &isa_stuff_type);

    $null_desc = "[NULL]";

    db_out(3,"Loaded module Stuff::Type","M");
    return 1;
}


sub new {
    my($self, $class);

    die "Stuff::Type is a virtual class, so you can't create one directly, sorry about that";
}

sub dump {
    my ($self) = shift;

    db_out(1,"Stuff::Type->dump : raw=\"". $self->raw() ."\", formatted=\"". $self->formatted() ."\"", "M");
}

sub isnull {
    my $self = shift;

    if ( ! defined( $self->{value} ) ) {
	return 1;
    }
    else {
	return 0;
    }
}

sub raw {
    my $self = shift;
    if ( $self->isnull() ) {
	return $null_desc;
    }
    else {
	return $self->{value};
    }
}

sub formatted {
    my $self = shift;
    return $self->raw();
}

###########
# Cloning #
###########
# by default we create new object of the same type, with the argument to the
# new() of the new object is the formatted() value.  If you want some other
# behaviour, overload "clone".

sub clone {
    my $self = shift;    
    my $class = ref($self);
    my $new_object;

    db_out(5,"$class default cloner " . $self->formatted() . ")", "M");
    my $c = "\$new_object = $class" . "->new(" . $self->formatted() . ")";

    eval $c;

    return $c;
}


########################
# Overloaded operators #
########################
# The default + operator will use numeric addition of the ->{value} of
# two like-typed objects.  If you want to implement addition accross types, 
# you'll have to define your own add() member.
sub add {
   my ( $ob1, $ob2, $was_reversed ) = @_;
   my ($t1, $t2) = ( ref($ob1), ref($ob2) );

   if ( $t1 ne $t2 ) {
       die "attempt to add object of type $t1 to object of type $t2";
       return undef;
   }

   if ( $ob1->isnull() && $ob2->isnull() ) {
       # both operands are null, so return a null object
       my $result = $t1->new();
       return $result;
   }
   elsif ( $ob1->isnull() ) {
       # 1 operand is null, so return the other one
       my $result = $t1->new();
       $result->{value} = $ob2->{value};
       return $result;
   }
   elsif ( $ob2->isnull() ) {
       # 1 operand is null, so return the other one
       my $result = $t1->new();
       $result->{value} = $ob1->{value};
       return $result;
   }
   else {
       my $result = $t1->new();
       $result->{value} = $ob1->{value} + $ob2->{value};
       return $result;
   }

}

sub subtract {
   my ( $ob1, $ob2, $was_reversed ) = @_;
   my ($t1, $t2) = ( ref($ob1), ref($ob2) );

   if ( $t1 ne $t2 ) {
       die "attempt to subtract object of type $t2 from object of type $t1";
   }

   ( $ob1, $ob2 ) = ( $ob2, $ob1 ) if $was_reversed;

   if ( $ob1->isnull() && $ob2->isnull() ) {
       # both operands are null, so return a null object
       my $result = $t1->new();
       return $result;
   }
   elsif ( $ob1->isnull() ) {
       # 1 operand is null, so return the other one
       my $result = $t1->new();
       $result->{value} = 0 - $ob2->{value};
       return $result;
   }
   elsif ( $ob2->isnull() ) {
       # 1 operand is null, so return the other one
       my $result = $t1->new();
       $result->{value} = $ob1->{value};
       return $result;
   }
   else {
       my $result = $t1->new();
       $result->{value} = $ob1->{value} - $ob2->{value};
       return $result;
   }

}

sub multiply {
   my ( $ob1, $ob2, $was_reversed ) = @_;
   my ($t1, $t2) = ( ref($ob1), ref($ob2) );

   if ( $t1 ne $t2 ) {
       die "attempt to multiply object of type $t1 by object of type $t2";
   }

   ( $ob1, $ob2 ) = ( $ob2, $ob1 ) if $was_reversed;

   if ( $ob1->isnull() || $ob2->isnull() ) {
       # both operands are null, so return a null object
       my $result = $t1->new();
       return $result;
   }
   else {
       my $result = $t1->new();
       $result->{value} = $ob1->{value} * $ob2->{value};
       return $result;
   }

}

sub divide {
   my ( $ob1, $ob2, $was_reversed ) = @_;
   my ($t1, $t2) = ( ref($ob1), ref($ob2) );

   if ( $t1 ne $t2 ) {
       die "attempt to divide object of type $t1 by object of type $t2";
   }

   ( $ob1, $ob2 ) = ( $ob2, $ob1 ) if $was_reversed;

   if ( $ob1->isnull() && $ob2->isnull() ) {
       # both operands are null, so return a null object
       my $result = $t1->new();
       return $result;
   }
   elsif ( $ob1->isnull() ) {
       # 1 operand is null, so retura null (null / anything = null)
       my $result = $t1->new();
       return $result;
   }
   elsif ( $ob2->isnull() ) {
       # 1 operand is null, so return the other one
       die "divide by NULL in $t1" . "->divide";
   }
   else {
       my $result = $t1->new();
       $result->{value} = $ob1->{value} / $ob2->{value};
       return $result;
   }

}

sub greater_than {
   my ( $ob1, $ob2, $was_reversed ) = @_;
   my ($t1, $t2) = ( ref($ob1), ref($ob2) );

   if ( $t1 ne $t2 ) {
       die "greater_than for object of type $t1 and object of type $t2";
   }

   ( $ob1, $ob2 ) = ( $ob2, $ob1 ) if $was_reversed;

   if ( $ob1->{value} > $ob2->{value} ) {
       return 1;
   }
   else {
       return 0;
   }
}

sub less_than {
   my ( $ob1, $ob2, $was_reversed ) = @_;
   my ($t1, $t2) = ( ref($ob1), ref($ob2) );

   if ( $t1 ne $t2 ) {
       die "less_than for object of type $t1 and object of type $t2";
   }

   ( $ob1, $ob2 ) = ( $ob2, $ob1 ) if $was_reversed;

   if ( $ob1->{value} < $ob2->{value} ) {
       return 1;
   }
   else {
       return 0;
   }
}

sub equal_to {
   my ( $ob1, $ob2, $was_reversed ) = @_;
   my ($t1, $t2) = ( ref($ob1), ref($ob2) );

   if ( $t1 ne $t2 ) {
       die "equal_to for object of type $t1 and object of type $t2";
   }

   ( $ob1, $ob2 ) = ( $ob2, $ob1 ) if $was_reversed;

   if ( $ob1->isnull() && $ob2->isnull() ) { return 1; }

   if ( $ob1->{value} eq $ob2->{value} ) {
       return 1;
   }
   else {
       return 0;
   }

}

sub greater_than_or_equal_to {
   my ( $ob1, $ob2, $was_reversed ) = @_;
   my ($t1, $t2) = ( ref($ob1), ref($ob2) );

   if ( $t1 ne $t2 ) {
       die "greater_than_or_equal_to for object of type $t1 and object of type $t2";
   }

   if ( $ob1 > $ob2 || $ob1 == $ob2 ) { return 1; }
   else { return 0; }
}

sub less_than_or_equal_to {
   my ( $ob1, $ob2, $was_reversed ) = @_;
   my ($t1, $t2) = ( ref($ob1), ref($ob2) );

   if ( $t1 ne $t2 ) {
       die "less_than_or_equal_to for object of type $t1 and object of type $t2";
   }

   if ( $ob1 < $ob2 || $ob1 == $ob2 ) { return 1; }
   else { return 0; }
}


###############
# Non-members #
###############

sub isa_stuff_type {
    my $class = ref($_[0]);
    if ( $class =~ /^Stuff\:\:Type/ ) { return 1; } 
    else { return 0; }
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











