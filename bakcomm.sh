export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# ===== 嚴格模式（一定要）=====
set -o errexit
set -o pipefail
set -o nounset

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
#cd /etc/sh
source "/etc/sh/common.sh"

# ===== 錯誤處理 =====
error_handler() {
    local exit_code=$?
    local line_no=$1
    local cmd="$BASH_COMMAND"
    local mail="liszt@ui.idv.tw"


    local host
    host="$(hostname)_至信"

    local subject="[FAIL] Backup Script Error on $host"

    local body

    terrormsg "$subject"
    body=$(cat <<EOF

    "
🚨 Backup Script 發生錯誤

主機: $host
時間: $(date)
錯誤碼: $exit_code
錯誤行數: $line_no
錯誤指令: $cmd

===== 最近 FAIL LOG =====
$(tail -n 50 "$FAIL_LOG" 2>/dev/null)

===== 最近 SUCCESS LOG =====
$(tail -n 20 "$SUCCESS_LOG" 2>/dev/null)

EOF
)

    # 📩 寄信
    echo "$body" | mail -s "$subject" "$mail"
    terrormsg "$body"

    # 寫入 log
    echo "$(date) [SCRIPT FAIL] line:$line_no code:$exit_code cmd:$cmd" | tee -a "$FAIL_LOG"
}

# ===== 綁定 trap =====
trap 'error_handler $LINENO' ERR


#開始執行
print_system_header


# 原版備份
#backup_rsync "/data/projectA" "/backup/projectA"
#backup_rsync "/zsysvol/scan" "/zsysvol/backup/bak-scan"

#快照範例
#zsnapshot "zsysvol/backup"
#/etc/sh/zfsmaxdel.sh zsysvol/software 180

# 旋轉備份，保留 5 份，自訂排除
#backup_rsync_rotate "/home/user/docs" "/backup/docs" 5 "*.bak" "temp/"
#backup_rsync_rotate "/zsysvol/scan" "/zsysvol/rotate/" 7

check_all_disks
check_ups

#結尾執行
print_system_footer
