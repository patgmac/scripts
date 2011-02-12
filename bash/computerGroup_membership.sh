#!/bin/sh

# computerGroup_membership.sh
# Purpose: This script will create a report of which OD computerGroups each machine is a member of

# Set these 2 values
odDomain=ecod.as.emory.edu
outputFile=ComputerMembership.txt

for i in `dscl /LDAPv3/$odDomain -list /Computers`; do
	echo "$i is a member of the following ComputerGroup(s):" >> $outputFile
	groups=`dscl /LDAPv3/$odDomain search /ComputerGroups Member $i | grep Member | cut -f1-1`
	echo "$groups" >> $outputFile
	echo "" >> $outputFile
	#echo $i >> $outputFile
done

exit 0
