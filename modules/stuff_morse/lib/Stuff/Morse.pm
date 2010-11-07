package Stuff::Morse;

=head1 NAME

Stuff::Morse - morse code fun with perl

=head1 SYNOPSIS

    use Stuff::Morse qw(&ascii2morse &morse2ascii &ascii_is_morseable
                        &morse_is_valid &set_morse_dialect);

    set_morse_dialect("american");
    my $ascii = "This is my test message.";
    my $morse = ascii2morse($ascii);
    my $back_to_ascii = morse2ascii($morse);

=head1 DESCRIPTION

For converting ASCII to and from Morse code.  The module supports English
language only at this time (no accented or non-latin character set letters), 
but both international and american morse dialects are supported. 

=head1 EXPORTS

Just the functions described in the FUNCTIONS section.

=cut

require Exporter;

@ISA=qw(Exporter);
@EXPORT     = qw(
		 &ascii_is_morseable 
		 &ascii_to_morse 
		 &get_morse_dialect 
		 &morse_is_valid
		 &morse_to_ascii 
		 &set_morse_dialect 
		 );
@EXPORT_OK  = qw();

use strict;
use vars qw(%dialect_aliases %dialect_abbrev $dialect %morse_char_data 
	    %morse2ascii %ascii2morse);
use File::Basename;
use Text::Abbrev;
use Stuff::Debug qw(db_out);
use constant STUFF_MODULE_VERSION => "0.01";

BEGIN {
    db_out(5, "Stuff::Morse version " . &STUFF_MODULE_VERSION, "M");

    %dialect_aliases = (
			"international" => "international",
			"british"       => "international",
			"english"       => "international",
			"continental"   => "international",
			"european"      => "international",
			"american"      => "american",
			"railroad"      => "american",
			"telegraph"     => "american",
			"original"      => "american",
			"yankie"        => "american", 
			);
    
    # set up abbreviations for dialect
    abbrev \%dialect_abbrev, keys %dialect_aliases;

    # Note structure element is an array of pairs, "on" or "off" followed by the length
    # The unit of length in morse code is the "Dit", which has length 1. 
    # "Dashes" have length 3
    # The gap between characters has length 1
    # The gap between words has length 3
    # In the american dialect I couldn't find character lengths, so I'm guessing 
    # at 2 for the special space (as in "O"), 5 for the L, and 7 for the 

    %morse_char_data = (
			   '.' => [ "name"   => "Dit",
				    "structure" => [ "on", 1 ],
				    "dialects" => [ "international", "american" ],
				    ],
			   '-' => [ "name"   => "Dash",
				    "structure" => [ "on", 3 ],
				    "dialects" => [ "international", "american" ],
				    ],
			   ' ' => [ "name"   => "Character Break",
				    "structure" => [ "off", 1 ],
				    "dialects" => [ "international", "american" ],
				    ],			   
			   '/' => [ "name"   => "Word Break",
				    "structure" => [ "off", 3 ],
				    "dialects" => [ "international", "american" ],
				    ],			   
			   '_' => [ "name"   => "American Space",
				    "structure" => [ "off", 2 ],
				    "dialects" => [ "american" ],
				    ],			   
			   'L' => [ "name"   => "American L",
				    "structure" => [ "on", 5 ],
				    "dialects" => [ "american" ],
				    ],			   
			   '0' => [ "name"   => "American Zero",
				    "structure" => [ "on", 7 ],
				    "dialects" => [ "american" ],
				    ],
			   );
    

    %ascii2morse = ( "international" => 
		     {
		      'A' => '.-',
		      'B' => '-...',
		      'C' => '-.-.',
		      'D' => '-..',
		      'E' => '.',
		      'F' => '..-.',
		      'G' => '--.',
		      'H' => '....',
		      'I' => '..',
		      'J' => '.---',
		      'K' => '-.-',
		      'L' => '.-..',
		      'M' => '--',
		      'N' => '-.',
		      'O' => '---',
		      'P' => '.--.',
		      'Q' => '--.-',
		      'R' => '.-.',
		      'S' => '...',
		      'T' => '-',
		      'U' => '..-',
		      'V' => '...-',
		      'W' => '.--',
		      'X' => '-..-',
		      'Y' => '-.--',
		      'Z' => '--..',
		      '0' => '-----',
		      '1' => '.----',
		      '2' => '..---',
		      '3' => '...--',
		      '4' => '....-',
		      '5' => '.....',
		      '6' => '-....',
		      '7' => '--...',
		      '8' => '---..',
		      '9' => '----.',
		      '.' => '.-.-.-',
		      ',' => '--..--',
		      '?' => '..--..',
		      ':' => '---...',
		      "'" => '.----.',
		      '-' => '-....-',
		      ';' => '-.-.-',
		      '/' => '-..-.',
		      '(' => '-.--.',
		      ')' => '-.--.-',
		      '"' => '.-..-.',
		      '_' => '..--.-',
		      '=' => '-...-',
		      '+' => '.-.-.',
		      ' ' => '/',
		      },
		     "american" => 
		     {
		      'A' => '.-',
		      'B' => '-...',
		      'C' => '.._.',
		      'D' => '-..',
		      'E' => '.',
		      'F' => '.-.',
		      'G' => '--.',
		      'H' => '....',
		      'I' => '..',
		      'J' => '.-.-',
		      'K' => '-.-',
		      'L' => 'L',
		      'M' => '--',
		      'N' => '-.',
		      'O' => '._.',
		      'P' => '.....',
		      'Q' => '..-.',
		      'R' => '._..',
		      'S' => '..',
		      'T' => '-',
		      'U' => '..-',
		      'V' => '...-',
		      'W' => '.--',
		      'X' => '.-..',
		      'Y' => '.._..',
		      'Z' => '..._.',
		      '0' => '0',
		      '1' => '.----',
		      '2' => '..---',
		      '3' => '...--',
		      '4' => '....-',
		      '5' => '.....',
		      '6' => '-....',
		      '7' => '--...',
		      '8' => '---..',
		      '9' => '----.',
		      '.' => '.-.-.-',
		      ',' => '--..--',
		      '?' => '..--..',
		      ':' => '---...',
		      "'" => '.----.',
		      '-' => '-....-',
		      ';' => '-.-.-',
		      '/' => '-..-.',
		      '(' => '-.--.',
		      ')' => '-.--.-',
		      '"' => '.-..-.',
		      '_' => '..--.-',
		      '=' => '-...-',
		      '+' => '.-.-.',
		      ' ' => '/',
		      },
		     );

    # OK, reverse the relationship for morse2ascii, similar structure
    db_out(9,"Stuff::Morse::BEGIN: populating morse2ascii","M");
    foreach my $d (keys %ascii2morse) {
	db_out(9,"Stuff::Morse::BEGIN: reversing ascii2morse into morse2ascii for dialect $d", "M");
	my $hr = $ascii2morse{$d};
	my %h  = ();
	foreach my $k (keys %$hr) {
	    my $v = $$hr{$k};
	    $h{$v} = $k;
	}
	$morse2ascii{$d} = \%h;
    }
    
    # Finally, set the default morse dialect to "international"
    $Stuff::Morse::dialect = "international";
    return 0;
}

