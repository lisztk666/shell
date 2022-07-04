#!/bin/bash
#ping 主機是否存在
PINGHOST="填入機器IP"
HOSTNAME="填入主機名稱"
NOWTIME=$(date +'%Y%m%d-%H:%M:%S')
ERRORMSG=("$HOSTNAME主機_$PINGHOST-於$NOWTIME-發生故障")
TERRORMSG="/etc/sh/terrormsg.sh"
DAY=1
HOURS=8h

# 1 正常,0 不正常
KEYOK="1"

#虛擬機開機準備
#sleep 90s
echo -e "預設KEYOK=$KEYOK 正常\n"

while true
do
    if [ $KEYOK != "1" ]
    then
        echo "主機 Ping 不到, $HOURS 後會再測試"
        sleep $HOURS
    else
        echo -e "$KEYOK\n"
        #ping 正常 設定 keyok=1
        ping $PINGHOST -c 1 >/dev/null && KEYOK="1" && echo "PING OK ,等 5 秒"
        ping $PINGHOST -c 1 >/dev/null || $TERRORMSG $ERRORMSG
        sleep 5s
    fi
done
