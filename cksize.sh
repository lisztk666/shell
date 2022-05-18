#!/bin/sh
df -Th | tail -n +2 | awk '{ print $6 " " $1 }' | while read output;
do
  # 取出使用量（百分比）
  usep=$(echo $output | awk '{ print $1}' | cut -d'%' -f1  )

  # 檔案系統
  partition=$(echo $output | awk '{ print $2 }' )

  # 若用量大於 90% 則用 Email 發出警告訊息
  if [ $usep -ge 95 ]; then
    echo "Running out of space \"$partition ($usep%)\" on $(hostname) as on $(date)" |
      mail -s "Alert: Almost out of disk space $usep%" you@somewhere.com
  fi
done
