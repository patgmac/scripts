#!/bin/sh
# enable_firewall.sh
#
# Patrick Gallagher
# http://macadmincorner.com
 
# Stealth Mode - Set to 0 to disable
# Stealth mode prevents machine from responding to ping requestst
# Be aware that this would prevent tools such as ARD from discovering
# the machine, though bonjour on the same subnet will still work
 
osversionlong=`sw_vers -productVersion`
osvers=${osversionlong:3:1}
 
# Check if this is being run by root
if [ "$(whoami)" != "root" ] ; then
  echo "Must be root to run this command."
  exit 1
fi
 
# Enable firewall for Tiger
if [ $osvers -eq 4 ]; then
	echo "Setting firewall on a ${osversionlong} machine"
	/usr/bin/defaults write /Library/Preferences/com.apple.sharing.firewall state -bool YES
	# UDP, change to 0 to disable
	/usr/bin/defaults write /Library/Preferences/com.apple.sharing.firewall udpenabled  -int 1
	# Stealth, change to 0 to disable
	/usr/bin/defaults write /Library/Preferences/com.apple.sharing.firewall stealthenabled -int 0
	/usr/libexec/FirewallTool
fi
 
# Enable firewall for Leopard or Snow Leopard
if [ $osvers -ge 5 ]; then
	echo "Setting firewall on a ${osversionlong} machine"
	# Globalstate - Set to 0 for off, 1 for on, 2 for "Block all incoming access"
	/usr/bin/defaults write /Library/Preferences/com.apple.alf globalstate -int 1
	/usr/bin/defaults write /Library/Preferences/com.apple.alf stealthenabled -int 0
fi