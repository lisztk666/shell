#!/bin/bash
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

# 參數檢查
if [ -z "$1" ]; then
    echo "錯誤：請指定 ZFS Dataset/Pool (例如: zpool1/zbak1)"
    exit 1
fi

PZFSLIST="$1"

# 設定 LOG 路徑
LOG_DIR="/backup/mis/log"
mkdir -p "$LOG_DIR"

LOGDAY="$(date +%Y%m%d)"
ZFSMLOG="${LOG_DIR}/${LOGDAY}_zfsdelmis.log"
ZFSHGLOG="${LOG_DIR}/${LOGDAY}_zfsdel_good.log"
ZFSHBLOG="${LOG_DIR}/${LOGDAY}_zfsdel_error.log"

# 設定快照保留的最大數量
max_snapshots=320

echo "[$(date +'%Y/%m/%d %H:%M:%S')] 開始檢測對象: $PZFSLIST" | tee -a "$ZFSMLOG"

# 檢查 Dataset 是否存在
if ! /usr/sbin/zfs list -H "$PZFSLIST" >/dev/null 2>&1; then
    echo "錯誤: Dataset $PZFSLIST 不存在，終止執行" | tee -a "$ZFSMLOG"
    exit 1
fi

# 獲取實際快照清單 (加上 -H 移除表頭)
snapshot_count=$(/usr/sbin/zfs list -H -t snapshot -r -s creation -o name "$PZFSLIST" | wc -l)
echo "Dataset: $PZFSLIST 目前共有 $snapshot_count 個快照 (預設上限: $max_snapshots)" | tee -a "$ZFSMLOG"

if [ "$snapshot_count" -gt "$max_snapshots" ]; then
    snapshots_to_delete=$((snapshot_count - max_snapshots))
    echo "超過限制，準備刪除最舊的 $snapshots_to_delete 個快照..." | tee -a "$ZFSMLOG"

    # 取得最舊的 $snapshots_to_delete 個快照名稱
    snapshots=$(/usr/sbin/zfs list -H -t snapshot -r -s creation -o name "$PZFSLIST" | head -n "$snapshots_to_delete")

    for snapshot in $snapshots; do
        echo "正在刪除快照: $snapshot" | tee -a "$ZFSMLOG"
        if /usr/sbin/zfs destroy "$snapshot" 2>&1 | tee -a "$ZFSHGLOG"; then
            echo "成功刪除: $snapshot" | tee -a "$ZFSMLOG"
        else
            echo "刪除失敗: $snapshot" | tee -a "$ZFSMLOG" "$ZFSHBLOG"
        fi
    done
else
    echo "快照數量未達上限，無需刪除。" | tee -a "$ZFSMLOG"
fi

echo "--------------------------------------------------" | tee -a "$ZFSMLOG"
