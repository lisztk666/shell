#sysvol list bak
#!/bin/bash
PATH="$PATH"

#設定LOG
LOG="/backup/log/`date +%Y%m%d`.log"
HGLOG="/backup/mis/log/`date +%Y%m%d`_good.log"
HBLOG="/backup/mis/log/`date +%Y%m%d`_error.log"

#日期
LOGDAY="`date +%Y%m%d`"
TODAY=$LOGDAY
NOWTIME="date"
DATEFMT="%Y/%m/%d-%R"
DATFEMT_WEEK="week_`date +%u`"
DAYSTOKEEP=$(date +%Y%m%d -d '-14 days')

#名稱
CMSG="名字_PVE_smb_week_`date +%u`"
EMSG="NAME_PVE_Backup_week_`date +%u`"
AMSG="名字_NAME_Backup_week_`date +%u`"

#開始掛載
#/etc/sh/umount.sh 1>>$HGLOG 
#/etc/sh/mmount.sh 1>>$HGLOG 2>>$HBLOG

#路徑
SOURCE="/zsysvol"
DIRECTORY_WEEK="/backup/bak/week_`date +%u`/"
#DIRECTORY_KEEPDAY="/backup/bak/$DAYSTOKEEP/"
#DIRECTORY_TODAY="/backup/bak/$TODAY/"
DIRECTORY_KEEP="/backup/4t/$DAYSTOKEEP/"
DIRECTORY_TODAY="/backup/4t/$TODAY/"

#檢查硬碟
/etc/sh/cksize.sh
LIMITDF="94"
CHECKDF=$(df -h|tr -s " "|grep /backup|awk -F" " '{print $5}'|awk -F"%" '{print $1}')
CKBAKDIR="/backup"
echo "$CKBAKDIR"
echo "限制參數 backup=$LIMITDF"
echo "現有空間 backup=$CHECKDF"

if [ ! -d $CKBAKDIR ] ;then
	echo "備分硬碟目錄不存在,跳出" 
        exit 1
elif [ $CHECKDF -ge $LIMITDF ];then
	echo "備份硬碟已趨近95,備分無法執行,不執行備分"
	echo "備份硬碟已趨近95,備分無法執行,不執行備分" >>$LOG
	echo "備份硬碟已趨近95,備分無法執行,不執行備分" >>$LOG
	echo "備份硬碟已趨近95,備分無法執行,不執行備分" >>$LOG
	echo "備份硬碟已趨近95,備分無法執行,不執行備分" >>$LOG
	echo "備份硬碟已趨近95,備分無法執行,不執行備分" >>$LOG
	echo "請找 李:= 0963-362-638" >>$LOG
	echo "或line:= liszt666" >>$LOG
    echo "\t" >>$LOG
	exit 1
else    echo "空間確認完成,執行備分"
fi

#設定UPS參數
UPSDATE2Y="20230901"
UPSTODYA="$(date +%Y%m%d)"
if [ $UPSDATE2Y -lt $(date +%Y%m%d) ];then
    echo "************* 警告 UPS 已到期請更換 ************"
    echo "************* 警告 UPS 已到期請更換 ************" >>"$LOG"
    echo "************* 警告 UPS 已到期請更換 ************" >>"$LOG"
    echo "************* 警告 UPS 已到期請更換 ************" >>"$LOG"
    echo "************* 警告 UPS 已到期請更換 ************" >>"$LOG"
    echo "************* 警告 UPS 已到期請更換 ************" >>"$LOG"
    echo "\t" >>$LOG
fi	

#檢查是否有目錄
echo $DIRECTORY_TODAY
echo $DIRECTORY_KEEP
sleep 3s
if [ ! -d $DIRECTORY_TODAY ] ;then
    echo "移動 $DIRECTORY_KEEP TO $DIRECTORY_TODAY" 
    echo "移動 $DIRECTORY_KEEP TO $DIRECTORY_TODAY" >>"$LOG"
    mv $DIRECTORY_KEEP $DIRECTORY_TODAY  || mkdir $DIRECTORY_TODAY
#else
#    echo "建立 $DIRECTORY_TODAY" 
#    echo "建立 $DIRECTORY_TODAY" >>"$LOG"
#    mkdir $DIRECTORY_TODAY 
fi

sleep 3s

