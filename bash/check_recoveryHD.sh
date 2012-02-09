#!/bin/sh

reHD=`diskutil list | grep Recovery`
if [  -z "$reHD" ]; then
	echo "No Recovery HD Found"
else echo $reHD
fi
exit 0