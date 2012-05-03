#!/bin/sh

# Emory University McAfee ePO installer
# Author: Patrick Gallagher - Emory College of Arts & Sciences
# Created: 4/18/2012
<<<<<<< HEAD
# Modified: 4/25/2012
=======
# Modified: 4/26/2012
>>>>>>> Updates
Version=0.3

# Instructions: Verify the variables for pkgTar and pkgName are correct.
# Also the var for sha1
# If you want SEP/SAV uninstalled as well, also include SymantecRemovalTool.command
# in the same directory. 
# http://www.symantec.com/business/support/index?page=content&id=TECH103489

clear
# Use relative paths
pkgTar="McAfeeSecurityForMac-1.1-ePO-1309.mpkg.tar.gz"
pkgName="McAfeeSecurityForMac-1.1-ePO-1309.mpkg"
installScript="install.sh"

# Get the sha1 with command: openssl sha1 install.sh
sha1=ac6ed3dafb8c3b21578ff43bb506b4cfcd463918

#  Set your Custom group, not necessary for AD-bound machines but doesn't hurt to set this.
#  Available groups:
# "CampusLife", "CampusServices", "College", "Dar", "GBS", "Law", "Library", "Oxford", "Physics", "RSPH", "SOM-Dom", "SOM-ITS"
# "SOM-Genetics", "SOM-Neurology", "SOM-Pathology", "SOM-Pediatrics", "SOM-Pharmacology", "SOM-Physiology", "SOM-psychiatry"
# "SOM-Surgury", "Son", "Student", "Theology", "UTS", "UTS-ATS", "Yerkes", "Other"
CustomProps4="Student"

scriptDir=$(dirname "$0")
subFolder="SupportFiles"

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

# Setting hostname to match computer name
compname=`scutil --get ComputerName`
sudo scutil --set HostName "${compname}"
echo "Hostname set to `scutil --get HostName`"

<<<<<<< HEAD
cd "${scriptDir}/${subFolder}"
# Check for existing McAfee agent
# Uninstall if found
if [ -e /Library/McAfee/cma/install.sh ]; then
	echo "Found an existing McAfee agent, uninstalling...
	sudo sh /Library/McAfee/cma/install.sh &>mcafee_uninstall.out
=======

cd "${scriptDir}/${subFolder}"

# Verify install.sh wasn't damaged or tampered with
sha2=`openssl sha1 install.sh | awk '{print $2}'`
if [ $sha1 != $sha2 ]; then
	echo "SHA1 doesn't match for install.sh"
	exit 1
>>>>>>> Updates
fi

# Start install.sh
if [ -e "${installScript}" ]; then
	echo "Found install.sh, running..."
	sudo sh "${installScript}" -i &>install.sh.out
	sleep 15
else 
	echo "*** ERROR: Did not find install.sh. Place this script in same folder as install.sh ***"
	exit 1
fi

# Set CustomProps4
/Library/McAfee/cma/bin/msaconfig -CustomProps4 "${CustomProps4}"
/Library/McAfee/cma/bin/cmdagent -P

# Uncompress $pkgTar
if [ -e "${pkgTar}" ]; then
	echo "Uncompressing "${pkgTar}"" 
	tar -xzvf "${pkgTar}" &>mcafee_untar.out
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
			sudo sh SymantecRemovalTool.command &>Symantec_Uninstall.out
			echo "Symantec uninstalled"
		else
			echo "*** Did not find SymantecRemovalTool.command, please uninstall Symantec separately ***"
		fi
	fi
	echo "Installing "${pkgName}"..."
	sudo installer -pkg "${pkgName}" -target / &>ePO_install.out
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