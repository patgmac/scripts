#!/bin/sh

## bind_to_AD_10.7.sh
##
## Purpose: Unbind and rebind to AD to correct computer name in AD
## 10.7 only
## Much of this borrowed from DeployStudio bind script

# Usage: bind_to_AD_10.7.sh newComputerName
# If using Absolute Manage, enter computer name in "command line options"
 
args=("$@")
COMPUTER_ID="${1}"
 
if [ ${#} -ne 1 ]
then
  echo "Missing argument for computer name"
  echo "Usage: ${SCRIPT_NAME} <computer name>"
  exit 1
fi

# Enter a user and password for an account with unbind/bind rights
DOM_ADMIN=""
DOM_ADMIN_PASS=""
 
# Advanced options
AD_DOMAIN="eu.emory.edu"
COMPUTER_ID="${1}"
COMPUTERS_OU="OU=Macs,OU=ArtsSciences,dc=EU,dc=Emory,dc=Edu"
ADMIN_LOGIN="eccsad"
ADMIN_PWD="eccsad0607"

MOBILE="enable"
MOBILE_CONFIRM="disable"
LOCAL_HOME="enable"
USE_UNC_PATHS="disable"
UNC_PATHS_PROTOCOL="smb"
PACKET_SIGN="allow"
PACKET_ENCRYPT="allow"
PASSWORD_INTERVAL="0"
AUTH_DOMAIN="All Domains"
ADMIN_GROUPS="EMORYUNIVAD\eccsls"
OS=`/usr/bin/sw_vers | grep ProductVersion | cut -c 17-20`

if [ "${OS}" != "10.7" ]; then
	echo "This script is only for 10.7"
	exit 1
fi
 
# Unbind from AD
dsconfigad -remove -force -user $DOM_ADMIN -password $DOM_ADMIN_PASS 2>&1

 
# set computer names
echo Computer will be renamed ${1}
scutil --set ComputerName $COMPUTER_ID
scutil --set LocalHostName $COMPUTER_ID
scutil --set HostName $COMPUTER_ID
 
# Activate the AD plugin
echo "Enabling the Active Directory Plugin" 2>&1
defaults write /Library/Preferences/DirectoryService/DirectoryService "Active Directory" Active 2>&1
chmod 600 /Library/Preferences/DirectoryService/DirectoryService.plist 2>&1
 
#echo "Setting plugin options"
#dsconfigad -alldomains $alldomains -localhome $localhome -protocol $protocol \
#    -mobile $mobile -mobileconfirm $mobileconfirm -useuncpath $useuncpath \
#    -shell $user_shell -packetsign $packetsign -packetencrypt $packetencrypt -status 2>&1
 
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
    dsconfigad -add "${AD_DOMAIN}" -computer "${COMPUTER_ID}" -ou "${COMPUTERS_OU}" -username "${DOM_ADMIN}" -password "${DOM_ADMIN_PASS}" -force 2>&1
    IS_BOUND=`dsconfigad -show | grep "Active Directory Domain"`
    if [ -n "${IS_BOUND}" ]
    then
      SUCCESS="YES"
    else
      echo "An error occured while trying to bind this computer to AD, new attempt in 10 seconds..." 2>&1
      sleep 10
      ATTEMPTS=`expr ${ATTEMPTS} + 1`
    fi
  else
    echo "AD binding failed (${MAX_ATTEMPTS} attempts)" 2>&1
    SUCCESS="NO"
  fi
done
 
if [ "${SUCCESS}" = "YES" ]
then
  #
  # Update AD plugin options
  #
  echo "Setting AD plugin options..." 2>&1
  dsconfigad -mobile ${MOBILE} 2>&1
  sleep 1
  dsconfigad -mobileconfirm ${MOBILE_CONFIRM} 2>&1 
  sleep 1
  dsconfigad -localhome ${LOCAL_HOME} 2>&1
  sleep 1
  dsconfigad -useuncpath ${USE_UNC_PATHS} 2>&1
  sleep 1
  dsconfigad -protocol ${UNC_PATHS_PROTOCOL} 2>&1
  sleep 1
  dsconfigad -packetsign ${PACKET_SIGN} 2>&1
  sleep 1
  dsconfigad -packetencrypt ${PACKET_ENCRYPT} 2>&1
  sleep 1
  dsconfigad -passinterval ${PASSWORD_INTERVAL} 2>&1
  if [ -n "${ADMIN_GROUPS}" ]
  then
    sleep 1
    dsconfigad -groups "${ADMIN_GROUPS}" 2>&1
  fi
  if [ "${AUTH_DOMAIN}" != 'All Domains' ]
  then
    sleep 1
    dsconfigad -alldomains disable 2>&1
  fi
  if [ -n "${UID_MAPPING}" ]
  then
    sleep 1
    dsconfigad -uid "${UID_MAPPING}" 2>&1
  fi
  if [ -n "${GID_MAPPING}" ]
  then
    sleep 1
    dsconfigad -gid "${GID_MAPPING}" 2>&1
  fi
fi
echo "Successfully rebound machine to AD"
exit 0