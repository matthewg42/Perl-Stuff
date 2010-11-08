#!/usr/bin/perl
#
# dh-make-perl seems to fail to get the LGPL stuff, so I wrote this to 
# fix the copyright info...

foreach my $f (@ARGV) {
	print "processing file $f...\n";
	my $old = "$f.old";
	system('mv', $f, $old);
	open(OLD, "<$old") || die "cannot open old file for reading: $old";
	open(NEW, ">$f") || die "cannot open new file for writing: $f";

	while(<OLD>) {
		if ( /^Name:/ ) {
			print NEW $_;
			print NEW new_copyright() . "\n";
			last;
		}
		print NEW $_;
	}
	close(OLD);
	close(NEW);
	unlink $old;
}

sub new_copyright {
	return <<EOD;

Files: *
Copyright: Matthew Gates <matthew\@porpoisehead.net>
License: LGPL-3+

Files: debian/*
Copyright: 2010, Matthew Gates <matthew\@porpoisehead.net>
License: Artistic

License: LGPL-3+
 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; version 3 dated June, 2007, or (at your
 option) any later version
 .
 On Debian GNU/Linux systems, the complete text of version 3 of the GNU
 General Public License can be found in `/usr/share/common-licenses/GPL-3'

License: Artistic
 This program is free software; you can redistribute it and/or modify
 it under the terms of the Artistic License, which comes with Perl.
 .
 On Debian GNU/Linux systems, the complete text of the Artistic License
 can be found in `/usr/share/common-licenses/Artistic'
EOD
}
