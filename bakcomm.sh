#!//bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
trap 'if [[ $? -ne 0 ]]; then echo "$(date) [SCRIPT FAIL]" | tee -a "$FAIL_LOG"; fi' EXIT

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
