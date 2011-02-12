#!/bin/sh# ec_Bind_to_OD.sh# Patrick Gallagher | patgmac at gmail dot com# http://blog.macadmincorner.com# Updated 12/11/2009# Purpose: Unbinds from old OD server, bind to new OD server. Can also be used if there is no old OD# Anonymous bind, adds computer account to OD computer group# Set variables for your enviornmentodAdmin=""odPassword=""oldDomain="oldserver.school.edu"oldODip="10.0.1.1"computerName=`/usr/sbin/scutil --get LocalHostName`nicAddress=`ifconfig en0 | grep ether | awk '{print $2}'`domain="od.school.edu"computerGroup=computers  # Add appropriate computer group, case sensitive check4OD=`dscl localhost -list /LDAPv3`check4ODacct=`dscl /LDAPv3/${domain} -read Computers/${computerName} RealName | cut -c 11-`check4AD=`dscl localhost -list /Active\ Directory`ADdomain="eu.emory.edu"osversionlong=`sw_vers -productVersion`osvers=${osversionlong:3:1}# Removing SUS# Delete or comment out the next 3 lines if you don't wish to nuke use of SUSecho "Removing locally configured SUS"defaults delete /Library/Preferences/com.apple.SoftwareUpdate CatalogURLdefaults delete /var/root/Library/Preferences/com.apple.SoftwareUpdate CatalogURL# Check if on OD alreadyif [ "${check4OD}" == "${domain}" ]; then	echo "This machine is joined to ${domain} already."	odSearchPath=`defaults read /Library/Preferences/DirectoryService/SearchNodeConfig "Search Node Custom Path Array" | grep $domain`	if [ "${odSearchPath}" = "" ]; then		echo "$domain not found in search path. Adding..."		dscl /Search -append / CSPSearchPath /LDAPv3/$domain		sleep 10	fielse if [ "${check4OD}" == "${oldDomain}" ]; then	echo "Removing from ${oldDomain}"	dsconfigldap -r "${oldDomain}"	dscl /Search -delete / CSPSearchPath /LDAPv3/"${oldDomain}"	dscl /Search/Contacts -delete / CSPSearchPath /LDAPv3/"${oldDomain}"	echo "Binding to $domain"	defaults write /Library/Preferences/DirectoryService/DirectoryService "LDAPv3" Active	dsconfigldap -v -a $domain -n $domain	dscl /Search -create / SearchPolicy CSPSearchPath	dscl /Search -append / CSPSearchPath /LDAPv3/$domain	killall DirectoryServiceelse if [ "${check4OD}" == "${oldODip}" ]; then	echo "Removing from ${oldODip}"		dsconfigldap -r "${oldODip}"		dscl /Search -delete / CSPSearchPath /LDAPv3/"${oldODip}"		dscl /Search/Contacts -delete / CSPSearchPath /LDAPv3/"${oldODip}"		echo "Binding to $domain"		defaults write /Library/Preferences/DirectoryService/DirectoryService "LDAPv3" Active		dsconfigldap -v -a $domain -n $domain		dscl /Search -create / SearchPolicy CSPSearchPath		dscl /Search -append / CSPSearchPath /LDAPv3/$domain		killall DirectoryServiceelse	echo "No previous OD servers found, binding to $domain"	dsconfigldap -v -a $domain -n $domain	defaults write /Library/Preferences/DirectoryService/DirectoryService "LDAPv3" Active	dscl /Search -create / SearchPolicy CSPSearchPath	dscl /Search -append / CSPSearchPath /LDAPv3/$domain	fififikillall DirectoryServicesleep 20	if [ "${check4ODacct}" == "${computerName}" ]; then 	echo "This machine has a computer account on ${domain} already."else	echo "Adding computer account to ${domain}"	dscl -u "${odAdmin}" -P "${odPassword}" /LDAPv3/${domain} -create /Computers/${computerName} ENetAddress "$nicAddress"	dscl -u "${odAdmin}" -P "${odPassword}" /LDAPv3/${domain} -merge /Computers/${computerName} RealName ${computerName}	# Add computer to ComputerList	dscl -u "${odAdmin}" -P "${odPassword}" /LDAPv3/${domain} -merge /ComputerLists/${computerGroup} apple-computers ${computerName}					# Set the GUID	GUID="$(dscl /LDAPv3/${domain} -read /Computers/${computerName} GeneratedUID | awk '{ print $2 }')"	# Add to computergroup	dscl -u "${odAdmin}" -P "${odPassword}" /LDAPv3/${domain} -merge /ComputerGroups/${computerGroup} apple-group-memberguid "${GUID}"	dscl -u "${odAdmin}" -P "${odPassword}" /LDAPv3/${domain} -merge /ComputerGroups/${computerGroup} memberUid ${computerName}fi# Fix DS search orderecho "Checking DS search order..."if [ "${check4AD}" == "${adDomain}" ]; then	echo "AD is set to ${check4AD}"	dsconfigad -alldomains enable	dscl /Search -delete / CSPSearchPath "/Active Directory/${adDomain}"	dscl /Search/Contacts -delete / CSPSearchPath "/Active Directory/${adDomain}"	dscl /Search -append / CSPSearchPath "/Active Directory/All Domains"	if [ $osvers -eq 4 ]; then		echo "OS detected as ${osversionlong}"		echo "Setting AD, then OD to search order..."		dscl localhost changei /Search CSPSearchPath 2 "/Active Directory/All Domains"		dscl localhost changei /Search CSPSearchPath 3 /LDAPv3/$domain		dscl /Search/Contacts -append / CSPSearchPath "/Active Directory/All Domains"	else if [[ ${osvers} -eq 5 || 6 ]]; then		echo "OS detected as ${osversionlong}"		echo "Setting OD, then AD to search order..."		dscl localhost changei /Search CSPSearchPath 2 /LDAPv3/$domain		dscl localhost changei /Search CSPSearchPath 3 "/Active Directory/All Domains"		dscl /Search/Contacts -append / CSPSearchPath "/Active Directory/All Domains"	fifi	else if [ "${check4AD}" == "All Domains" ]; then	echo "AD is set to ${check4AD}"	dscl localhost -append /Search CSPSearchPath "/Active Directory/All Domains"	sleep 10		if [ $osvers -eq 4 ]; then			echo "OS detected as ${osversionlong}"			echo "Setting AD, then OD to search order..."			dscl localhost changei /Search CSPSearchPath 1 "/Active Directory/All Domains"			dscl localhost changei /Search CSPSearchPath 2 /LDAPv3/$domain		else if [[ ${osvers} -eq 5 || 6 ]]; then			echo "OS detected as ${osversionlong}"			echo "Setting OD, then AD to search order..."			dscl localhost changei /Search CSPSearchPath 2 /LDAPv3/$domain			dscl localhost changei /Search CSPSearchPath 3 "/Active Directory/All Domains"			dscl /Search/Contacts -append / CSPSearchPath "/Active Directory/All Domains"		fi	fififiecho "Enabling MCX login scripts"defaults write /var/root/Library/Preferences/com.apple.loginwindow EnableMCXLoginScripts -bool TRUEdefaults write /var/root/Library/Preferences/com.apple.loginwindow MCXScriptTrust Anonymous		echo "Finished. Exiting..."exit 0