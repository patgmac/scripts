#!/bin/sh

# Emory University McAfee ePO installer for 10.5 and earlier
# Author: Patrick Gallagher - Emory College of Arts & Sciences
# Created: 4/18/2012
# Modified: 08/06/2012
Version=0.9.1

# Instructions: Verify the variables for pkgTar and pkgName are correct.
# Local support folks should specify correct group for CustomProps4

#  Set your Custom group, not necessary for AD-bound machines but doesn't hurt to set this.
#  Available groups:
# "CampusLife", "CampusServices", "College", "Dar", "GBS", "Law", "Library", "Oxford", "Physics", "RSPH", "SOM-Biochemistry", "SOM-Dom", "SOM-ITS"
# "SOM-Genetics", "SOM-Neurology", "SOM-Pathology", "SOM-Pediatrics", "SOM-Pharmacology", "SOM-Physiology", "SOM-psychiatry"
# "SOM-Surgery", "Son", "Student", "Theology", "UTS-Desktop", "UTS-Systems", "UTS-ATS", "Yerkes", "Other"
CustomProps4="Student"

# If you want SEP/SAV uninstalled as well, also include SymantecRemovalTool.command
# in the SupportFiles directory 
# http://www.symantec.com/business/support/index?page=content&id=TECH103489

clear
# Specify file names for the tar and mpkg
pkgTar="McAfeeSecurityForMac-Anti-malware-1.1-ePORTW-1309.mpkg.tar.gz"
pkgName="McAfeeSecurityForMac-Anti-malware-1.1-ePORTW-1309.mpkg"
#pkgTarpatch1="MSM110-1418-ePOPatch1.mpkg.tar.gz"
#pkgPatch1Name="MSM110-1418-ePOPatch1.mpkg"
plistPath="/Library/LaunchDaemons/com.mcafee.ssm.ScanManager.plist"
newPlist="com.mcafee.ssm.antimalware.plist"
antimalwarePlistPath="/Library/Preferences/com.mcafee.ssm.antimalware.plist"
osversionlong=`sw_vers -productVersion`
osvers=${osversionlong:3:1}
installScript="install.sh"
Arch=`arch`

# Get the sha1 with command: openssl sha1 install.sh
sha1=ee9a2ad936b476cd7061ea1366820e2db901802b

scriptDir=$(dirname "$0")
subFolder="SupportFiles"

if [[ $osvers != 5 ]] || [[ $Arch != "i386" ]]; then
	echo "This installer is only for Intel Macs with OS 10.5.x"
	echo "Please use the appropriate installer"
	exit 1
fi

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

# Setup logging
LogLoc=/Library/Logs/Emory_McAfee_Install.log
if [ -e "${LogLoc}" ]; then
	sudo echo >> "${LogLoc}"
	sudo echo >> "${LogLoc}"
	sudo echo >> "${LogLoc}"
	sudo echo "<<< *** New Install Log for `scutil --get HostName`: `date` *** >>>" >> "${LogLoc}"
	sudo echo >> "${LogLoc}"
	sudo echo >> "${LogLoc}"
	sudo echo >> "${LogLoc}"
else
	sudo echo "<<< *** New Install Log for `scutil --get HostName`: `date` *** >>>" > "${LogLoc}"
	sudo echo >> "${LogLoc}"
	sudo echo >> "${LogLoc}"
	sudo echo >> "${LogLoc}"
fi

cd "${scriptDir}/${subFolder}"
# Check for existing McAfee agent
# Uninstall if found
if [ -e /usr/local/McAfee/uninstallMSC ]; then
	echo "McAfee VirusScan installed already, uninstalling..."
	echo >> "${LogLoc}"
	echo >> "${LogLoc}"
	echo >> "${LogLoc}"
	echo "<<< *** Log for McAfee VirusScan Uninstall: `date` *** >>>" >> "${LogLoc}"
	sudo /usr/local/McAfee/uninstallMSC >> "${LogLoc}" 2>&1
	sleep 5
fi
if [ -e /Library/McAfee/cma/uninstall.sh ]; then
	echo "Found an existing McAfee agent, uninstalling..."
	echo >> "${LogLoc}"
	echo >> "${LogLoc}"
	echo >> "${LogLoc}"
	echo "<<< *** Log for McAfee Agent Uninstall: `date` *** >>>" >> "${LogLoc}"
	sudo sh /Library/McAfee/cma/uninstall.sh >>"${LogLoc}" 2>&1 
	sudo pkgutil --forget comp.nai.cmamac >> "${LogLoc}" 2>&1
fi

