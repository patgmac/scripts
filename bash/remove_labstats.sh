#!/bin/sh

launchctl unload /Library/LaunchDaemons/LabStats.plist
launchctl unload /Library/LaunchAgents/LabStats.plist

rm -rf /Applications/LabStats
rm -f /Library/LaunchDaemons/LabStats.plist
rm -f /Library/LaunchAgents/LabStats.plist
rm -rf /Library/Application Support/LabStats