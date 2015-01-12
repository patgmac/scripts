#!/bin/sh

# delete_mcx_printers.sh

# Patrick Gallagher
# Modified 1/9/2014

for i in `lpstat -p | grep mcx | awk '{print $2}'`; do lpadmin -x "$i"; done
exit 0