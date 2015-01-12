#!/bin/sh

# eccs_config_ssh
# Patrick Gallagher
# Created 2/16/2012
# Modified 6/17/2014

## Change Log
# 2/16/2012 - Initial script
# 3/1/2012 - Added logic to create ssh group only if it didn't already exist. 
# 3/5/2012 - Fixed logic with help of @gregneagle and @tvsutton
# 3/27/2012 - Changed how ssh is enabled. No longer using deprecated systemsetup. 
# 6/17/2014 - Back to using systemsetup since Mavericks doesn't like plistbuddy. 

# Enable ssh
systemsetup -setremotelogin on
launchctl load -w /System/Library/LaunchDaemons/ssh.plist

# Create the com.apple.access_ssh group
dscl . read /Groups/com.apple.access_ssh > /dev/null 2>&1
if [ "$?" != "0" ]; then
	echo "Creating ssh access group"
	dseditgroup -o create -q com.apple.access_ssh
fi

# Add the admin group to com.apple.access_ssh
dseditgroup -o edit -a admin -t group com.apple.access_ssh

# Add our admin acct to group. This is mainly to remain consistent from what we did the past. 
# Otherwise not needed. 
dseditgroup -o edit -a eccsadmin -t user com.apple.access_ssh

exit 0