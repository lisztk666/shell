#!/bin/bash 
#1150424 偵測溫度,sensors 需自行調整
CNAME="客戶名"
SENDMSG="/etc/sh/terrormsg.sh"

CPUTEMP="$(sensors | grep -E 'Core 0|Package id 0|Tctl|Tdie'|sed s/+//|awk -F"." '{print $1}'|awk -F" " '{print $2}')"
#GPUTEMP="$(sensors|grep GPU -n1|grep temp|awk -F" " '{print $2}'|sed  s/^\+//g|awk -F"." '{print $1 }')"

#上限
CPUMAX="95"
GPUMAX="80"

#if [ $CPUTEMP -ge $CPUMAX ] || [ $GPUTEMP -ge $GPUMAX  ]
if [ "$CPUTEMP" -ge "$CPUMAX" ] 
then
    echo "temp too hot"
    ERRORMSG="$CNAME :=
    "$(date '+%Y-%m-%d %H:%M:%S')" CPU:=現在溫度:"$CPUTEMP"  上限溫度:"$CPUMAX"

#    "$(date '+%Y-%m-%d %H:%M:%S')" GPU:=現在溫度:"$GPUTEMP"  上限溫度:"$GPUMAX"

    "$SENDMSG" "$ERRORMSG"
else
    echo $(date '+%Y-%m-%d %H:%M:%S') - coretemp is normal"
 fi

#
