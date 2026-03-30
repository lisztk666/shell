#!/usr/bin/env bash
#搭配 bakcomm.sh 前頭呼叫
set -euo pipefail

# =============================
# 全域設定
# =============================

DATE_STR="$(date +%Y%m%d_%H%M%S)"
ZDATE_STR="$(date +%Y%m%d-%H%M%S)"

REPORT_BASE="/backup/log"
mkdir -p "$REPORT_BASE"

REPORT_FILE="$REPORT_BASE/${DATE_STR}_backup_report.log"

LOG_BASE="/backup/mis/log"
LOG_SINGLE="$LOG_BASE/single"
LOG_ROTATE="$LOG_BASE/rotate"
LOG_SUCCESS="$LOG_BASE/success"
LOG_FAIL="$LOG_BASE/fail"
LOG_ZFS="$LOG_BASE/zfs"

mkdir -p "$LOG_SINGLE" "$LOG_ROTATE" "$LOG_SUCCESS" "$LOG_FAIL" "$LOG_ZFS"

SUCCESS_LOG="$LOG_SUCCESS/${DATE_STR}-backup_success.log"
FAIL_LOG="$LOG_FAIL/${DATE_STR}-backup_fail.log"
ZFS_LOG="$LOG_ZFS/${DATE_STR}-backup_fail.log"


#Telegram var
TOKEN=""
ERROR_TOKEN=""
CHAT_ID=""

#Mail setup
ALERT_EMAIL="user@mail.com"

#容量相關參數
DISK_CRITICAL=98
DISK_WARNING=95
DISK_HAS_CRITICAL=0

#事務所名稱
OFFICENAME="test"

#ups 請先安裝時間+2年
UPSDATE2Y="20260225"

#快照最大數量
MAX_SNAPSHOTS=170

# =============================
# 錯誤處理
# =============================

handle_error() {
    local exit_code=$?
    echo "=== $(date) [SCRIPT FAIL] ===" | tee -a "$FAIL_LOG"
    echo "Exit code: $exit_code" | tee -a "$FAIL_LOG"
    echo "Last command: ${BASH_COMMAND:-未知}" | tee -a "$FAIL_LOG"

    if [[ -n "${log_file:-}" && -f "$log_file" ]]; then
        echo "錯誤詳情（最後20行）:" | tee -a "$FAIL_LOG"
        tail -20 "$log_file" | tee -a "$FAIL_LOG"
    fi

    echo "=============================" | tee -a "$FAIL_LOG"
    exit "$exit_code"
}

trap 'handle_error' ERR INT TERM

# =============================
# 工具函式
# =============================

#zsnapshot

zsnapshot(){
    local dataset="$1"
        
    local good_log
    local bad_log
    local zsnapset="${dataset}@${ZDATE_STR}"

    if /usr/sbin/zfs snapshot "${zsnapset}"|tee -a "${ZFS_LOG}" ;then
        echo "$(date) [zsnapshot-SUCCESS] ${zsnapset}"|tee -a "$SUCCESS_LOG"
    else
        echo "$(date) [zsnapshot-FAIL]    ${zsnapset}"|tee -a "$FAIL_LOG"
        echo -e "\n" >>"$FAIL_LOG"
        return 1
    fi
}

#發警告信
send_critical_alert() {

    local message="$1"

    # 寫入 syslog
    logger -p user.crit -t backup-script "$message"

    # 寄信（需要系統有 mail 或 mailx）
    if command -v mail >/dev/null 2>&1; then
        echo "$message" | mail -s "[CRITICAL] Backup Disk Alert on $OFFICENAME" "$ALERT_EMAIL"
    fi
}

#發正常通知信
send_mail(){
    mutt -s "$OFFICENAME" liszt@ui.idv.tw <"$REPORT_FILE"
}

