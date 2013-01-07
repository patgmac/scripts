#!/bin/sh

iPhoto="/Applications/iPhoto.app"

if [ -e "${iPhoto}" ]; then

	if [ -e "${iPhoto}/Contents/_MASReceipt" ]; then
		echo "MAS iLife version"
	else
		echo "Retail iLife version"
	fi
fi
exit 0