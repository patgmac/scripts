#!/bin/sh

# Emory University McAfee ePO installer
# Author: Patrick Gallagher - Emory College of Arts & Sciences
# Created: 4/18/2012
# Modified: 4/23/2012
Version=0.1

# Instructions: Verify the variables for pkgTar and pkgName are correct.
# Drop this script into the same directory as install.sh and $pkgTar
# If you want SEP/SAV uninstalled as well, also include SymantecRemovalTool.command
# in the same directory. 
# http://www.symantec.com/business/support/index?page=content&id=TECH103489

clear
# Use relative paths
pkgTar="McAfeeSecurityForMac-1.1-ePO-1309.mpkg.tar.gz"
pkgName="McAfeeSecurityForMac-1.1-ePO-1309.mpkg"
installScript="install.sh"

# Set your CustomProps
grp="\
Emory College \
UTS-Desktop"

CustomProps4="Student"

scriptDir=$(dirname "$0")



RunAsRoot()
{
    ##  Pass in the full path to the executable as $1
    if [[ "${USER}" != "root" ]] ; then
    	echo
        echo "***  You must be an admin user to run this script.  ***"
        echo "***  Please enter your admin password. ***"
        echo
        sudo "${1}" && exit 0
    fi
}

RunAsRoot "${0}"

printf "%b" "\a\n\nPlease select the appropriate group:\n" >&2
select grp in $listgroups

# Setting hostname to match computer name
sudo scutil --set HostName `scutil --get ComputerName`
echo "Hostname set to `scutil --get HostName`"

# Start install.sh
cd "${scriptDir}"
if [ -e "${installScript}" ]; then
	sudo sh "${installScript}" -i
	sleep 30
else 
	echo "*** ERROR: Did not find install.sh. Place this script in same folder as install.sh ***"
	exit 1
fi

# Set CustomProps4
/Library/McAfee/cma/bin/msaconfig -CustomProps4 "${CustomProps4}"

# Uncompress $pkgTar
if [ -e "${pkgTar}" ]; then
	echo "Uncompressing "${pkgTar}""
	tar -xzvf "${pkgTar}"
else 
	echo
	echo "*** ERROR: Did not find "${pkgTar}".  Place this script in same folder as "${pkgTar}" ***"
	echo
	exit 1
fi

# Install $pkgName
if [ -e "${pkgName}" ]; then
	# Check if SEP is installed
	if [ -d "/Applications/Symantec Solutions" ]; then
		echo "Found Symantec, uninstalling..."
		if [ -e SymantecRemovalTool.command ]; then
			sudo sh SymantecRemovalTool.command
			echo "Symantec uninstalled"
		else
			echo "*** Did not find SymantecRemovalTool.command, please uninstall Symantec separately ***"
		fi
	fi
	echo "Found "${pkgName}", installing"
	sudo installer -pkg "${pkgName}" -target /
	rm -rf "${pkgName}"
else
	echo
	echo "*** ERROR: Did not find installer package ***"
	echo
	exit 1
fi

echo
echo "## Install Complete. You can close this window ##"
echo

exit 0