tsendmsg() {
# 1110513用法 ./tsendmsg text
    local message="$1"
    local FilePath="$2"

    if [ -z "$message" ]; then
      echo No argument given
      return 1
    fi
    
    #$TOKEN
    local CMD1="https://api.telegram.org/bot$TOKEN/sendMessage"
    local CMD2="https://api.telegram.org/bot$TOKEN/sendDocument"

    curl -s -X POST "$CMD1" \
         -d chat_id="$CHAT_ID" \
         -d text="$message" \
         -d parse_mode="MarkdownV2" \
         >/dev/null 2>&1

    if [ -n "$FilePath" ]; then
      curl "$CMD2" -F chat_id="$CHAT_ID" -F document=@"$FilePath" >/dev/null 2>&1
    fi
}    

tsenderror() {
# 1110513用法 ./tsenderror text
    local message="$1"
    local FilePath="$2"

    if [ -z "$message" ]; then
      echo No argument given
      return 1
    fi

    #$ERRROR_TOKEN
    local CMD1="https://api.telegram.org/bot$ERROR_TOKEN/sendMessage"
    local CMD2="https://api.telegram.org/bot$ERROR_TOKEN/sendDocument"

    curl -s -X POST "$CMD1" \
         -d chat_id="$CHAT_ID" \
         -d text="$message" \
         -d parse_mode="MarkdownV2" \
         >/dev/null 2>&1

    if [ -n "$FilePath" ]; then
      curl "$CMD2" -F chat_id="$CHAT_ID" -F document=@"$FilePath" >/dev/null 2>&1
    fi
}

write_crontab_to_report() {

    echo "================ Crontab 設定 =================" | tee -a "$REPORT_FILE"

    if crontab -l >/dev/null 2>&1; then
        crontab -l | tee -a "$REPORT_FILE"
    else
        echo "(目前使用者沒有 crontab 設定)" | tee -a "$REPORT_FILE"
    fi

    echo "================================================" | tee -a "$REPORT_FILE"
    echo | tee -a "$REPORT_FILE"
}

sanitize_filename() {
    local name="$1"
    basename "$name" \
        | sed 's/[^a-zA-Z0-9._-]/_/g' \
        | sed 's/__*/_/g' \
        | sed 's/^_//; s/_$//'
}
get_log_filename() {
    local mode="$1"   # single 或 rotate
    local src="$2"
    local dst="$3"

    local dir
    [[ "$mode" == "rotate" ]] && dir="$LOG_ROTATE" || dir="$LOG_SINGLE"

    local src_name
    local dst_name

    src_name=$(sanitize_filename "$src")
    dst_name=$(sanitize_filename "$dst")

    echo "$dir/${DATE_STR}_${src_name}_${dst_name}.log"
}

get_Glog_filename() {
    local mode="$1"
    local src="$2"
    local dst="$3"

    local dir
    [[ "$mode" == "rotate" ]] && dir="$LOG_ROTATE" || dir="$LOG_SINGLE"

    local src_name
    local dst_name

    src_name=$(sanitize_filename "$src")
    dst_name=$(sanitize_filename "$dst")

    echo "$dir/${DATE_STR}_${src_name}_${dst_name}_good.log"
}

get_Blog_filename() {
    local mode="$1"
    local src="$2"
    local dst="$3"

    local dir
    [[ "$mode" == "rotate" ]] && dir="$LOG_ROTATE" || dir="$LOG_SINGLE"

    local src_name
    local dst_name

    src_name=$(sanitize_filename "$src")
    dst_name=$(sanitize_filename "$dst")

    echo "$dir/${DATE_STR}_${src_name}_${dst_name}_error.log"
}

print_system_header() {
    local host ip kernel disk

    host="$(hostname)"
    ip="$(hostname -I | awk '{print $1}')"
    kernel="$(uname -r)"
    disk="$(df -h / | awk 'NR==2 {print $5 " used (" $3 "/" $2 ")"}')"

    {
        echo "=============================================================="
        echo "Host      : $host"
        echo "IP        : $ip"
        echo "Kernel    : $kernel"
        echo "Disk Root : $disk"
        echo "Start Time: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "=============================================================="
        echo
    } | tee -a "$REPORT_FILE"
}

