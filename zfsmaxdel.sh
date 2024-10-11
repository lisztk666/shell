#!/bin/bash
PATH="$PATH"

#範例
#$1 請填入 zpool1/zbak1

#設定LOG
ZFSLOG="/backup/log/`date +%Y%m%d`_zfsdel.log"
ZFSMLOG="/backup/mis/log/`date +%Y%m%d`_zfsdelmis.log"
ZFSHGLOG="/backup/mis/log/`date +%Y%m%d`_zfsdel_good.log"
ZFSHBLOG="/backup/mis/log/`date +%Y%m%d`_zfsdel_error.log"

#日期
LOGDAY="`date +%Y%m%d`"
NOWTIME="date"
DATEFMT="%Y/%m/%d-%R"

#要檢測的變數1,沒有就跳開
if [ ! $1 ] ; then
    echo "no env $1"
    exit 1
fi

PZFSLIST=$1

echo "檢測對象:= $PZFSLIST"|tee -a $ZFSMLOG

# 設定快照保留的最大數量
max_snapshots=320

echo "預設保留數量 $max_snapshots"|tee -a $ZFSMLOG


# 獲取所有 ZFS datasets 列表
#datasets=$(zfs list -H -o name |grep -wv -e swap -e cache -e tmp -e vz -e hs-today| grep "zsysovl/" )

#show zpool list
#zplist=$(zpool list -H -o name) 
#zplist_wc=$(zpool list -H -o name|wc -l) 

zplist=$(/usr/sbin/zfs list -H -o name $PZFSLIST) 
zplist_wc=$(/usr/sbin/zfs list -H -o name $PZFSLIST|wc -l) 


#檢查 快照=0 不執行    
if [ $zplist_wc == 0 ] ;then
    echo "zfs list = 0, no run"
    echo "檢測對象變數=0,不往下執行" |tee -a $ZFSMLOG
    exit 1
fi

echo " 顯示檢測對象 zpoollist:= $zplist"
echo " 顯示檢測對象數量 zpoollist wc:= $zplist_wc"

#zfslit 過濾名單
zfslist_grepv="-e swap -e cache -e tmp -e log -e vz -e hs-today"
zfslist_grep=$zplist"/"

echo "過濾對象 zpoollist:= $zfslist_grep"|tee -a $ZFSMLOG

sleep 3s

if  [ $zplist_wc  -gt 1 ];then
    echo " zpool list:= $zplist_wc > 1 不執行 " 
    sleep 3s
    exit
fi

echo "***********************  start ***************************"

#datasets=$(zfs list -H -o name |grep -wv -e swap -e cache -e tmp -e vz -e hs-today -e log |grep zsysvol/ )
#datasets=$(zfs list -H -o name|grep -wv $zfslist_grepv|grep $zfslist_grep |grep zfslist_grep)
datasets=$PZFSLIST

    echo "********************-datasets*****************************"
    echo $datasets

sleep 3s

# 循環每個 dataset，並獲取其快照數量
for dataset in $datasets
do
    #snapshot_count=$(zfs list -t snapshot -r -o name $dataset |grep -wv $zfslist_grepv|grep zfslist_grep )
    snapshot_count=$(zfs list -t snapshot -r -o name $PZFSLIST|wc -l)
    echo "Dataset: $dataset 有 $snapshot_count 個快照"

    # 如果快照數量超過最大限制，則刪除最舊的快照
    if [ $snapshot_count -gt $max_snapshots ]; then
        snapshots_to_delete=$((snapshot_count - max_snapshots))
        echo "需要刪除 $snapshots_to_delete 個最舊的快照..."|tee -a $ZFSMLOG


        # 獲取要刪除的快照列表，並按創建時間排序
		#
        #snapshots=$(zfs list -t snapshot -r -o name,creation -s creation -H $dataset | head -n $snapshots_to_delete | awk '{print $1}')
        snapshots=$(zfs list -t snapshot -r -o name,creation -s creation -H $dataset | head -n $snapshots_to_delete | awk '{print $1}')

        # 刪除快照
        for snapshot in $snapshots
        do
            echo "刪除快照: $snapshot"|tee -a $ZFSMLOG

            zfs destroy $snapshot
        done
    else
        echo "無需刪除快照" |tee -a $ZFSMLOG
    fi
done

echo "--------------------------------------------------"|tee -a $ZFSMLOG


