#!/bin/bash
set -euo pipefail

# 1. 取得系統總記憶體 (Byte)
MEM=$(free -b | awk '/^Mem:/ {print $2}')

# 2. 計算 ARC 限制大小 (預設為總記憶體的 50%)
MEM_MAX=$(($MEM / 2))

# 3. 建議將 MIN 設為 MAX 的一半（或 1/4），保留 ARC 動態調整快取的彈性
# 若設為 MAX - 1 會強迫 ARC 幾乎無法根據系統其他程序需求進行釋放
MEM_MIN=$(($MEM_MAX / 2))

echo "設定 ZFS ARC MAX = $MEM_MAX Bytes"
echo "設定 ZFS ARC MIN = $MEM_MIN Bytes"

# 4. 寫入 /etc/modprobe.d/zfs.conf (開機自動套用)
# 注意：原語法 zfs_arc_mix 是致命的拼字錯誤，已修正為 zfs_arc_min
cat <<EOF > /etc/modprobe.d/zfs.conf
options zfs zfs_arc_max=$MEM_MAX
options zfs zfs_arc_min=$MEM_MIN
EOF

# 5. 即時寫入內核參數 (免重開機立刻生效)
if [ -d /sys/module/zfs/parameters ]; then
    echo "$MEM_MAX" > /sys/module/zfs/parameters/zfs_arc_max
    echo "$MEM_MIN" > /sys/module/zfs/parameters/zfs_arc_min
    echo "ZFS ARC 參數已成功即時套用！"
else
    echo "警告：ZFS 模組尚未載入，已寫入 zfs.conf，將於下次重開機或載入模組時生效。"
fi
