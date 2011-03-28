package Stuff::ExpirySet;

=head1 NAME 

Stuff::ExpirySet - container with expiry time for objects

=head1 SYNOPSIS

    use Stuff::ExpirySet;

    my $s = Stuff::ExpirySet->new('Life' => 3);
    $s->add(qw(one two));
    $s->data(); # ('one', 'two');
    sleep 3;
    $s->add(qw(three));
    $s->data(); # ('one', 'two', 'three');
    sleep 3;
    $s->data(); # ('three');
    sleep 3;
    $s->data(); # ('three');
    sleep 2;
    $s->data(); # ();


=head1 DESCRIPTION

Stuff::ExpirySet is a container which expires objects based on how long ago they were
added to the container.  The resolution of the internal clock is millisecond.

=head1 MEMBER FUNCTIONS

=cut

require Exporter;

@ISA       = qw(Exporter);
@EXPORT    = qw();
@EXPORT_OK = qw();

use strict;
use vars qw($VERSION);
use Carp;
use Time::HiRes;
use Stuff::Debug qw(db_out);

BEGIN {
    $VERSION = '0.01';
    db_out(5, "Stuff::ExpirySet version $VERSION", "M");
}

=head2 new(I<%params>)

A new Stuff::ExpirySet is returned.  The parameters are in hash form.  Valid parameters:

=over

=item B<Life> (+ve number)

The time in seconds between objects being added to the ExpirySet, and getting removed.
If the B<Life> paremeter is not specified, the new function will raise an exception.

=back

=cut

sub new {
    my $that = shift || croak 'object fail';
    my $class = ref($that) || $that;
    my %params = @_;
    croak "requires 'Life' parameter" unless defined($params{'Life'});
    croak "'Life' parameter must be numeric" unless ($params{'Life'} =~ /^\d+(.\d+)?$/);
    my $self = {
        '_start' => Time::HiRes::time,
        '_life' => $params{'Life'},
        '_data' => [], 
    };

    bless $self, $class;
    
    db_out(8,"Stuff::ExpirySet->new(Life => " . $self->{'_life'} . ") OK", "M"); 
    
    return $self;
}

1;

=head2 add(item, item ...)

Add items to the ExpirySet.

=cut

sub add {
    my $self = shift || croak 'object fail';
    my $now = Time::HiRes::time;
    my @data = @{$self->{'_data'}};
    foreach my $o (@_) {
        push @data, [ $now, $o ];
    }
    $self->{'_data'} = \@data;
}

=head2 dump([level])

use Stuff::Debug to dump the contents and age of the ExpirySet.  Level 
5 debugging is used by default, although a different value may be specified
with a parameter.  The debugging channel is 'M' (module).

=cut

sub dump {
    my $self = shift || croak 'object fail';
    my $level = 5;
    if ($#_ >= 0) { $level = shift; }
    my @data = @{$self->{'_data'}};
    my $now = Time::HiRes::time;

    db_out($level, 'Stuff::ExpirySet::dump count = ' . ($#data+1), 'M');
    foreach my $ar (@data) {
        my $age = $now - $ar->[0];
        db_out($level, "Stuff::ExpirySet::dump age=$age; \"$ar->[1]\"", 'M');
    }
}

=head2 data()

Returns an array of objects when have been added to the ExpirySet and have not
yet become too old.

Note the B<clean()> function is called automatically before this function
returns it's values.

=cut

sub data {
    my $self = shift || croak 'object fail';
    my @a;

    $self->clean();
    foreach my $ar (@{$self->{'_data'}}) {
        push @a, $ar->[1];
    }
    return @a;
}

=head2 clean() 

Removes items which are older than the B<Life> setting for the object.  Note
that this function is called automatically before B<data()> returns its 
values.

=cut 

sub clean {
    my $self = shift || croak 'object fail';
    my $cleaned = 0;
    my $now = Time::HiRes::time;
    my @data = @{$self->{'_data'}};
    db_out(3, "Stuff::ExpirySet::clean there are " . ($#data+1) . " elements to examine", "M");
    while($#data>=0) {
        my $ar = $data[0];
        my $age = $now - $ar->[0];
	if ($age > $self->{'_life'}) {
            db_out(5, "Stuff::ExpirySet::clean aging out item $ar->[1] with age: $age", "M");
	    shift @data;
	    $cleaned++;
        }
	else {
	    last;
	}
    }
    $self->{'_data'} = \@data;
    return $cleaned;
}

=head2 age()

Returns the age of the set in seconds.  Note that this may not be the same as 
the B<Life> parameter to the new() member - if the set was created less than 
B<Life> seconds ago, the age of the object is returned instead.

=cut 

sub age {
    my $self = shift || croak 'object fail';
    my $now = Time::HiRes::time;
    if ($now - $self->{'_start'} < $self->{'_life'}) {
        return $now - $self->{'_start'};
    }
    else {
        return $self->{'_life'};
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

