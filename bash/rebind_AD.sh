#!/bin/sh

# rebind_AD.sh
# Patrick Gallagher | patgmac at gmail dot com
# http://blog.macadmincorner.com

## Purpose: Unbind and rebind to AD to correct computer name in AD
## Much of this borrowed from DeployStudio bind script

# Usage: rebind_AD.sh newComputerName
# If using Absolute Manage, enter computer name in "command line options"

args=("$@")
echo Computer will be renamed ${1}
COMPUTER_ID="${1}"

if [ ${#} -ne 1 ]
then
  echo "Missing argument for computer name"
  echo "Usage: ${SCRIPT_NAME} <computer name>"
  exit 1
fi

# Enter a user and password for an account with unbind/bind rights
DOM_ADMIN=" "
DOM_ADMIN_PASS=" "

# Standard parameters
AD_DOMAIN="eu.emory.edu" # Change to your domain
AUTH_DOMAIN="All Domains" 
COMPUTERS_OU="CN=Computers,DC=eu,DC=emory,DC=edu"  # Change to your OU

# Advanced options
alldomains="enable"
localhome="enable"
protocol="smb"
mobile="enable"
mobileconfirm="disable"
useuncpath="disable"
user_shell="/bin/bash"
preferred="-nopreferred"	
admingroups="EMORYUNIVAD\eccsls" # change to your domain and AD group
check4AD=`dscl localhost -list /Active\ Directory`


# Unbind from AD
if [[ "${check4AD}" == "All Domains" || "$AD_DOMAIN" ]]; then
	unbind_status=`dsconfigad -r -u $DOM_ADMIN -p $DOM_ADMIN_PASS -status 2>&1`
	if [ "$unbind_status" = "Error: The credentials you supplied do not have privileges to remove this computer." ]
	then
		echo "This account does not have permission to unbind from this OU"
		exit 1
	else
		echo "Successfully unbound from AD"
		break
	fi
fi

# set computer names
scutil --set ComputerName $COMPUTER_ID
scutil --set LocalHostName $COMPUTER_ID
scutil --set HostName $COMPUTER_ID

# Activate the AD plugin
echo "Enabling the Active Directory Plugin" 2>&1
defaults write /Library/Preferences/DirectoryService/DirectoryService "Active Directory" Active 2>&1
chmod 600 /Library/Preferences/DirectoryService/DirectoryService.plist 2>&1

echo "Setting plugin options"
dsconfigad -alldomains $alldomains -localhome $localhome -protocol $protocol \
	-mobile $mobile -mobileconfirm $mobileconfirm -useuncpath $useuncpath \
	-shell $user_shell $preferred -status 2>&1
	
# Set --passinterval on 10.5 or later
if [ `sw_vers -productVersion | awk -F. '{ print $2 }'` -ge 5 ]
then
	dsconfigad -passinterval 0 -status 2>&1
fi

# Do the bind
#dsconfigad -a "${COMPUTER_ID}" -domain "${AD_DOMAIN}" -u "${DOM_ADMIN}" -p "${DOM_ADMIN_PASS}" -ou "${ou}" -status 2>&1

# Configure advanced AD plugin options
if [ "$admingroups" = "" ]; then
	dsconfigad -nogroups -status 2>&1
else
	dsconfigad -groups "$admingroups" -status 2>&1
fi

#
# Try to bind the computer
#
ATTEMPTS=0
MAX_ATTEMPTS=12
SUCCESS=
while [ -z "${SUCCESS}" ]
do
  if [ ${ATTEMPTS} -le ${MAX_ATTEMPTS} ]
  then
    echo "Binding computer to domain ${AD_DOMAIN}..." 2>&1
    dsconfigad -f -a "${COMPUTER_ID}" -domain "${AD_DOMAIN}" -ou "${COMPUTERS_OU}" -u "${DOM_ADMIN}" -p "${DOM_ADMIN_PASS}" -status 2>&1
	IS_BOUND=`defaults read /Library/Preferences/DirectoryService/ActiveDirectory "AD Bound to Domain"`
    if [ ${IS_BOUND} -eq 1 ]
    then
	  SUCCESS="YES"
    else
	  echo "An error occured while trying to bind this computer to AD, new attempt in 10 seconds..." 2>&1
      sleep 10
      ATTEMPTS=`expr ${ATTEMPTS} + 1`
    fi
  else
    echo "AD binding failed (${MAX_ATTEMPTS} attempts), will retry at next boot!" 2>&1
    SUCCESS="NO"
  fi
done

if [ "${SUCCESS}" = "YES" ]
then
  #
  # Restart the DirectoryService
  #
  echo "Killing DirectoryService daemon..." 2>&1
  killall DirectoryService
  sleep 5

  #
  # Trigger the node availability
  #
  echo "Triggering '/Active Directory/${AUTH_DOMAIN}' node..." 2>&1
  NODE_AVAILABILITY=`dscl localhost -read "/Active Directory/${AUTH_DOMAIN}" | grep "NodeAvailability:" | grep "Available"`
  ATTEMPTS=0
  MAX_ATTEMPTS=12
  while [ -z "${NODE_AVAILABILITY}" ]
  do
    if [ ${ATTEMPTS} -le ${MAX_ATTEMPTS} ]
    then
      NODE_AVAILABILITY=`dscl localhost -read "/Active Directory/${AUTH_DOMAIN}" | grep "NodeAvailability:" | grep "Available"`
	  if [ -z "${NODE_AVAILABILITY}" ]
	  then
	    echo "The '/Active Directory/${AUTH_DOMAIN}' node is unavailable, new attempt in 10 seconds..." 2>&1
        sleep 10
        ATTEMPTS=`expr ${ATTEMPTS} + 1`
      fi
    else
      echo "AD directory node lookup failed (${MAX_ATTEMPTS} attempts), will retry at next boot!" 2>&1
      exit 1
    fi
  done

  #
  # Update the search policy
  #
  echo "Updating authentication search policy..." 2>&1
  CSP_SEARCH_POLICY=`dscl localhost -read /Search | grep "SearchPolicy:" | grep -i "CSPSearchPath"`
  if [ -z "${CSP_SEARCH_POLICY}" ]
  then
    ATTEMPTS=0
    MAX_ATTEMPTS=12
    SUCCESS=
    while [ -z "${SUCCESS}" ]
    do
      if [ ${ATTEMPTS} -le ${MAX_ATTEMPTS} ]
      then
        dscl localhost -create /Search SearchPolicy CSPSearchPath 2>&1
        if [ ${?} -eq 0 ]
        then
          SUCCESS="YES"
        else
          echo "An error occured while trying to update the authentication search policy, new attempt in 10 seconds..." 2>&1
          sleep 10
          ATTEMPTS=`expr ${ATTEMPTS} + 1`
        fi
	  else
        echo "Authentication search policy update failed (${MAX_ATTEMPTS} attempts), will retry at next boot!" 2>&1
	    exit 1
      fi
    done
  fi

  echo "Updating contacts search policy..." 2>&1
  CSP_SEARCH_POLICY=`dscl localhost -read /Contact | grep "SearchPolicy:" | grep -i "CSPSearchPath"`
  if [ -z "${CSP_SEARCH_POLICY}" ]
  then
    ATTEMPTS=0
    MAX_ATTEMPTS=12
    SUCCESS=
    while [ -z "${SUCCESS}" ]
    do
      if [ ${ATTEMPTS} -le ${MAX_ATTEMPTS} ]
      then
        dscl localhost -create /Contact SearchPolicy CSPSearchPath 2>&1
        if [ ${?} -eq 0 ]
        then
          SUCCESS="YES"
        else
          echo "An error occured while trying to update the contacts search policy, new attempt in 10 seconds..." 2>&1
          sleep 10
          ATTEMPTS=`expr ${ATTEMPTS} + 1`
        fi
	  else
        echo "Contacts search policy update failed (${MAX_ATTEMPTS} attempts), will retry at next boot!" 2>&1
	    exit 1
      fi
    done
  fi
  
  #
  # Add "${AUTH_DOMAIN}" to the search path
  #
  echo "Updating authentication search path..." 2>&1
  AD_SEARCH_PATH=`dscl localhost -read /Search | grep "CSPSearchPath:" | grep -i "/Active Directory/${AUTH_DOMAIN}"`
  if [ -z "${AD_SEARCH_PATH}" ]
  then
    ATTEMPTS=0
    MAX_ATTEMPTS=12
    SUCCESS=
    while [ -z "${SUCCESS}" ]
    do
      if [ ${ATTEMPTS} -le ${MAX_ATTEMPTS} ]
      then
        dscl localhost -append /Search CSPSearchPath "/Active Directory/${AUTH_DOMAIN}" 2>&1
        if [ ${?} -eq 0 ]
        then
	      SUCCESS="YES"
        else
          echo "An error occured while trying to update the authentication search path, new attempt in 10 seconds..." 2>&1
          sleep 10
          ATTEMPTS=`expr ${ATTEMPTS} + 1`
        fi
	  else
        echo "Authentication search path update failed (${MAX_ATTEMPTS} attempts), will retry at next boot!" 2>&1
        exit 1
      fi
    done
  fi

  echo "Updating contacts search path..." 2>&1
  AD_SEARCH_PATH=`dscl localhost -read /Contact | grep "CSPSearchPath:" | grep -i "/Active Directory/${AUTH_DOMAIN}"`
  if [ -z "${AD_SEARCH_PATH}" ]
  then
    ATTEMPTS=0
    MAX_ATTEMPTS=12
    SUCCESS=
    while [ -z "${SUCCESS}" ]
    do
      if [ ${ATTEMPTS} -le ${MAX_ATTEMPTS} ]
      then
        dscl localhost -append /Contact CSPSearchPath "/Active Directory/${AUTH_DOMAIN}" 2>&1
        if [ ${?} -eq 0 ]
        then
	      SUCCESS="YES"
        else
          echo "An error occured while trying to update the contacts search path, new attempt in 10 seconds..." 2>&1
          sleep 10
          ATTEMPTS=`expr ${ATTEMPTS} + 1`
        fi
	  else
        echo "Contacts search path update failed (${MAX_ATTEMPTS} attempts), will retry at next boot!" 2>&1
        exit 1
      fi
    done
  fi
 fi