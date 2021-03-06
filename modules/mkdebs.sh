#!/bin/bash

erex () {
	echo "$2" 1>&2
	exit "$1"
}

# stuff_fieldset stuff_spambl stuff_type

if [ $# -gt 0 ]; then
	modules="$@"
else
	modules="stuff_chart stuff_bytesize stuff_column stuff_debug stuff_expiryset stuff_gnostic stuff_mktemp stuff_morse stuff_parserange stuff_range stuff_relpath stuff_statset stuff_table stuff_text stuff_usage"
fi

for p in $modules; do
	cd $p
	debuild --no-tgz-check || erex 1 "SOMETHING WENT WRONG MAKING DEB FOR $p in $PWD"
	cd -
done

echo "ALL DONE OK"

