#!/bin/bash
MEM=$(free -b|grep Mem|awk -F" " '{print $2}')
MEM_2=$(($MEM/2))
  
#MEM_MAX=$(free -b|grep Mem|awk -F" " '{print $2}')
MEM_MAX=$MEM_2
echo "MEM_MAX"=$MEM_MAX
MEM_MIN=$(($MEM_MAX - 1))
echo "MEM_MIN"=$MEM_MIN
 
echo "options zfs zfs_arc_max=$MEM_MAX">/etc/modprobe.d/zfs.conf
echo "options zfs zfs_arc_mix=$MEM_MIN">>/etc/modprobe.d/zfs.conf
echo "$MEM_MAX" >/sys/module/zfs/parameters/zfs_arc_max
echo "$MEM_MIN" >/sys/module/zfs/parameters/zfs_arc_min
 