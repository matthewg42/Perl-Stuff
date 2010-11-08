package Stuff::FieldSet;

=head1 NAME

Stuff::FieldSet

=head1 SYNOPSIS

    use Stuff::FieldSet;
    # TODO

=head1 DESCRIPTION

TODO - Umm.  I think we need to implement it first.  Then doeument it.
Or maybe the other way round.  Whatever, I work backwards anyway.

=head1 MEMBER FUNCTIONS

=cut

use Stuff::Debug qw(db_out);

# We only need the equality operator.  This will be used when deciding if 
# two FieldSets are of compatable type (for union operators and the like)
# It should IGNORE fieldnames.
use overload ('==' => "equal_to");
use constant STUFF_MODULE_VERSION => "0.01";

BEGIN {
    use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
    @ISA         = qw(Exporter);
    @EXPORT      = qw();
    %EXPORT_TAGS = qw();
    @EXPORT_OK   = qw($null_desc &isa_stuff_type);

    db_out(5, "Stuff::FieldSet version " . &STUFF_MODULE_VERSION, "M");
    return 1;
}

sub new {
    my($self, $class);

    db_out(5,"Stuff::FieldSet->new(" . delimit_data("data" => \@_, "delimiter" => ",") . ")", "M");

    bless $self, $class;
    $self->init(@_);
    return $self
}

sub dump {
    my ($self) = shift;

    db_out(1,"Stuff::FieldSet->dump : TODO: provide a string describing the FieldSet", "M");
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

    # TODO - copy cioy struct to new object

    eval $c;

    return $c;
}

# overload equality operator
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

1;

=head1 AUTHOR

Matthew Gates E<lt>matthew@porpoisehead.netE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Matthew Gates

This library is released under the terms of the GNU LGPL Version 3, 29 June 2007.
A copy of this license should have been provided with this software (filename
LICENSE.LGPL).  The license may also be found at 
http://www.gnu.org/licenses/lgpl.html



