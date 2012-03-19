#!/bin/sh

# ECCS firstboot.sh script for InstaDMG
# Created 11/11/2010
# Modified 12/2/2010
 
defaults="/usr/bin/defaults"
PlistBuddy="/usr/libexec/PlistBuddy"
 
# Declare directory variables.
 
PKG_DIR="$1/Contents/Resources"
SCRIPTS_DIR="$3/Library/Scripts/CompanyName"
LAUNCHD_DIR="$3/Library/LaunchDaemons"
PRIVETC_DIR="$3/private/etc"
PREFS_DIR="$3/Library/Preferences"
USERPREFS_DIR="$3/System/Library/User Template/English.lproj/Library/Preferences"
NONLOC_USERPREFS_DIR="$3/System/Library/User Template/Non_localized/Library/Preferences"
ROOT="$3/"
UPDATE_DYLD="$3/usr/bin/update_dyld_shared_cache" # Set variable to location of update_dyld_shared_cache command on target volume.
 
# These settings can be set on the target volume before startup.
 
# Run update_dyld_shared_cache
$UPDATE_DYLD -universal_boot -root $ROOT

# Changes roots and Guest's shell to /usr/bin/false which disables their ability to login to a shell or GUI
/usr/bin/dscl . -create /Users/root UserShell /usr/bin/false
/usr/bin/dscl . -create /Users/Guest UserShell /usr/bin/false

# Secure SSH
dseditgroup -o create -q com.apple.access_ssh
dseditgroup -o edit -a eccsadmin -t user com.apple.access_ssh
 
# Display login window as Name and Password.
$defaults write "${PREFS_DIR}/com.apple.loginwindow" SHOWFULLNAME -bool YES

# Hide Bootcamp assistant
/usr/bin/SetFile -a V "$3/Applications/Utilities/Boot Camp Assistant.app"
 
#Starts the Flurry screensaver over the login window when idle for 120 seconds
$defaults write "${PREFS_DIR}/com.apple.screensaver" loginWindowIdleTime -int 120
$defaults write "${PREFS_DIR}/com.apple.screensaver" loginWindowModulePath "/System/Library/Screen Savers/Flurry.saver"
 
# Use encrypted virtual memory.
$defaults write "${PREFS_DIR}/com.apple.virtualMemory" UseEncryptedSwap -bool Yes

# Disable bluetooth
#$defaults write "${PREFS_DIR}/com.apple.Bluetooth" "ControllerPowerState" -int 0
#killall SIGHUP blued
 
# Set Safari Preferences.
$defaults write "${USERPREFS_DIR}/com.apple.Safari" HomePage "http://www.emory.edu/"
$defaults write "${USERPREFS_DIR}/com.apple.Safari" ShowStatusBar -bool YES
 
# Set Finder Prefereces.
$defaults write "${USERPREFS_DIR}/com.apple.finder" ShowMountedServersOnDesktop -bool YES
 
# No .ds-store files on Network Shares
$defaults write "${PREFS_DIR}/com.apple.desktopservices" DSDontWriteNetworkStores true
 
# Globally Set Expanded Print dialog Box.
$defaults write "${PREFS_DIR}/.GlobalPreferences" PMPrintingExpandedStateForPrint -bool TRUE
 
# Use short-name for logging into Network Shares
$defaults write "${PREFS_DIR}/com.apple.NetworkAuthorization" UseDefaultName -bool NO
$defaults write "${PREFS_DIR}/com.apple.NetworkAuthorization" UseShortName -bool YES
 
# Set Apple Mouse button 1 to Primary click and button 2 to Secondary click.
$defaults write "${USERPREFS_DIR}/com.apple.driver.AppleHIDMouse" Button1 -integer 1
$defaults write "${USERPREFS_DIR}/com.apple.driver.AppleHIDMouse" Button2 -integer 2

# Turn off backwards mouse scrolling
$defaults write "${USERPREFS_DIR}/.GlobalPreferences" com.apple.swipescrolldirection -bool false
 
# Disable Time Machine Offers.
$defaults write "${PREFS_DIR}/com.apple.TimeMachine" DoNotOfferNewDisksForBackup -bool YES
 
# Disable Time Machine AutoBackup
$defaults write "${PREFS_DIR}/com.apple.TimeMachine" AutoBackup 0

# Set network time server to ntp.service.emory.edu
/usr/sbin/systemsetup -setusingnetworktime on -setnetworktimeserver ntp.service.emory.edu
/usr/sbin/systemsetup -settimezone America/New_York
 
# Allows any user to set dvd region
$PlistBuddy -c "Set :rights:system.device.dvd.setregion.initial:class allow" "$3"/etc/authorization
 
# Firewall Settings
$defaults write "${PREFS_DIR}/Preferences/com.apple.alf" globalstate -int 1

# Allow admin users to add printers
/usr/sbin/dseditgroup -o edit -a admin -t group _lpadmin

# Energy Saver settings
/usr/bin/pmset -a displaysleep 10 disksleep 10 -b sleep 15 -a womp 1 -c sleep 0

# Delete iMovie (Previous Version) Directory if it exists
rm -R /Applications/iMovie\ \(previous\ version\).localized/

# Kill iCloud assistant
defaults write "${USERPREFS_DIR}/com.apple.SetupAssistant" DidSeeCloudSetup -bool true

# Repair permissions
diskutil repairPermissions /

exit 0