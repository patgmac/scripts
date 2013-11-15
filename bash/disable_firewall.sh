#!/bin/sh

# disable_firewall.sh

defaults write /Library/Preferences/com.apple.alf globalstate -int 0
launchctl unload /System/Library/LaunchDaemons/com.apple.alf.agent.plist
launchctl load /System/Library/LaunchDaemons/com.apple.alf.agent.plist
