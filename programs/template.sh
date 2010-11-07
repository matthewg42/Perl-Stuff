#!/bin/bash
# Template shell script
# Some script scope variables and function defs first.  To skip to the 
# main program, search for the comment "Start Main Program"
###############################################################################
# basename and full path of program
THISSCRIPT=${0##*/}
THISSCRIPT_FULL="$0"

# Debugging level.  Set this with the -D option:
# -ve = ERROR
#   0 = WARNING
# +ve = DEBUG
DBLEV_S=${DBLEV_S:-0}

# Some useful function definitions
usage () {
  pod2usage $THISSCRIPT_FULL
  exit ${1:-0}
}

# usage example (warning): db_out 0 "a warning message"
db_out () {
  meslev="${1:-1}"
  shift
  message="$@"
  
  if [ $meslev -le ${DBLEV_S:-0} ]; then
    if [ $meslev -lt 0 ]; then
      mestyp="$THISSCRIPT ERROR[$meslev]:"
    elif [ $meslev -eq 0 ]; then
      mestyp="$THISSCRIPT WARNING:"
    else
      mestyp="$THISSCRIPT DEBUG[$meslev]:"
    fi

    print -u2 "$mestyp $message"
  fi
}

#
# End of generic functions and the like
###############################################################################
# Start Main Program

PROGNAME="Template MNG shell script"
VERSION="0.01"
AUTHOR="Matthew Gates, MMM YYYY"

if [ "$1" = "--help" ] || [ "$1" = "-help" ]; then
  usage 0
fi

set -- `getopt vhD: $@`
if [ $? -ne 0 ]; then
  usage 2
fi

while [ $# -gt 0 ]; do
  case $1 in
    -D)
	DBLEV_S=$2
	shift 2
	;;
    -h)
	usage 0
	shift
	;;
    -v)
	echo "$PROGNAME; version $VERSION"
	echo "$AUTHOR"
	shift
	;;
    --)
	shift
	break
	;;
  esac
done

db_out 3 "command line parsed, parameters now: $@"

exit 0

__END__

