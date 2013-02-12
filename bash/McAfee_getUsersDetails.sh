#!/bin/sh

#get users on the machine
getUsersDetails=
count=1
for i in `dscl . list /Users | egrep -v '_|nobody|root|daemon|Guest'` ;
do
    getUsersDetails="${getUsersDetails}User$count="$(dscl . read /Users/${i} RealName RecordName EMailAddress |awk -v ORS=' ' '{print}')
    let count++    
done
echo "$getUsersDetails"

/Library/McAfee/cma/bin/msaconfig -CustomProps1 "$getUsersDetails" 
/Library/McAfee/cma/bin/cmdagent -P
exit 0