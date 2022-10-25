#!/bin/bash
#ping 主機是否存在, 0:正常 1:不正常
#參數區
#PINGHOST="vm_ip"
PINGHOST="192.168.7.191"
#HOSTNAME="客戶名"
HOSTNAME="iphone"
NOWTIME=$(date +'%Y%m%d-%H:%M:%S')
GOODMSG=("$HOSTNAME主機_$PINGHOST-於$NOWTIME-恢復正常")
ERRORMSG=("$HOSTNAME主機_$PINGHOST-於$NOWTIME-發生故障")
TERRORMSG="/etc/sh/terrormsg.sh"
VM=("pve_編號")
QM_ON=("/usr/sbin/qm start $VM")
QM_TIME=0
QM_NTIME=$(date +'%H%M')
QM_RTIME=0630
DAY=1
HOURS=8h
SEC=4s

#正常0 不正常1
KEYOK=0

#虛擬機開機準備
#sleep 300s
sleep 3s
echo -e "預設 KEYOK=$KEYOK 正常\n"
while true
do
 
 #每天固定 QM_RTIME 時間點 重設定 QM_TIME
##############################################
 QM_NTIME=$(date +'%H%M')
 if [ $QM_RTIME == $QM_NTIME ] && [ $QM_TIME > 0  ] 
 then
    #重新設定 QM 啟動次數 
    $QM_TIME=0
 echo "\$QM_TIME=$QM_TIME"
 fi
#############################################


 if [ $KEYOK == 1 ]
 then
  #進入第2迴圈,除非正常才會跳出到第一迴圈
  while true
  do
   echo "login 2 while"
   echo "斷線,進入第2次迴圈"
   sleep 3s
   NOWTIME=$(date +'%Y%m%d-%H:%M:%S')
   GOODMSG=("$HOSTNAME主機_$PINGHOST-於$NOWTIME-恢復正常")

   echo "qm check"
   echo "qm 比對開始"
   QM_STATUS=$(qm list|grep $VM|awk -F" " '{print $3}')
   echo $QM_STATUS
   if [ $KEYOK == 1 ] && [ $QM_STATUS == "stopped" ] && [ $QM_TIME > 0 ]
   then
	 $TERRORMSG "$VM_start"
    echo "qm call start"
    echo $QM_ON
    #啟動次數+1
    (( QM_TIME++ ))
    $QM_ON
    sleep 90s
   else
   #$TERRORMSG "$VM_跳過"
   echo "qm continue"
   #QM_TIME=0
   fi

   ping $PINGHOST -c 1 >>/dev/null && KEYOK=0 || KEYOK=1

   if [ $KEYOK == 0 ]
    then
     echo "logout 2 "
     echo "確認上線脫離2次迴圈 "
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
