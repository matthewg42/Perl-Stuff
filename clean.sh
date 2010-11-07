#!/bin/bash 
#
# Nukes the files generted by perl Makefile.PL in the
# modules directories, and also any emacs backup files.

for f in modules/stuff_*; do 
    pushd $f
    if [ ! -e Makefile ]; then
	perl Makefile.PL PREFIX=${PREFIX:-/usr/local}
    fi
    make distclean
    popd
done

find . -type f -name \*~ |xargs rm
