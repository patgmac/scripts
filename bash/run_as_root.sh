#!/bin/sh
RunAsRoot()
{
    ##  Pass in the full path to the executable as $1
    if [[ "${USER}" != "root" ]] ; then
    	echo
        echo "***  This application must be run as root.  Please authenticate below.  ***"
        echo
        sudo "${1}" && exit 0
    fi
}

RunAsRoot "${0}"
echo "${0}"


#echo "${1}"