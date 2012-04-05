#!/bin/sh

# ================================================================================
# check-for-osx-flashback.K.sh
#
# Script to check system for any signs of OSX/Flashback.K trojan
# Checks are based on information from F-Secure's website:
# http://www.f-secure.com/v-descs/trojan-downloader_osx_flashback_k.shtml
#
# Hannes Juutilainen, hjuutilainen@mac.com
# Patrick Gallagher, pgalla2@emory.edu - Modified to work with Absolute Manage
#
# History:
# - 2012-04-03, Hannes Juutilainen, first version
# - 2012-04-05, Patrick Gallagher
# ================================================================================

# Check for root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" 2>&1
    exit 1
fi

defaults read /Applications/Safari.app/Contents/Info LSEnvironment > /dev/null 2>&1
if [[ $? -eq 0 ]]; then
	printf "%b\n\n" "===> WARNING: Found LSEnvironment in Safari Info.plist"
fi

if [[ -f /Users/Shared/.libgmalloc.dylib ]]; then
	printf "%b\n\n" "===> WARNING: Found /Users/Shared/.libgmalloc.dylib"
fi

shopt -s nullglob
USER_HOMES=/Users/*
for f in $USER_HOMES
do
	#echo "---> Checking $f/.MacOSX/environment.plist"
	if [[ -f $f/.MacOSX/environment.plist ]]; then
		defaults read $f/.MacOSX/environment DYLD_INSERT_LIBRARIES > /dev/null 2>&1
		if [[ $? -eq 0 ]]; then
			printf "%b\n" "===> WARNING: Found DYLD_INSERT_LIBRARIES key in $f/.MacOSX/environment"
		fi
	fi
done
shopt -u nullglob
#printf "%b\n\n" "---> Done"

exit 0