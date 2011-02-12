#! /bin/sh

# ECAS_Set_Asset-Tag.sh


defaults write /Library/Preferences/com.apple.RemoteDesktop Text2 "$1"

nvram ASSET="$1"