=head1 FUNCTIONS

=head2 ascii2morse(I<string>)

This converts an ascii I<string> to morse code, returning the result
as a string.  un-convertable characters will cause a warning, as will
an undefined parameter.  If there are no morseable characters in
I<string> (or it is undefinied), an empty string will be returned.

Conversions are done according to the current dialect.

=cut

sub ascii_to_morse {
    my $ascii = $_[0];
    db_out(7,"Stuff::Morse::ascii_to_morse($ascii) called", "M");
    if ( ! defined($ascii) ) {
	warn "ascii_to_morse got no parameter\n";
	return "";
    }

    my $err = 0;
    my $retval = "";
  
    # OK, we need to clean up the message.  Multi-whitespace gets converted to a single space.
    # we also trim the ends of whitespace.
    $ascii =~ s/\s+/ /g;
    $ascii =~ s/^\s+//;
    $ascii =~ s/\s+$//;

    for( my $i=0; $i<length($ascii); $i++) {
	my $c = uc(substr($_[0], $i, 1));
	if ( ! defined($Stuff::Morse::ascii2morse{$Stuff::Morse::dialect}{$c} ) ) {
	    warn "character $c not defined in dialect \"$Stuff::Morse::dialect\" - ignoring\n";
	}
	else {
	    my $m = $Stuff::Morse::ascii2morse{$Stuff::Morse::dialect}{$c};
	    db_out(10,"Stuff::Morse::ascii_to_morse(...): in dialect \"$Stuff::Morse::dialect\", $c => $m","M");
	    $retval .= $m . " ";
	}
    }

    # We will always end up with an additional space on the end of the morse
    # so we whill chop it off now.
    chop $retval;

    db_out(8, "Stuff::Morse::ascii_to_morse: retval = \"$retval\"", "M");
    return $retval;
}

=head2 ascii_is_morseable(I<string>)

Returns 1 if all the characters in I<string> have morse
representations in the current dialect.  

Returns 0 if there are one or more characters in I<string> that have
no known morse represetation in the current morse dialect.

Issues a warning and returns 2 if I<srting> is not defined.

=cut

