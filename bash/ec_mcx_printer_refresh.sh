#!/bin/sh

# ec_mcx_printer_refresh.sh

# Patrick Gallagher
# Modified 5/5/2010

# Purpose: Logout script to delete any MCX printers using a generic ppd. 
# If correct printer driver is installed after mcx applied, printer needs to be deleted for new driver to be used


for i in `lpstat -p | grep mcx | awk '{print $2}'`; 
	do make=`lpoptions -d "$i" | grep -o -e "model='.*'" | awk -F"'" '{print $2}'`
	p=`lpinfo --make-and-model "$make" -m | grep generic | awk '{print $2}'`
	if [ "$p" == "Generic" ]; then
		lpadmin -x "$i"
	fi
	done
exit 0