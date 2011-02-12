#!/bin/sh

myID=`id -u`
if [ $myID -ge 1000 ]; then
	dscl . read /users/`whoami` PhoneNumber | awk '{print $2}'
fi

exit 0