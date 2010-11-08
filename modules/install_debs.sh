#!/bin/bash
# install them in a dependency safe order...

for deb in libstuff-debug-perl_0-1_all.deb libstuff-mktemp-perl_0-1_all.deb libstuff-usage-perl_0-1_all.deb libstuff-text-perl_0-1_all.deb libstuff-column-perl_0-1_all.deb libstuff-table-perl_0-1_all.deb libstuff-bytesize-perl_0-1_all.deb libstuff-chart-perl_0-1_all.deb libstuff-morse-perl_0-1_all.deb libstuff-range-perl_0-1_all.deb libstuff-parserange-perl_0-1_all.deb libstuff-relpath-perl_0-1_all.deb libstuff-statset-perl_0-1_all.deb; do
	sudo dpkg --install "$deb"
done
