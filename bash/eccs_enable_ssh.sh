#!/bin/sh

# eccs_config_ssh
# Patrick Gallagher
# Created 2/16/2012
# Modified 2/16/2012

## Change Log
# 2/16/2012 - Initial script

# Enable ssh
systemsetup -setremotelogin on

# Create the com.apple.access_ssh group
dseditgroup -o create -q com.apple.access_ssh

# Add the admin group to com.apple.access_ssh
dseditgroup -o edit -a admin -t group com.apple.access_ssh