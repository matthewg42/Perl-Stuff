#!/bin/bash
#
# Does the installation of the modules and programs for Stuff Tools.
#

# default, override by calling install like this:
# PREFIX=/my/prefix ./install.sh
PREFIX=${PREFIX:-/usr/local}

main () {
    echo "About to install Stuff to $PREFIX/..."
    echo "Press control-C now if you want to abort the installation, else RETURN."
    read breaker
    
    install_modules
    install_programs
    install_docs
}

install_modules () {
    echo "INSTALLING MODULES..."
    for d in modules/stuff_*; do 
	pushd $d
        if [ -a Makefile ]; then
            make clean
        fi
	perl Makefile.PL "PREFIX=$PREFIX"
	make
	make install
	popd
    done
}

install_programs () {
    # Programs
    # --------
    # I guess this should really be done more in line with the modules, 
    # but right now I just want it to work quickly!
    echo "INSTALLING PROGRAMS..."
    pushd programs
    mkdir -p "$PREFIX/bin" "$PREFIX/share/man/man1"
    for src in ascii2morse.pl cr2crlf.pl dms2dec.pl hms2dec.pl dec2dms.pl dec2hms.pl groupby.pl isprime.pl log_bt_ip.pl morse2ascii.pl sq.pl sumup.pl qps.pl spam_bl_check.pl tabulate.pl; do
	program="${src%.pl}"
	echo "Installing $program"
	
        # Generate manual pages from POD docs
	echo " + Generating manual page"
	pod2man "$src" > "$PREFIX/share/man/man1/$program.1"
	
	doit=1
	if [ -a "${PREFIX:-/usr/local}/bin/$program" ]; then
	    echo "WARNING: $PREFIX/bin/$program already exists, overwrite (Y/n)"
	    doit=0
	    read r
	    case $r in
		n|N|no|NO)
		    doit=0
		    ;;
		*)
		    doit=1
		    ;;
	    esac
	fi
	
	if [ $doit -eq 1 ]; then
	    echo " + Installing program file => $PREFIX/bin/$program"
	    install -m 755 "$src" "$PREFIX/bin/$program"
	else
	    echo " + SKIPPING program file installation ($PREFIX/bin/$program already exists)"
	fi
    done
    popd
}

install_docs () {
    # Document files look like: name.section.pod.  E.g. bananas.1.pod
    echo "INSTALLING EXTRA DOCUMENTATION..."
    pushd docs
    for doc in *.pod; do 
	pagename="${doc%.pod}"
	section="${pagename##*.}"
	pagename="${doc%%.*}"
	destdir="$PREFIX/share/man/man$section"
        destfile="$destdir/$pagename.$section"
	echo "Installing documentation from $doc to $destfile"
	if [ ! -a "$destdir" ]; then
	    mkdir -p "$destdir" && 
	    echo " + created $destdir OK" ||
	    echo " + ERROR creating dir: $destdir"
	fi

	pod2man "$doc" > "$destfile"
    done
    popd
}

main $@
