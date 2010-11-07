package Stuff::SpamBL;

=head1 NAME 

Stuff::SpamBL - check spam blacklist status of a host

=head1 SYNOPSIS

    use Stuff::SpamBL;
    my $bl1 = Stuff::SpamBL->new(host      => "111.222.333.444",
                               [ blacklist => "bl_name",]
                               [ rdns      => {0|1}     ]);
    my $bl2 = Stuff::SpamBL->new("foo.com"[,"bl_name]);

    $bl1->is_listed()      # 1 or 0
    $bl1->is_dynamic();    # 1 or 0
    $bl1->is_exploited();  # 1 or 0
    $bl1->full_txt();      # full contents of TXT record
    $bl1->ip();            # numerical IP address
    $bl1->fqdn();          # FQDN
    $bl1->rdns_ok();       # if a name was given, did DNS/rDNS match it?

=head1 DESCRIPTION

Stuff::SpamBL looks up a host in DNS for spam blacklist status.  The
constructor can take and or FQDN, and optionally a spam blacklist
name.  The default spam blacklist is "dnsbl.sorbs.net".

=head1 MEMBER FUNCTIONS

=cut

require Exporter;

@ISA       = qw(Exporter);
@EXPORT    = qw();
@EXPORT_OK = qw();

use strict;
use Carp;
use Stuff::Debug qw(db_out);
use Net::DNS;
use constant STUFF_MODULE_VERSION => "0.01";

BEGIN {
    db_out(5, "Stuff::ByteSize version " . &STUFF_MODULE_VERSION, "M");
}

=head2 new(I<%params>)
   
Creates a new Stuff::SpamBL object.  This does the actualy DNS lookup
and parses the results, setting the internal state of the object -
it cannot be changed subsequently.

I<%params> must contain an element "host", which can be a domain name
or an IP address.  It may also contain the optional elements
"blacklist" and "rdns".  "blacklist" should be the name of a
blacklist.  At time of writing only dnslb.sorbs.net is supported, and
this is the default. 

"rdns" is either 1 (the default), or 0.  1 means that a reverse DNS
check is done. "0" means no reverse DNS check is performed.  Not doing
the rDNS check is quicker if you're not interested in this specific
check, and saves a little time, but won't detect dmoain name spoofers.

Setting "rdns" to 0 may be desirable when scanning large numbers of
hosts for blacklist status if you're not interested in domain name
spoofing.  It's up to you.

=cut

sub new {
    my $that = shift;
    my $class = ref($that) || $that;
    my %params = @_;

    my $host_string = $params{"host"} || croak "must specify an ip or hostname using the \"host\" parameter";
    my $bl_name = $params{"blacklist"} || "dnsbl.sorbs.net";
    my $test_rdns = $params{"rdns"} || 1;

    if ( $test_rdns !~ /^0|1$/ ) {
	die "rdns option must be 0 or 1, you specified \"$test_rdns\"";
    } 

    my $self = bless {
	_host_string      => $host_string,
	_bl_name          => $bl_name,
	_test_rdns        => $test_rdns,
	_ip               => undef,
	_fqdn             => undef,
	_bl_dummy_address => undef,
	_rdns_ok          => undef,
	_txt_record       => "",
    }, $class;

    my $dns_resolver = Net::DNS::Resolver->new;

    if ( $host_string =~ /^\d+\.\d+\.\d+\.\d+$/ ) {
	# we got an IP address in the new params
	$self->{_ip} = $host_string;
    }
    else {
	# We were passed a name, not an IP.  Get the IP address using
	# a regular DNS lookup
	$self->{_fqdn} = $host_string;

	my $dns_query = $dns_resolver->search($host_string);
    
	if ($dns_query) {
	    foreach my $rr ($dns_query->answer) {
		if ($rr->type eq "A") {
		    $self->{_ip} = $rr->address;
		}
	    }
	}

	if ( ! defined($self->{_ip}) ) {
	    die "DNS lookup failed for address: $host_string";
	}
	else {
	    db_out(5, "Stuff::SpamBL::new DNS lookup OK: $host_string -> $self->{_ip}", "M");
	}
    }

    # OK we have an IP address.  Set the _bl_dummy_address
    if ( $self->{_ip} =~ /^(\d+)\.(\d+)\.(\d+)\.(\d+)$/ ) {
	$self->{_bl_dummy_address} = "$4.$3.$2.$1.$self->{_bl_name}";
	db_out(5, "blacklist dummy name is $self->{_bl_dummy_address}", "M");
    }

    # Do a rDNS lookup on the IP to get/check the host name
    
    if ( ! $self->{_test_rdns} ) {
	# the user specified that she doesn't want to do an rdns lookup.
	# so we automatically set _rdns_ok to 1.  It's their choice.
	$self->{_rdns_ok} = 1;
    }
    else {
	my $rdns_query = $dns_resolver->query($self->{_ip}, "PTR");
	if ($rdns_query) {
	    my $query_ok = 0;
	    foreach my $rr ($rdns_query->answer) {
		if ($rr->type eq "PTR") {
		    # OK we found the correct response.
		    # If the _fqdn is not yet defined we just set it to the result
		    # otherwise check if it matches the original value and set the
		    # _rdns_ok flag accordingly.
		    
		    db_out(5,"rDNS result = " . $rr->ptrdname, "M");
		    $query_ok = 1;
		    
		    if ( ! defined($self->{_fqdn}) ) {
			$self->{_fqdn} = $rr->ptrdname;
			$self->{_rdns_ok} = 1;
		    }
		    elsif ( lc($self->{_fqdn}) eq lc($rr->ptrdname) ) {
			# rdns passed ok
			$self->{_rdns_ok} = 1;		    
		    } 
		    else {
			warn "a DNS/rDNS pair found a mismatch: $self->{_fqdn} ne $self->{_host_string}\n";
			# we set the _fqdn to the value from the rDNS.  This way we have both
			# values in the object - _host_string with the originally specified
			# name and _fqdn with the DNS version.
			$self->{_fqdn} = $rr->ptrdname;
			$self->{_rdns_ok} = 0;   
		    }
		}
	    }
	    
	    if ( ! $query_ok ) {
		die "rDNS failed for $self->{_ip}";
	    }
	    else {
		db_out(5, "rDNS result: $self->{_ip} -> $self->{_fqdn}", "M");
	    }
	}
	else {
	    die "rDNS failed for $self->{_ip}";
	}
    }

    # TXT lookup time.
 
    my $txt_query = $dns_resolver->query($self->{_bl_dummy_address}, "TXT");
    if ($txt_query) {
	foreach my $rr ($txt_query->answer) {
	    if ($rr->type eq "TXT") {
		$self->{_txt_record} .= $rr->txtdata . "\n";
	    }
	    else {
		db_out(10,"while doing txt query, got record of type: " . $rr->type, "M");
	    }
	}

    }
    else {
	die "TXT DNS failed for $self->{_bl_dummy_address}";
    }

    # some debugging output
    foreach my $k (qw(_host_string _bl_name _ip _fqdn _bl_dummy_address _rdns_ok _txt_record)) {
	db_out(6, "  $k => $self->{$k}", "M");
    }

    return $self;
}

=head2 is_listed()

Returns 1 if host/ip is listed with spam dns check, 0 otherwise.  This
might still be OK as it could just be listed as a dynamic IP, not an
exploited machine.

=cut

sub is_listed {
    my $self = shift;
    if ( $self->{_txt_record} eq "unlisted" ) { return 0; }
    else  { return 1; }
}

=head2 is_dynamic()

Return 1 if the host/ip is listed as a dynamically allocated address, 0 otherwise.

=cut

sub is_dynamic {
    my $self = shift;
    if ( $self->{_txt_record} =~ /Dynamic IP Addresses/ ) { return 1; }
    else  { return 0; }
}

=head2 is_exploited()

Returns 1 is the host/ip is flagged as exploited, 0 otherwise.  This
means mail coming from the address is going to be flagged as spam for
sure.  This is the one you probably want to check.

=cut

sub is_exploited {
    my $self = shift;
    if ( $self->{_txt_record} =~ /Exploitable Server/ ) { return 1; }
    else  { return 0; }
}

=head2 full_txt ()

Returns the full text of the dns query.  If more than one TXT record
was returned they will be concatenated, with \n between each one.

=cut

sub full_txt {
    return $_[0]->{_txt_record};
}

=head2 ip()

Returns the IP address.

=cut

sub ip {
    return $_[0]->{_ip};
}

=head2 fqdn()

Returns the FQDN as found by a rDNS query. The original value may be
found using host_string().

=cut 

sub fqdn {
    return $_[0]->{_fqdn};
}

=head2 rdns_ok()

Returns 1 if the reverse DNS check was OK.  Note this is always 1 if a
numerical IP was passed to new().

=cut

sub rdns_ok {
    return $_[0]->{_rdns_ok};
}

=head2 host_string()

If a name was passed to new(), and it did not match the FQDN returned
by an rDNS query, the original value can be found here.  If a
numerical IP was send to new(), that will be returned.

=cut

sub host_string {
    return $_[0]->{_host_string};
}

1;

=head1 LICENSE

Stuff::SpamBL is released under the GNU LGPL.

=head1 AUTHOR

Author: Matthew Gates <matthew@porpoisehead.net>

http://porpoisehead.net/

=head1 BUGS

Reports to the author please.

=head1 SEE ALSO

Stuff(7)

=cut

