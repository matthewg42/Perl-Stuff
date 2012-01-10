#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use Stuff::Debug qw(&db_out);
use Stuff::Usage qw(&usage &long_usage &version_message);
use Stuff::Table;

use constant STUFF_PROG_DESCRIPTION => "template stuff perl script";
use constant STUFF_PROG_COPYRIGHT   => "(C) 2012; released under the GNU GPL version 2";
use constant STUFF_PROG_VERSION     => "1.00";
use constant STUFF_PROG_AUTHOR      => "Matthew Gates";

BEGIN {
    db_out(1, "program starting");
}

END {
    db_out(1, "program exiting with status " . ($? || 0));
}

my $gs_max_lines 		= 0;
my $gs_delimiter		= '\s+';
my $gs_headers			= 0;
my $gs_comment_re		= undef;

GetOptions(
           'comment=s'         => \$gs_comment_re,
           'headers'           => \$gs_headers,
	   'help'              => sub { long_usage(0) },
	   'version'           => sub { version_message(); exit 0; },
	   'debug=i'           => \$Stuff::Debug::debug_level{S},
           'delimiter=s'       => \$gs_delimiter,
	   )     or usage(1);

my $gs_header_print		= $gs_headers;

my @sizes;
my @names;
my @buffer;

while(<>) {
	chomp;
	my (@fields) = split(/$gs_delimiter/);
	if ($gs_headers) {
		if (/^\s*$/) { next; }
		else {
			foreach my $f (@fields) {
				push @names, $f;
			}	
			$gs_headers = 0;
			next;
		}
	}

	my $comment = 0;
	if (defined($gs_comment_re)) {
		if (/$gs_comment_re/) {
			$comment = 1;
		}
	}

	if (!$comment) {
		for (my $i=0; $i<=$#fields; $i++) {
			if ($#sizes < $i) {
				$sizes[$i] = length($fields[$i]);
			}
			elsif (length($fields[$i]) > $sizes[$i]) {
				$sizes[$i] = length($fields[$i]);
			}
		}
		push @buffer, \@fields;
	}
	else {
		push @buffer, $_;
	}
}

my $t = new Stuff::Table('empty' => '');

for(my $i=0; $i<=$#sizes; $i++) {
	my $name = $i;
	$name = $names[$i] if (defined($names[$i]));
	$t->add_column(	'name' => $name, 'format' => 's' , 'width' => $sizes[$i]);
}

if ($gs_header_print) {
	print $t->title_str();
	print $t->underline_str();
}

foreach my $aref (@buffer) {
	if (ref $aref eq 'ARRAY') {
		print $t->array_row(@$aref);
	}
	else {
		print $aref . "\n";
	}
}

__END__

=head1 NAME 

tabulate - format textual input in columns

=head1 SYNOPSIS

tabulate [options]

=head1 DESCRIPTION

Read input from a file or standard input, determine column widths, and print
in a tabular form.

Input lines are split into fields based on a delimiter, which is a Perl regular
expression, and is '\s+' by default (whitespace).

Column widths are determined based on the maximum size of all values for a given
column for the total size of the file.

=head1 OPTIONS

=over

=item B<--comment>=I<re>

Do not tabulat commented lines, which is all lines matching the perl-style
regular expression I<re>.

=item B<--debug>=I<level>

Print diagnostic messages while executing.  The value of I<level> must be an
integer.  The higher the number, the more verbose the diagnostic output will
be.

=item B<--delimiter>=I<re>

Use I<re> as the input field delimiter where I<re> is a Perl style regular 
expression. 

=item B<--headings>

Treat the first non-empty line as column headings, and print a title row
before the main output.

=item B<--help>

Print the command line syntax an option details.

=item B<--version>

Print the program description and version.

=back

=head1 ENVIRONMENT

=over

=item STUFF_?_DBLEVEL

Sets debugging levels.  The ? can be D for database, M for module,
or S for script debugging messages.  Generally only S and D are
interesting for users, M is mostly just used during development.

=back

=head1 FILES

=over

=item filename

desc

=back

=head1 LICENSE

tabulate is released under the GNU GPL (version 3, 29 June 2007).  A
copy of the license should have been provided in the distribution of
the software in a file called "LICENSE.GPL".  If you can't find this, then
try here: http://www.gnu.org/copyleft/gpl.html

=head1 AUTHOR

Matthew Gates <matthew@porpoisehead.net>

http://porpoisehead.net/

=head1 CHANGELOG

=over

=item Date:YYYY-MM-DD Created, Author MNG

Original version.

=back

=head1 BUGS

Please report bugs to the author.

=head1 SEE ALSO


=cut

