#!/bin/bash 
#1110513 偵測溫度,sensors 需自行調整
CNAME="客戶名"
SENDMSG="/etc/sh/tsendmsg.sh"
CPUTEMP=$(sensors|grep Package|awk -F" " '{print $4}'|sed s/^\+//g|awk -F"." '{print $1}')
GPUTEMP=$(sensors|grep GPU -n1|grep temp|awk -F" " '{print $2}'|sed  s/^\+//g|awk -F"." '{print $1 }')

#上限
CPUMAX="75"
GPUMAX="80"


if [ $CPUTEMP -ge $CPUMAX ] || [ $GPUTEMP -ge $GPUMAX  ]
then
    echo "temp too hot"
    ERRORMSG="$CNAME :=
    CPU:=現在溫度:$CPUTEMP  上限溫度:$CPUMAX
    GPU:=現在溫度:$GPUTEMP  上限溫度:$GPUMAX

    $SENDMSG "$ERRORMSG"
else
    echo "coretemp is normal"
 fi

#