#!/bin/sh

# Emory College fistboot-config.sh script 
# Created 11/11/2010
# Modified 01/12/2015

localAdmin=eccsadmin
ntpserver="ntp.service.emory.edu"
timezone="America/New_York"

osvers=$(sw_vers -productVersion | awk -F. '{print $2}')
sw_vers=$(sw_vers -productVersion)
sw_build=$(sw_vers -buildVersion)

update_dyld_shared_cache -root /

# Config networking
networksetup -detectnewhardware
networksetup -setnetworkserviceenabled FireWire off
networksetup -setnetworkserviceenabled "Thunderbolt Bridge" off

# Changes roots and Guest's shell to /usr/bin/false which disables their ability to login to a shell or GUI
/usr/bin/dscl . -create /Users/root UserShell /usr/bin/false
/usr/bin/dscl . -create /Users/Guest UserShell /usr/bin/false

# Setup ssh
dseditgroup -o create -q com.apple.access_ssh
dseditgroup -o edit -a ${localAdmin} -t user com.apple.access_ssh
dseditgroup -o edit -a admin -t group com.apple.access_ssh

#/usr/libexec/PlistBuddy -c "Delete Disabled" "/System/Library/LaunchDaemons/ssh.plist"
systemsetup -setremotelogin on
launchctl load -w /System/Library/LaunchDaemons/ssh.plist

# Display login window as Name and Password.
defaults write "/Library/Preferences/com.apple.loginwindow" SHOWFULLNAME -bool YES

#Enable ARD client
KICKSTRT="/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart"
$KICKSTRT -configure -allowAccessFor -specifiedUsers
sleep 1
$KICKSTRT -activate -configure -users ${localAdmin} -privs -DeleteFiles -TextMessages -OpenQuitApps -GenerateReports -RestartShutDown -SendFiles -ChangeSettings -access -on -clientopts -setreqperm -reqperm yes -setmenuextra -menuextra yes -restart -agent

# Disable GateKeeper
spctl --master-disable
 
#Starts the Flurry screensaver over the login window when idle for 120 seconds
defaults write "/Library/Preferences/com.apple.screensaver" loginWindowIdleTime -int 120
defaults write "/Library/Preferences/com.apple.screensaver" loginWindowModulePath "/System/Library/Screen Savers/Flurry.saver"
 
# Use encrypted virtual memory.
defaults write "/Library/Preferences/com.apple.virtualMemory" UseEncryptedSwap -bool Yes
 
# Set Safari Preferences.
defaults write "/System/Library/User Template/English.lproj/Library/Preferences/com.apple.Safari" HomePage "http://www.emory.edu/"
defaults write "/System/Library/User Template/English.lproj/Library/Preferences/com.apple.Safari" ShowStatusBar -bool YES
 
# Set Finder Prefereces.
defaults write "/System/Library/User Template/English.lproj/Library/Preferences/com.apple.finder" ShowMountedServersOnDesktop -bool YES
 
# No .ds-store files on Network Shares
defaults write "/Library/Preferences/com.apple.desktopservices" DSDontWriteNetworkStores true
 
# Globally Set Expanded Print dialog Box.
defaults write "/Library/Preferences/.GlobalPreferences" PMPrintingExpandedStateForPrint -bool TRUE
 
# Use short-name for logging into Network Shares
defaults write "/Library/Preferences/com.apple.NetworkAuthorization" UseDefaultName -bool NO
defaults write "/Library/Preferences/com.apple.NetworkAuthorization" UseShortName -bool YES
 
# Set Apple Mouse button 1 to Primary click and button 2 to Secondary click.
defaults write "/System/Library/User Template/English.lproj/Library/Preferences/com.apple.driver.AppleHIDMouse" Button1 -integer 1
defaults write "/System/Library/User Template/English.lproj/Library/Preferences/com.apple.driver.AppleHIDMouse" Button2 -integer 2

# Turn off backwards mouse scrolling
defaults write "/System/Library/User Template/English.lproj/Library/Preferences/.GlobalPreferences" com.apple.swipescrolldirection -bool false
 
# Disable Time Machine Offers.
defaults write "/Library/Preferences/com.apple.TimeMachine" DoNotOfferNewDisksForBackup -bool YES
 
# Disable Time Machine AutoBackup
defaults write "/Library/Preferences/com.apple.TimeMachine" AutoBackup 0

# Set network time server
/usr/sbin/systemsetup -setusingnetworktime on -setnetworktimeserver ${ntpserver}
/usr/sbin/systemsetup -settimezone ${timezone}
ntpdate -bvs ${ntpserver}
 
# Enable firewall
defaults write "/Library/Preferences/com.apple.alf" globalstate -int 1
/usr/libexec/ApplicationFirewall/socketfilterfw -k

# Allow admin users to add printers
/usr/sbin/dseditgroup -o edit -a admin -t group _lpadmin

# Energy Saver settings
/usr/bin/pmset -a displaysleep 10 disksleep 10 -b sleep 15 -a womp 1 -c sleep 0

# Show system info at login window
/usr/bin/defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

# Kill iCloud assistant
if [[ ${osvers} -ge 7 ]]; then

 for USER_TEMPLATE in "/System/Library/User Template"/*
  do
    defaults write "${USER_TEMPLATE}"/Library/Preferences/com.apple.SetupAssistant DidSeeCloudSetup -bool TRUE
    defaults write "${USER_TEMPLATE}"/Library/Preferences/com.apple.SetupAssistant GestureMovieSeen none
    defaults write "${USER_TEMPLATE}"/Library/Preferences/com.apple.SetupAssistant LastSeenCloudProductVersion "${sw_vers}"
    defaults write "${USER_TEMPLATE}"/Library/Preferences/com.apple.SetupAssistant LastSeenBuddyBuildVersion "${sw_build}"
  done
fi

# Configuring diagnostic report settings.
SUBMIT_DIAGNOSTIC_DATA_TO_APPLE=FALSE
SUBMIT_DIAGNOSTIC_DATA_TO_APP_DEVELOPERS=FALSE

if [[ ${osvers} -ge 10 ]]; then

  CRASHREPORTER_SUPPORT="/Library/Application Support/CrashReporter"
 
  if [ ! -d "${CRASHREPORTER_SUPPORT}" ]; then
    mkdir "${CRASHREPORTER_SUPPORT}"
    chmod 775 "${CRASHREPORTER_SUPPORT}"
    chown root:admin "${CRASHREPORTER_SUPPORT}"
  fi

 /usr/bin/defaults write "$CRASHREPORTER_SUPPORT"/DiagnosticMessagesHistory AutoSubmit -boolean ${SUBMIT_DIAGNOSTIC_DATA_TO_APPLE}
 /usr/bin/defaults write "$CRASHREPORTER_SUPPORT"/DiagnosticMessagesHistory AutoSubmitVersion -int 4
 /usr/bin/defaults write "$CRASHREPORTER_SUPPORT"/DiagnosticMessagesHistory ThirdPartyDataSubmit -boolean ${SUBMIT_DIAGNOSTIC_DATA_TO_APP_DEVELOPERS}
 /usr/bin/defaults write "$CRASHREPORTER_SUPPORT"/DiagnosticMessagesHistory ThirdPartyDataSubmitVersion -int 4
 /bin/chmod a+r "$CRASHREPORTER_SUPPORT"/DiagnosticMessagesHistory.plist
 /usr/sbin/chown root:admin "$CRASHREPORTER_SUPPORT"/DiagnosticMessagesHistory.plist
fi

# Hide Boot Camp Assistant
chflags hidden /Applications/Utilities/Boot\ Camp\ Assistant.app

exit 0