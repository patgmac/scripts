#!/bin/sh

licFile="/Library/Application Support/Sibelius Software/Sibelius 6/_manuscript/LicenceServerInfo" 

if [ -e "$licFile" ]; then
cat "$licFile" 
fi