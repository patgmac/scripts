#!/bin/sh

# check_for_f5_plugin.sh

if [ -e /Library/Internet\ Plug-Ins/F5\ SSL\ VPN\ Plugin.plugin ]; then
	defaults read /Library/Internet\ Plug-Ins/F5\ SSL\ VPN\ Plugin.plugin/Contents/Info CFBundleVersion
else
	echo "F5 Plugin not installed"
fi
exit 0