#corntab
write_crontab_to_report() {

    echo "================ Crontab 設定 =================" | tee -a "$REPORT_FILE"

    if crontab -l >/dev/null 2>&1; then
        crontab -l | tee -a "$REPORT_FILE"
    else
        echo "(目前使用者沒有 crontab 設定)" | tee -a "$REPORT_FILE"
    fi

    echo "================================================" | tee -a "$REPORT_FILE"
    echo | tee -a "$REPORT_FILE"
}

#cron.d/
write_cron_d_to_report() {

    echo "================ /etc/cron.d 設定 ================" | tee -a "$REPORT_FILE"

    if compgen -G "/etc/cron.d/*" > /dev/null; then

        for file in /etc/cron.d/*; do
            [[ -f "$file" ]] || continue

            echo "----- $(basename "$file") -----" | tee -a "$REPORT_FILE"
            cat "$file" | tee -a "$REPORT_FILE"
            echo | tee -a "$REPORT_FILE"
        done

    else
        echo "(沒有 /etc/cron.d 設定檔)" | tee -a "$REPORT_FILE"
    fi

    echo "====================================================" | tee -a "$REPORT_FILE"
    echo | tee -a "$REPORT_FILE"
}

print_system_footer() {
    {
        write_crontab_to_report 
        write_cron_d_to_report 
        echo "================================================" 
        echo "=============================================================="
        echo "End Time  : $(date '+%Y-%m-%d %H:%M:%S')"
        echo "=============================================================="
    } | tee -a "$REPORT_FILE"
    tsendmsg "$OFFICENAME" "$REPORT_FILE"
    send_mail
}

check_disk_usage() {
    local path="$1"
    local label="$2"

    # 取得磁碟資訊
    local df_line
    df_line=$(df -hP "$path" 2>/dev/null | awk 'NR==2')

    if [[ -z "$df_line" ]]; then
        echo "$label: 無法取得磁碟資訊" | tee -a "$REPORT_FILE"
        return
    fi

    local size used avail percent
    size=$(echo "$df_line" | awk '{print $2}')
    used=$(echo "$df_line" | awk '{print $3}')
    avail=$(echo "$df_line" | awk '{print $4}')
    percent=$(echo "$df_line" | awk '{print $5}' | tr -d '%')

    percent=${percent:-0}

    local warning=""
    if (( percent >= 98 )); then
        warning=" ⚠ WARNING: 磁碟使用率過高"
    fi

    echo "$label: $used / $size (${percent}%)${warning}" \
        | tee -a "$REPORT_FILE"
}


#企業級磁碟檢查 Function
check_all_disks() {

    echo | tee -a "$REPORT_FILE"
    echo "================ 磁碟健康檢查 ================" | tee -a "$REPORT_FILE"

    df -hP | awk 'NR>1' | while read -r fs size used avail percent mount; do

        percent_num=$(echo "$percent" | tr -d '%')
        percent_num=${percent_num:-0}

        status="OK"
        mark="🔵"

        if (( percent_num >= DISK_CRITICAL )); then
            status="CRITICAL"
            mark="🔴"
            DISK_HAS_CRITICAL=1
        elif (( percent_num >= DISK_WARNING )); then
            status="WARNING"
            mark="🟡"
        fi

        printf "%-20s %8s / %-8s (%3s%%)  %s %s\n" \
            "$mount" "$used" "$size" "$percent_num" "$mark" "$status" \
            | tee -a "$REPORT_FILE"

    done

    echo "================================================" | tee -a "$REPORT_FILE"
    echo | tee -a "$REPORT_FILE"
}

#查特定硬碟
check_backup_destination_disk() {

    local original_path="$1"
    local mount_point
    local source_device

    # 解析真正的 mount point
    mount_point=$(findmnt -no TARGET --target "$original_path" 2>/dev/null)
    source_device=$(findmnt -no SOURCE --target "$original_path" 2>/dev/null)

    if [[ -z "$mount_point" ]]; then
        echo "❌ 無法解析 mount point: $original_path" | tee -a "$REPORT_FILE"
        return 1
    fi

    echo "================ 目的磁碟健康檢查 ================" | tee -a "$REPORT_FILE"
    echo "目標路徑 : $original_path" | tee -a "$REPORT_FILE"
    echo "掛載點   : $mount_point" | tee -a "$REPORT_FILE"
    echo "來源裝置 : $source_device" | tee -a "$REPORT_FILE"
    echo | tee -a "$REPORT_FILE"

    # 取得使用率（數字）
    local percent
    percent=$(df -P "$mount_point" | awk 'NR==2 {gsub("%","",$5); print $5}')
    percent=${percent:-0}

    local status="OK"
    local mark="🔵"

    if (( percent >= DISK_CRITICAL )); then
        status="CRITICAL"
        mark="🔴"
    elif (( percent >= DISK_WARNING )); then
        status="WARNING"
        mark="🟡"
    fi

    printf "使用率   : (%3s%%)  %s %s\n" \
        "$percent" "$mark" "$status" \
        | tee -a "$REPORT_FILE"

    echo | tee -a "$REPORT_FILE"
    echo "------ df -h 詳細資訊 ------" | tee -a "$REPORT_FILE"
    df -h "$mount_point" | tee -a "$REPORT_FILE"
    echo "--------------------------------" | tee -a "$REPORT_FILE"
    echo | tee -a "$REPORT_FILE"

    # CRITICAL → 停止 + 通知
    if (( percent >= DISK_CRITICAL )); then

        local msg="🔴 <b>CRITICAL Disk Alert</b>
    Host: $HOSTNAME
    Path: $dst_path
    Usage: ${percent}%
    Time: $(date '+%Y-%m-%d %H:%M:%S')"

        logger -p user.crit -t backup-script "$msg"

        if command -v mail >/dev/null 2>&1; then
            echo "$msg" | mail -s "[CRITICAL] Backup Disk Alert on $HOSTNAME" "$ALERT_EMAIL"
        fi

        send_telegram_alert "$msg"

        return 1
    fi
}

#給 check_backup_destination_disk() 使用
send_telegram_alert() {

    local message="$1"

    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
        -d chat_id="${CHAT_ID}" \
        -d text="$message" \
        -d parse_mode="HTML" \
        >/dev/null 2>&1 || true
}

#檢查ups
check_ups() {
    if [ "$UPSDATE2Y" -lt $(date +%Y%m%d) ];then
    echo "************* 警告 UPS 已到期請更換 ************" | tee -a "$REPORT_FILE"  
    echo "************* 警告 UPS 已到期請更換 ************" | tee -a "$REPORT_FILE"  
    echo "************* 警告 UPS 已到期請更換 ************" | tee -a "$REPORT_FILE"  
    echo "************* 警告 UPS 已到期請更換 ************" | tee -a "$REPORT_FILE"  
    echo "************* 警告 UPS 已到期請更換 ************" | tee -a "$REPORT_FILE"  
    fi

    /usr/sbin/apcaccess | tee -a "$REPORT_FILE"
    echo -e "\n" >> "$REPORT_FILE"
    return 0 
}

# =============================
# RSYNC 執行核心-START
run_rsync() {
    # 檢查目的磁碟
    if ! check_backup_destination_disk "$dst"; then
        echo "🔴 目的磁碟空間不足，停止備份！" | tee -a "$REPORT_FILE"
#        return 1
    fi

    local src="$1"
    local dst="$2"
    local good_log="$3"
    local bad_log="$4"
    shift 4
    local custom_excludes=("$@")

    local start_time
    start_time="$(date '+%Y-%m-%d %H:%M:%S')"

    mkdir -p "$dst"

    # -------------------------
    # rsync 參數
    # -------------------------
    local -a rsync_opts
    rsync_opts=(
        -a
        -h
        -v
        --delete
        --delete-excluded
        --stats
        --itemize-changes
        --exclude-from=/etc/sh/list/exlist
    )

    for pattern in "${custom_excludes[@]}"; do
        rsync_opts+=("--exclude=$pattern")
    done

    echo "=== $(date) RSYNC START ===" | tee -a "$log_file"

    # -------------------------
    # 執行 rsync
    # -------------------------
#    check_all_disks

    # 若有 CRITICAL 直接停止
#    if (( DISK_HAS_CRITICAL == 1 )); then
#        echo "🔴 發現磁碟 CRITICAL，停止備份！" | tee -a "$REPORT_FILE"
#        return 1
#    fi
    
    rsync "${rsync_opts[@]}" "${src%/}/" "${dst%/}/" \
        1>>"$good_log" \
        2>>"$bad_log"

    local exit_code=$?

    # -------------------------
    # 統計分析
    # -------------------------
    local added modified deleted transferred

    added=$(grep -c '^>f' "$good_log" 2>/dev/null)
    added=${added:-0}

    modified=$(grep -c '^\.f' "$good_log" 2>/dev/null)
    modified=${modified:-0}

    deleted=$(grep -c '^\*deleting' "$good_log" 2>/dev/null)
    deleted=${deleted:-0}

    transferred=$(grep "Total transferred file size:" "$good_log" \
        | awk -F': ' test'{print $2}' | tail -1)
    transferred=${transferred:-0}

    # 真正傳輸檔案數（只算 >f）
    local success_count
    success_count=$(grep '^>f' "$good_log" 2>/dev/null | wc -l)
    success_count=${success_count:-0}

    # stderr 行數
    local fail_count
    #fail_count=$(wc -l < "$bad_log" 2>/dev/null || echo 0)
    fail_count=$(wc -l < "$bad_log" 2>/dev/null)
    fail_count=${fail_count:-0}

    local end_time
    end_time="$(date '+%Y-%m-%d %H:%M:%S')"

    # -------------------------
    # 主 log 摘要
    # -------------------------
    if [[ $exit_code -eq 0 ]]; then
        echo "RSYNC SUCCESS" | tee -a "$log_file"
    else
        echo "RSYNC FAIL (exit=$exit_code)" | tee -a "$log_file"
    fi

    echo "新增: $added" | tee -a "$log_file"
    echo "修改: $modified" | tee -a "$log_file"
    echo "刪除: $deleted" | tee -a "$log_file"
    echo "傳輸大小: $transferred" | tee -a "$log_file"

    echo "----- 變更檔案清單 -----" | tee -a "$log_file"
    grep -E '^>f|^>d|^\.f|^\*deleting' "$good_log" \
        | tee -a "$log_file" || true

    if (( added == 0 && modified == 0 && deleted == 0 )); then
        echo "NO CHANGE" | tee -a "$log_file"
    fi
    echo "-------------------------" | tee -a "$log_file"

    echo "=== $(date) RSYNC END ===" | tee -a "$log_file"

    # -------------------------
    # 寫入整體報表
    # -------------------------
    {
        echo "--------------------------------------------------------------"
        echo "任務: $src -> $dst"
        echo "開始時間: $start_time"

        echo "成功傳輸檔案數: $success_count"
        echo "刪除檔案數    : $deleted"
        echo "錯誤行數      : $fail_count"
        echo "傳輸大小      : $transferred"
        echo "完成時間      : $end_time"
        echo "狀態          : $([[ $exit_code -eq 0 ]] && echo SUCCESS || echo FAIL)"
        echo "--------------------------------------------------------------"
        echo
    } | tee -a "$REPORT_FILE"

    return "$exit_code"
}
# =============================
# =============================
# RSYNC 執行核心--END
# =============================

# =============================
# 單次備份
# =============================

backup_rsync() {

    local src="$1"
    local dst="$2"
    shift 2
    local custom_excludes=("$@")

    local start_time
    start_time="$(date '+%Y-%m-%d %H:%M:%S')"

    echo "--------------------------------------------------------------" | tee -a "$REPORT_FILE"
    echo "任務: $src -> $dst" | tee -a "$REPORT_FILE"
    echo "開始時間: $start_time" | tee -a "$REPORT_FILE"
    echo
    check_disk_usage "$src" "來源磁碟"
    check_disk_usage "$dst" "目的磁碟"
    echo

    log_file=$(get_log_filename "single" "$src" "$dst")

    local good_log
    local bad_log

    good_log=$(get_Glog_filename "single" "$src" "$dst")
    bad_log=$(get_Blog_filename  "single" "$src" "$dst")

    local task_name="Backup $src -> $dst"

    if run_rsync "$src" "$dst" "$good_log" "$bad_log" "${custom_excludes[@]}"; then
        echo "$(date) [SUCCESS] $task_name" | tee -a "$SUCCESS_LOG"
    else
        echo "$(date) [FAIL] $task_name" | tee -a "$FAIL_LOG"
        return 1
    fi
}

# =============================
# Rotate 備份
# =============================
backup_rsync_rotate() {
    local src="$1"
    local dst_base="$2"
    local retain_count="${3:-7}"
    shift 3
    local custom_excludes=("$@")

    local start_time
    start_time="$(date '+%Y-%m-%d %H:%M:%S')"

    echo "--------------------------------------------------------------" | tee -a "$REPORT_FILE"
    echo "任務: $src -> $dst_base" | tee -a "$REPORT_FILE"
    echo "開始時間: $start_time" | tee -a "$REPORT_FILE"

    mkdir -p "$dst_base"

    mapfile -t backups < <(
        find "$dst_base" -maxdepth 1 -mindepth 1 -type d \
        -regextype posix-extended \
        -regex ".*/[0-9]{8}_[0-9]{4}" \
        | sort
    )

    local total=${#backups[@]}
    local timestamp
    timestamp="$(date +%Y%m%d_%H%M)"

    local dst

    if (( total < retain_count )); then
        # 未達上限 → 新增
        echo "# 未達上限 → 新增"
        echo "目前 $total 份，未達上限 ($retain_count)，新增備份" | tee -a "$log_file"
        dst="$dst_base/$timestamp"

    else
        # 已達或超過上限 → 輪替最舊
        echo "# 已達或超過上限 → 輪替最舊"
        local oldest="${backups[0]}"
        echo "已達上限 ($retain_count)，輪替最舊: $oldest" | tee -a "$log_file"

        echo "mv "$oldest" "$dst_base/$timestamp""
        mv "$oldest" "$dst_base/$timestamp"
        #ls -al  "$dst_base/$timestamp"
        dst="$dst_base/$timestamp"
    fi

    # 設定 log
    log_file=$(get_log_filename "rotate" "$src" "$dst_base")
    local good_log
    local bad_log

    good_log=$(get_Glog_filename "rotate" "$src" "$dst_base")
    bad_log=$(get_Blog_filename "rotate" "$src" "$dst_base")

    if run_rsync "$src" "$dst" "$good_log" "$bad_log" "${custom_excludes[@]}"; then
        echo "$(date) [SUCCESS] RotateBackup $src -> $dst" | tee -a "$SUCCESS_LOG"
    else
        echo "$(date) [FAIL] RotateBackup $src -> $dst" | tee -a "$FAIL_LOG"
        return 1
    fi
}

