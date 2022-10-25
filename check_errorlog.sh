#!/bin/bash
PATH="$PATH"

LOG="/backup/log/`date +%Y%m%d`.log"

DIRLOG="/backup/mis/log/"
HGLOG="/backup/mis/log/`date +%Y%m%d`_hs_good.log"
HBLOG="/backup/mis/log/`date +%Y%m%d`_hs_error.log"
SGLOG="/backup/mis/log/`date +%Y%m%d`_share_good.log"
SBLOG="/backup/mis/log/`date +%Y%m%d`_share_error.log"

LOGDAY="`date +%Y%m%d`"
NOWTIME="date"
DATEFMT="%Y/%m/%d-%R"
DATFEMT_WEEK="week_`date +%u`"

SERVERN="客戶名_IP"
CMSG="客戶名_week_`date +%u`"
EMSG="EnglishName_Backup_week_`date +%u`"
AMSG="客戶名_EnglishName_Backup_week_`date +%u`"

SOURCE="/sysvol"
SOURCEHS="/sysvol/hs"
SOURCESHARE="/sysvol/share"
#DIRECTORY="/backup/daily/"
DIRECTORY_WEEK="/backup/bak/week_`date +%u`/"

SENDMSG="/etc/sh/tsendmsg.sh"
SENDERROR="/etc/sh/terrormsg.sh"

cat $HBLOG|grep -v "=" && $SENDERROR $SERVERN $HBLOG
cat $SBLOG|grep -v "=" && $SENDERROR $SERVERN $SBLOG
