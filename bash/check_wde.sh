#!/bin/sh
count=$(pgpwde --disk-status --disk 0 |grep Disk\ 0 |wc -w) 2> /dev/null
if [  $count == 6 ];
   then
      echo "yes"
else
    echo "no"
fi