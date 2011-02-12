#!/bin/sh
#ec_get_DS_landesk.sh

# Patrick Gallagher
# Modified 03/12/2010

# Plist variables
plistFile="/Library/Application Support/LANDesk/data/ldscan.core.data"
adPlist="/Library/Preferences/DirectoryService/ActiveDirectory"

### Retrieve the directory service settings

# Gets the OD domain
odDomain=`dscl localhost -list /LDAPv3` 
# Get the setting for AD machine password change settings. Some enviornments need to change this value
# so having it in inventory helps enforce this. Only applicable to 10.5 and greater
adIntervalDate=`/usr/bin/defaults read ${adPlist} "Password Change Date" | cut -c1-10`
adIntervalDays=`/usr/bin/defaults read ${adPlist} | grep Interval | cut -c38-39`
# Is the machine bound to AD?
boundToAD=`defaults read ${adPlist} "AD Bound to Domain"`
# If bound to AD, what computer name was used?
computerID=`defaults read ${adPlist} "AD Computer ID"`
# AD domain Mac is bound to
defaultADdomain=`defaults read ${adPlist} "AD Default Domain"`
# This will show the first DS in the search path. I use this to ensure that Tiger machines
# have AD first and that > 10.5 have OD first. 
searchPath=`defaults read /Library/Preferences/DirectoryService/SearchNodeConfig "Search Node Custom Path Array"`
# Check MCX trust level. Used if you are using login or logout scripts through OD.
mcxScripts=`defaults read com.apple.loginwindow EnableMCXLoginScripts`
mcxTrust=`defaults read com.apple.loginwindow MCXScriptTrust`

# Write the data to the LANDesk plist
/usr/bin/defaults write "${plistFile}" "Custom Data - Mac - Directory Services - Open Directory - Open Directory Domain" "${odDomain}"
/usr/bin/defaults write "${plistFile}" "Custom Data - Mac - Directory Services - Open Directory - Enable MCX Login Scripts" ${mcxScripts}
/usr/bin/defaults write "${plistFile}" "Custom Data - Mac - Directory Services - Open Directory - MCX Script Trust" "${mcxTrust}"
/usr/bin/defaults write "${plistFile}" "Custom Data - Mac - Directory Services - Active Directory - Active Directory Domain" "${adDomain}"
/usr/bin/defaults write "${plistFile}" "Custom Data - Mac - Directory Services - Active Directory - Password Change Date" "${adIntervalDate}"
/usr/bin/defaults write "${plistFile}" "Custom Data - Mac - Directory Services - Active Directory - Password Change Interval" -int "${adIntervalDays}"
/usr/bin/defaults write "${plistFile}" "Custom Data - Mac - Directory Services - Active Directory - AD Bound to Domain" -int "${boundToAD}"
/usr/bin/defaults write "${plistFile}" "Custom Data - Mac - Directory Services - Active Directory - AD Computer ID" "${computerID}"
/usr/bin/defaults write "${plistFile}" "Custom Data - Mac - Directory Services - Active Directory - AD Default Domain" "${defaultADdomain}"
/usr/bin/defaults write "${plistFile}" "Custom Data - Mac - Directory Services - Search Node Custom Path Array" "${searchPath}"
/usr/bin/defaults read "$plistFile"

# Running a scan gets the inventory up to date instead of waiting for the next scheduled scan to run
# If you don't want this, delete or comment out the next line. 
"/Library/Application Support/LANDesk/bin/ldscan"

exit 0


