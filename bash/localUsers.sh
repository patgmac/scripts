users=`dscl . list /users | grep -v _ | grep -v nobody | grep -v daemon | grep -v Guest | grep -v root`

for i in `dscl . list /users | grep -v _ | grep -v nobody | grep -v daemon | grep -v Guest | grep -v root`; 
do uniqueID=`dscl . read /users/$i UniqueID | awk '{print $2}'`
if [ $uniqueID -lt 600 ] && [ $uniqueID -ge 499 ]; then
echo $i
fi
done