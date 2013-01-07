#!/bin/sh

# Delete_MAS_iLife.sh
# Patrick Gallagher
# Emory College of Arts & Sciences

## Purpose
# Delete iLife apps to allow installation of retail versions. 

iMovie="/Applications/iMovie.app"
iPhoto="/Applications/iPhoto.app"
GarageBand="/Applications/GarageBand.app"

if [ -e "${iMovie}/Contents/_MASReceipt" ]; then
	rm -rf "${iMovie}"
	rm -rf "/var/db/receipts/com.apple.pkg.iMovie_AppStore.bom"
	rm -rf "/var/db/receipts/com.apple.pkg.iMovie_AppStore.plist"	
fi

if [ -e "${iPhoto}/Contents/_MASReceipt" ]; then
	rm -rf "${iPhoto}"
	rm -rf "/var/db/receipts/com.apple.pkg.iPhoto_AppStore.bom"
	rm -rf "/var/db/receipts/com.apple.pkg.iPhoto_AppStore.plist"
fi

if [ -e "${GarageBand}/Contents/_MASReceipt" ]; then
	rm -rf "${GarageBand}"
	rm -rf "/Library/Application Support/GarageBand"
	rm -rf "/Library/Audio/Apple Loops"
	rm -rf "/Library/Audio/Apple Loops Index"
	rm -rf "/var/db/receipts/com.apple.pkg.GarageBandBasicContent.bom"
	rm -rf "/var/db/receipts/com.apple.pkg.GarageBandBasicContent.plist"
	rm -rf "/var/db/receipts/com.apple.pkg.GarageBand_AppStore.bom"
	rm -rf "/var/db/receipts/com.apple.pkg.GarageBand_AppStore.plist"
fi

exit 0