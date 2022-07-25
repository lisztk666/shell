#!/bin/bash
#ping 主機是否存在, 0:正常 1:不正常
#參數區
PINGHOST="192.168.100.8"
HOSTNAME="填入主機名稱"
NOWTIME=$(date +'%Y%m%d-%H:%M:%S')
GOODMSG=("$HOSTNAME主機_$PINGHOST-於$NOWTIME-恢復正常")
ERRORMSG=("$HOSTNAME主機_$PINGHOST-於$NOWTIME-發生故障")
TERRORMSG="/etc/sh/terrormsg.sh"
DAY=1
HOURS=8h
SEC=5s

#正常0 ,不正常1
KEYOK=0

#虛擬機開機準備,休息300s
sleep 300s
echo -e "預設 KEYOK=$KEYOK 正常\n"
while true
do
 if [ $KEYOK == 1 ]
 then
  #進入第2迴圈,除非正常才會跳出到第一迴圈
  while true
  do
   echo "login 2 while"
   sleep 3s
   NOWTIME=$(date +'%Y%m%d-%H:%M:%S')
   GOODMSG=("$HOSTNAME主機_$PINGHOST-於$NOWTIME-恢復正常")
   #ping $PINGHOST -c 1 >>/dev/null && echo "2 ok" || $TERRORMSG $GOODMSG
   ping $PINGHOST -c 1 >>/dev/null && KEYOK=0 || KEYOK=1
   if [ $KEYOK == 0 ]
    then
     echo "logout 2 "
     $TERRORMSG $GOODMSG
     break
    fi
  done
 else
  NOWTIME=$(date +'%Y%m%d-%H:%M:%S')
  ERRORMSG=("$HOSTNAME主機_$PINGHOST-於$NOWTIME-發生故障")
  ping $PINGHOST -c 1 >>/dev/null && echo "ok" || $TERRORMSG $ERRORMSG
  ping $PINGHOST -c 1 >>/dev/null && KEYOK=0 || KEYOK=1
  echo "KEYOK: $KEYOK"
  sleep $SEC
fi
done