#-------------- baklist 循環開始
BAKLIST=$(cat /etc/sh/list/baklist)
echo "================`hostname`==================">>"$LOG"
for b in $BAKLIST ;do
		
    bGLOG="/backup/mis/log/`date +%Y%m%d`_${b##*/}_good.log"
    bBLOG="/backup/mis/log/`date +%Y%m%d`_${b##*/}_error.log"

    sleep 3s
    echo "================"`date`" - $b-Backup ==================">>"$LOG"
    echo "================"`date`" - $b-Backup ==================">>"$bGLOG"
    echo "================"`date`" - $b-Backup ==================">>"$bBLOG"
    echo "\t" >>$LOG
    echo "*********************************************************************"
    echo "產生 Log 中 ==> $bGLOG"
    echo "產生 Log 中 ==> $bBLOG"

    echo "正在拷貝 $b 到 $DIRECTORY_TODAY${b##*/} -------------------------------------"
    #Backup_start---------------------------------
    echo "`date +"$DATEFMT"` Backup $b-start">>"$LOG"
    
    #rsync  -ahv --delete  --delete-excluded  --exclude-from=/etc/sh/list/exlist  "$b" "$DIRECTORY_WEEK" >>"$bGLOG" 2>>"$bBLOG"
    rsync  -ahv --delete  --delete-excluded  --exclude-from=/etc/sh/list/exlist  "$b" "$DIRECTORY_TODAY" >>"$bGLOG" 2>>"$bBLOG"

    echo "================"`date`" - $b-END ==================">>"$LOG"
    echo "================"`date`" - $b-END ==================">>"$bGLOG"
    echo "================"`date`" - $b-END ==================">>"$bBLOG"
    echo "拷貝成功檔案數目，共有 `cat "$bGLOG" |grep -v CST|wc -l`">>"$LOG"
    echo "問題檔案數目，共有 `cat "$bBLOG" |grep -v CST|wc -l`" >>"$LOG"
    echo "-------------------以下是-$b-有問題檔案------------------">>"$LOG"
    cat "$bBLOG"|grep -v "CST">>"$LOG"
    echo "-------------------END-$b-問題檔案-$b-END------------------">>"$LOG"
    echo "\t" >>$LOG
done

echo "*********************************************************************"
echo "-------------------以下 sysvol 備分完的時間------------------">>"$LOG"
echo "`date +"$DATEFMT"` Backup end">>"$LOG"
    echo "\t" >>$LOG
echo "-------------------以下是檔案容量大小------------------">>"$LOG"
df -h  >>"$LOG"
echo "\t" >>$LOG

echo "-------------------以下是檔案容量大小------------------">>"$LOG"
/usr/sbin/zpool status >>"$LOG"
echo "\t" >>$LOG

echo "-------------------以下是檔案容量大小------------------">>"$LOG"
/usr/sbin/zfs list >>"$LOG"
echo "\t" >>$LOG

echo "-------------------以下是檔案容量大小------------------">>"$LOG"
/usr/sbin/zpool list >>"$LOG"
echo "\t" >>$LOG

echo "-----UPS測試-----">>"$LOG"
/usr/sbin/apcaccess  >>"$LOG"
echo "\t" >>$LOG

echo "-----最近10次重開機-----" >>"$LOG"
last  reboot |tail -10>>"$LOG"
echo "\t" >>$LOG

echo "-----最近10次登入-----" >>"$LOG"
last -n 10 >>"$LOG"
echo "\t" >>$LOG

echo "-----最近10次關機-----" >>"$LOG"
last -x|grep shutdown |tail -10>>"$LOG"
echo "\t" >>$LOG

echo "-----排程-----">>"$LOG"
crontab -l >>"$LOG"
 echo "\t" >>$LOG

echo "排除項目">>"$LOG"
cat /etc/sh/list/exlist >>"$LOG"
echo "\t" >>$LOG
#Backup end-----------------------------------

#unix2dos start-------------------------------
unix2dos "$LOG"
unix2dos "$bGLOG"
unix2dos "$bBLOG"
#unix2dos end---------------------------------

#mail start-----------------------------------
echo "`date +"$DATEFMT"`-"$CMSG""
#echo "`date +"$DATEFMT"`"-"$EMSG""|mail -s "$EMSG" liszt@ui.idv.tw <"$LOG"
#cat "$LOG" |mail -s "$AMSG" liszt@ui.idv.tw
mutt -s "$AMSG" liszt@ui.idv.tw <"$LOG"
#mail end-------------------------------------
#/etc/sh/umount.sh 1>>$HGLOG 2>>$HBLOG
#呼叫快照
#/etc/sh/snapshot.sh 
#檢查容量
/etc/sh/cksize.sh
echo 拷貝完成請查看備份資料-------------------
sleep 10m