sub ascii_is_morseable {
    my $ascii = $_[0];
    db_out(7,"Stuff::Morse::ascii_is_morseable($ascii) called", "M");
    if ( ! defined($ascii) ) {
	warn "ascii_is_morseable got no parameter\n";
	return 2;
    }

    $ascii =~ s/\s//g;
    for(my $i=0; $i<length($ascii); $i++) {
	my $c = uc(substr($_[0], $i, 1));
	if ( ! defined( $Stuff::Morse::ascii2morse{$Stuff::Morse::dialect}{$c} ) ) {
	    db_out(5, "Stuff::Morse::ascii_is_morseable: $c has no morse value in dialect \"$Stuff::Morse::dialect\"", "M");
	    return 0;
	}
    }
    
    return 1;

}

=head2 get_morse_dialect()

Returns the name of the current morse dialect (either "international" or "american").

=cut

sub get_morse_dialect {
    return $Stuff::Morse::dialect;
}

=head2 morse_is_valid(I<morse>)

Returns 1 if the morse string I<morse> is valid - i.e. that all morse codes
translate to ascii characters properly, and that there are no extraneous bits
in there.

Returns 0 if there is something wrong with the string.

Issues a warning and returns 2 if I<morse> is not defined.

=cut

sub morse_is_valid {
    my $morse = $_[0];
    db_out(7,"Stuff::Morse::morse_is_valid($morse) called", "M");
    if ( ! defined($morse) ) {
	warn "morse_is_valid got no parameter\n";
	return 2;
    }

    # First, chop the morse string into an array of letters.  We will replace
    # / and multi-whitespace with a single " " for that.
    $morse =~ s/\// /g;
    $morse =~ s/\s+/ /g;

    my @letters = split(" ", $morse);

    foreach my $ml (@letters) {
	if ( ! defined( $Stuff::Morse::morse2ascii{$Stuff::Morse::dialect}{$ml} ) ) {
	    db_out(5, "Stuff::Morse::morse_is_valid: \"$ml\" has no ascii value in dialect \"$Stuff::Morse::dialect\"", "M");
	    return 0;
	}
    }

    return 1;
}

=head2 morse_to_ascii(I<morse>)

Converts the morse code string I<morse> to ascii according to the current
dialect.  If there are codes that are not valid, a warning will be issued.  The
ASCII string is returned.  If I<morse> is not defined, a warning will be issued
and an empty string returned.

If there are no valid codes in I<morse> an empty string will be returned. 

=cut

sub morse_to_ascii {
    my $morse = $_[0];
    db_out(7,"Stuff::Morse::morse_to_ascii($morse) called", "M");
    if ( ! defined($morse) ) {
	warn "morse_to_ascii got no parameter\n";
	return "";
    }

    # Surround / with spaces 
    $morse =~ s|/| / |g; 

    # nuke leading and trailing whitespace
    $morse =~ s/^\s+//;
    $morse =~ s/\s+$//;

    # multi-space to single space
    $morse =~ s/\s+/ /g;


    my @letters = split(" ", $morse);
    my $retval = "";

    foreach my $ml (@letters) {
	if ( ! defined( $Stuff::Morse::morse2ascii{$Stuff::Morse::dialect}{$ml} ) ) {
	    warn "\"$ml\" has no ascii value in dialect \"$Stuff::Morse::dialect\"\n";
	}
	else {
	    $retval .= $Stuff::Morse::morse2ascii{$Stuff::Morse::dialect}{$ml};
	}
    }

    return $retval;
}

=head2 set_morse_dialect(I<name>)

This sets the dialect to I<name>, where I<name> is an (optionally
abbreviated) alias for either "internaational" or "american".  When
the module is included with a "use" statement, "international" is set
as the default.

There are several aliases, which are my guesses at common names.  They
include: "english" (international), "european" (international),
"continental" (international), "railroad" (american), and a few others
(take a look in the BEGIN subroutine for more information).

=cut 

sub set_morse_dialect {
    db_out(7,"Stuff::Morse::set_morse_dialect($_[0]) called", "M");
    die "set_morse_dialect expects parameter" if ($#_ < 0 );

    # OK, make sure the param is a known abreviation of dialect name or alias: 
    if ( ! defined( $Stuff::Morse::dialect_abbrev{$_[0]} ) ) {
	die "Sorry, I don't know the morse dialect \"$_[0]\"";
    }
    
    # OK, expand the abreviation and use it to look up the proper name for the alias:
    $Stuff::Morse::dialect = $Stuff::Morse::dialect_aliases{$Stuff::Morse::dialect_abbrev{$_[0]}};

    db_out(8,"Stuff::Morse::set_morse_dialect($_[0]) setting dialect $Stuff::Morse::dialect", "M");
}

1;

__END__

=head1 LICENSE

Stuff::Morse is released under the GNU LGPL.

=head1 AUTHOR

Author: Matthew Gates <matthew@porpoisehead.net>

http://porpoisehead.net/

=head1 BUGS

Reports to the author please.

=head1 SEE ALSO

ascii2morse(1), morse2ascii(1).

=cut

