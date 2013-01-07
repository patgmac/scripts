include /usr/local/share/luggage/luggage.make
TITLE=EmoryCollegeFirstBootConfig
REVERSE_DOMAIN=edu.emory.eccsPrefs.pkg
PAYLOAD=pack-usr-local-sbin-networkCheckers.py \
pack-script-preflight \
pack-Library-LaunchDaemons-com.afp548.instaDMGd.plist \
pack-Library-LaunchAgents-com.afp548.networkUp.plist \
pack-usr-local-sbin-firstBootPost-Imaging.sh \
pack-user-template-plist-com.apple.dock.plist \
pack-usr-bin-SetFile

# apply Lion-specific perms fix:

modify_packageroot:
	@sudo chgrp wheel ${WORK_D}/Library
	@sudo chmod 755 ${WORK_D}/Library
