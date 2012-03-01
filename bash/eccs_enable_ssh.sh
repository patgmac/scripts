#!/bin/sh

# eccs_config_ssh
# Patrick Gallagher
# Created 2/16/2012
# Modified 2/16/2012

## Change Log
# 2/16/2012 - Initial script
# 3/1/2012 - Added logic to create ssh group only if it didn't already exist. 

# Enable ssh
systemsetup -setremotelogin on

# Create the com.apple.access_ssh group
sshGroup=`dseditgroup -o checkmember com.apple.access_ssh`
if [[ "$sshGroup" == "Group not found." ]]; then # This is not working yet
	echo "Creating ssh access group"
	dseditgroup -o create -q com.apple.access_ssh
fi

# Add the admin group to com.apple.access_ssh
dseditgroup -o edit -a admin -t group com.apple.access_ssh

exit 0