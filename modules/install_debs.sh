#!/bin/bash
# install them in a dependency safe order...

for deb in libstuff-debug-perl*.deb libstuff-mktemp-perl*.deb libstuff-usage-perl*.deb libstuff-text-perl*.deb libstuff-column-perl*.deb libstuff-table-perl*.deb libstuff-bytesize-perl*.deb libstuff-chart-perl*.deb libstuff-morse-perl*.deb libstuff-range-perl*.deb libstuff-parserange-perl*.deb libstuff-relpath-perl*.deb libstuff-statset-perl*.deb; do
	sudo dpkg --install "$deb"
done