# Verify install.sh wasn't damaged or tampered with
sha2=`openssl sha1 install.sh | awk '{print $2}'`
if [ $sha1 != $sha2 ]; then
	echo "SHA1 doesn't match for install.sh"
	exit 1
fi

# Start install.sh
if [ -e "${installScript}" ]; then
	echo "Installing the McAfee agent..."
	echo >> "${LogLoc}"
	echo >> "${LogLoc}"
	echo >> "${LogLoc}"
	echo "<<< *** Log for McAfee agent install: `date` *** >>>" >> "${LogLoc}"
	sudo sh "${installScript}" -i >> "${LogLoc}" 2>&1 
	sleep 20
else 
	echo "*** ERROR: Did not find install.sh. Place this script in same folder as install.sh ***"
	exit 1
fi

# Set CustomProps4
/Library/McAfee/cma/bin/msaconfig -CustomProps4 "${CustomProps4}"

# Uncompress $pkgTar
if [ -e "${pkgTar}" ]; then
	echo "Uncompressing "${pkgTar}""
	echo >> "${LogLoc}"
	echo >> "${LogLoc}"
	echo >> "${LogLoc}"
	echo "<<< *** Log for McAfee software uncompression: `date` *** >>>" >> "${LogLoc}"
	tar -xzvf "${pkgTar}" >> "${LogLoc}" 2>&1 
else 
	echo
	echo "*** ERROR: Did not find "${pkgTar}".  Place this script in same folder as "${pkgTar}" ***"
	echo
	exit 1
fi

# Uncompress $pkgTarpatch1
#if [ -e "${pkgTarpatch1}" ]; then
#	echo "Uncompressing "${pkgTarpatch1}""
#	echo >> "${LogLoc}"
#	echo >> "${LogLoc}"
#	echo >> "${LogLoc}"
#	echo "<<< *** Log for McAfee software patch1 uncompression: `date` *** >>>" >> "${LogLoc}"
#	tar -xzvf "${pkgTarpatch1}" >> "${LogLoc}" 2>&1 
#else 
#	echo
#	echo "*** ERROR: Did not find "${pkgTarpatch1}".  Place this script in same folder as "${pkgTarpatch1}" ***"
#	echo
#	exit 1
#fi

# Install $pkgName
if [ -e "${pkgName}" ]; then
	# Check if SEP is installed
	if [ -d "/Applications/Symantec Solutions" ]; then
		echo "Found Symantec, uninstalling..."
		if [ -e SymantecRemovalTool.command ]; then
			echo >> "${LogLoc}"
		echo >> "${LogLoc}"
		echo >> "${LogLoc}"
		echo "<<< *** Log for Symantec Uninstall: `date` *** >>>" >> "${LogLoc}"
			sudo sh SymantecRemovalTool.command >> "${LogLoc}" 2>&1 
			echo "Symantec uninstalled"
		else
			echo "*** Did not find SymantecRemovalTool.command, please uninstall Symantec separately ***"
		fi
	fi
	echo "Installing "${pkgName}"..."
	echo >> "${LogLoc}"
	echo >> "${LogLoc}"
	echo >> "${LogLoc}"
	echo "<<< *** Log for McAfee VirusScan Install: `date` *** >>>" >> "${LogLoc}"
	sudo installer -pkg "${pkgName}" -target / >>"${LogLoc}" 2>&1 
		# Verify MSM installed
		if [[ ! -e "/Applications/McAfee Security.app" ]]; then
			echo "ERROR: McAfee Security not properly installed" >> "${LogLoc}"
			echo "ERROR: McAfee Security not properly installed"
			exit 1
		fi
	sleep 10
	echo "<<< Unloading the Anti-Malware Services...: `date` *** >>>" >> "${LogLoc}"
	sudo launchctl unload "${plistPath}" >>"${LogLoc}" 2>&1
	sleep 10
	echo "Copying the antimalware preference file ..."
	sudo cp -rf "${newPlist}" "${antimalwarePlistPath}"
	echo "<<< *** Copied the antimalware plist file to "${antimalwarePlistPath}": `date` *** >>>" >> "${LogLoc}"
	echo "<<< Loading the Anti-Malware Services...: `date` *** >>>" >> "${LogLoc}"
	sudo launchctl load "${plistPath}" >>"${LogLoc}" 2>&1
	echo "<<< *** Installation completed successfully....: `date` *** >>>" >> "${LogLoc}"
	rm -rf "${pkgName}" 
	#rm -rf "${pkgPatch1Name}"
else
	echo
	echo "*** ERROR: Did not find installer package ***"
	echo
	exit 1
fi

# Update status on ePO
sudo /Library/McAfee/cma/bin/cmdagent -P -C -E

echo
echo "## Install Complete. You can close this window ##"
echo

exit 0
