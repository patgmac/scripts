#!/bin/sh
KICKSTRT="/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart"
$KICKSTRT -configure -allowAccessFor -specifiedUsers
sleep 1
$KICKSTRT -activate -configure -users eccsadmin -privs -DeleteFiles -TextMessages -OpenQuitApps -GenerateReports -RestartShutDown -SendFiles -ChangeSettings -access -on -clientopts -setreqperm -reqperm yes -setmenuextra -menuextra yes -restart -agent
