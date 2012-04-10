#!/bin/sh

# check-for-jsched_flashback.sh
# Patrick Gallagher | Emory College
#
# Checks for a variant of Flashback.k which installs a com.sun.jsched.plist
# file in the users Library/LaunchAgents and executes a hidden file .jsched in ~/. 

# Check for root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" 2>&1
    exit 1
fi

USER_HOMES=/Users/*
for f in $USER_HOMES
do
	if [ -f $f/.jsched ]; then
		echo "Found .jsched"
		rm -f $f/.jsched
		echo "Deleted .jsched"
	fi
done

for f in $USER_HOMES
do
	if [ -f $f/Library/LaunchAgents/com.sun.jsched.plist ]; then
		echo "Found fake Java preference"
		rm -f $f/Library/LaunchAgents/com.sun.jsched.plist
		echo "Deleted com.sun.jsched.plist"
	fi
done

exit 0