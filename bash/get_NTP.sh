#!/bin/sh

osversionlong=`sw_vers -productVersion`
osvers=${osversionlong:3:1}

if [ $osvers -eq 4 ]; then
	/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Support/systemsetup -getnetworktimeserver
else if [[ $osvers -eq 5 || 6 ]]; then
	systemsetup -getnetworktimeserver
fi
fi
exit 0


	