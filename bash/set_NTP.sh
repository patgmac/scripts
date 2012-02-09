#!/bin/sh

osversionlong=`sw_vers -productVersion`
osvers=${osversionlong:3:1}

if [ $osvers -eq 4 ]; then
	/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Support/systemsetup -setnetworktimeserver ntp.service.emory.edu
else if [[ $osvers -eq 5 || 6 ]]; then
	systemsetup -setnetworktimeserver ntp.service.emory.edu
fi
fi
exit 0