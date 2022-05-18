#!/bin/bash
DATE=`date +%Y%m%d-%H%M`
/usr/sbin/zfs snapshot zsysvol/hs@$DATE
/usr/sbin/zfs snapshot zsysvol/share@$DATE

