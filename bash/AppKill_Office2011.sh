#!/bin/bash

###########################################################################
# AppKill.sh v1.0                                                         #
#                                                                         #
# DISCLAIMER: This script is offered on a strictly "as is" basis without  #
# any warranty, expressed or implied. Use of this script is at your own   #
# risk. LANrev is not responsible for and cannot be held accountable for  #
# any direct, indirect, incidental or consequential damages that may      #
# result from its use.                                                    #
###########################################################################

# Increase APPROVALTIME (in minutes) to give enduser more time to save changes to 
# open documents. Set TIMER to NO to wait virtually forever.
###########################################################################
APPROVALTIME=5

MSGTIME=$((60 * $APPROVALTIME))

TIMER=YES

# Edit messages to reference application or application suite to be updated
###########################################################################
MESSAGETIMER="============ WARNING ============ All Microsoft Office 2011 applications and web browsers will automatically be closed in $APPROVALTIME minutes so that they can be updated.  Click OK to close all open Office applications and begin now."

MESSAGE="============ WARNING ============ All Microsoft Office 2011 applications and web browsers will automatically be closed so that they can be updated. Click OK to close all open Office applications and begin now."

LOGGEDINUSER=`who | grep console | wc -l | cut -c 8`

if [ $LOGGEDINUSER = "0" ] ; then
	exit
else
	if [ $TIMER = "YES" ] ; then
		osascript <<-__AS__
			tell application "Finder" to activate
			with timeout of $MSGTIME seconds
				tell application "Finder"
					display dialog "$MESSAGETIMER" giving up after $MSGTIME buttons {"OK"}
				end tell
			end timeout
		__AS__
	else
		osascript <<-__AS__
			tell application "Finder" to activate
			with timeout of 8947848 seconds
				tell application "Finder"
					display dialog "$MESSAGE" buttons {"OK"}
				end tell
			end timeout
		__AS__
	fi
fi

function AppKill()
{
CURRENTUSER=`whoami`
PCOUNT=`ps -u $CURRENTUSER | grep "$1" | wc -l`
if [ "$PCOUNT" -eq "1" ] ; then
	echo "Application $1 not open."
else
	killall "$1"
	echo "Closing application $1."
fi
}

# Add entries for any applications you would like to terminate
###########################################################################
AppKill "Microsoft Word"
AppKill "Microsoft Excel"
AppKill "Microsoft PowerPoint"
AppKill "Microsoft Entourage"
AppKill "Firefox"
AppKill "Safari"
AppKill "Google Chrome"
AppKill "Opera"
