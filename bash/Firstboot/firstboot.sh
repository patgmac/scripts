#!/bin/sh

# ECCS firstboot.sh script 
# Created 11/11/2010
# Modified 3/19/2012

 
# Run update_dyld_shared_cache
/usr/bin/update_dyld_shared_cache -universal_boot -root /

# Config networking
networksetup -detectnewhardware
networksetup -setnetworkserviceenabled FireWire off

# Changes roots and Guest's shell to /usr/bin/false which disables their ability to login to a shell or GUI
/usr/bin/dscl . -create /Users/root UserShell /usr/bin/false
/usr/bin/dscl . -create /Users/Guest UserShell /usr/bin/false

# Setup ssh
systemsetup -setremotelogin on
dseditgroup -o create -q com.apple.access_ssh
dseditgroup -o edit -a eccsadmin -t user com.apple.access_ssh
dseditgroup -o edit -a admin -t group com.apple.access_ssh
 
# Display login window as Name and Password.
defaults write "/Library/Preferences/com.apple.loginwindow" SHOWFULLNAME -bool YES

# Hide Bootcamp assistant
/usr/bin/SetFile -a V "/Applications/Utilities/Boot Camp Assistant.app"
 
#Starts the Flurry screensaver over the login window when idle for 120 seconds
defaults write "/Library/Preferences/com.apple.screensaver" loginWindowIdleTime -int 120
defaults write "/Library/Preferences/com.apple.screensaver" loginWindowModulePath "/System/Library/Screen Savers/Flurry.saver"
 
# Use encrypted virtual memory.
defaults write "/Library/Preferences/com.apple.virtualMemory" UseEncryptedSwap -bool Yes

# Disable bluetooth
#defaults write "/Library/Preferences/com.apple.Bluetooth" "ControllerPowerState" -int 0
#killall SIGHUP blued
 
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

# Set network time server to ntp.service.emory.edu
/usr/sbin/systemsetup -setusingnetworktime on -setnetworktimeserver ntp.service.emory.edu
/usr/sbin/systemsetup -settimezone America/New_York
ntpdate -bvs ntp.service.emory.edu
 
# Allows any user to set dvd region
/usr/libexec/PlistBuddy -c "Set :rights:system.device.dvd.setregion.initial:class allow" /etc/authorization

# Allow user to change time zone, as documented: http://support.apple.com/kb/TA23576
/usr/libexec/PlistBuddy -c "Add :rights:system.preferences.dateandtime.changetimezone dict" /etc/authorization
/usr/libexec/PlistBuddy -c "Add :rights:system.preferences.dateandtime.changetimezone:class string allow" /etc/authorization
/usr/libexec/PlistBuddy -c "Add :rights:system.preferences.dateandtime.changetimezone:comment string 'This right is used by DateAndTime preference to allow any user to change the system timezone.'" /etc/authorization
/usr/libexec/PlistBuddy -c "Add :rights:system.preferences.dateandtime.changetimezone:shared bool true" /etc/authorization
 
# Enable firewall
defaults write "/Library/Preferences/Preferences/com.apple.alf" globalstate -int 1
/usr/libexec/ApplicationFirewall/socketfilterfw -k

# Allow admin users to add printers
/usr/sbin/dseditgroup -o edit -a admin -t group _lpadmin

# Energy Saver settings
/usr/bin/pmset -a displaysleep 10 disksleep 10 -b sleep 15 -a womp 1 -c sleep 0

# Delete iMovie (Previous Version) Directory if it exists
rm -R /Applications/iMovie\ \(previous\ version\).localized/

# Kill iCloud assistant
defaults write /System/Library/User\ Template/Non_localized/Library/Preferences/com.apple.SetupAssistant DidSeeCloudSetup -bool TRUE

# Repair permissions
diskutil repairPermissions /

# This message will self destruct now
rm $0