#!/bin/sh

# Absolute Admin console settings for EC
# Speeds up console for us. 
# Use with caution! There are settings on server that accompany this
# Run when tech is logged in

osascript -e 'tell application "LANrev Admin" to quit'

defaults write com.poleposition-sw.lanrev_admin AutoGenerateInstalledSoftwareStatistics -bool false
defaults write com.poleposition-sw.lanrev_admin AutoGenerateMissingPatchesStatistics -bool false
defaults write com.poleposition-sw.lanrev_admin DatabaseSyncManagerEnable -bool true
defaults write com.poleposition-sw.lanrev_admin SyncLicenseStatusAgentRecords -bool false

exit 0