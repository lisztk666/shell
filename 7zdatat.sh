#!/bin/bash
#1110508修改
PATH=$PATH

#set name

LOG="/backup/log/`date +%Y%m%d`-data.log"
GLOG="/backup/mis/log/`date +%Y%m%d`-data_good.log"
BLOG="/backup/mis/log/`date +%Y%m%d`-data_error.log"
LOGDAY="`date +%Y%m%d`"
DATEFMT="`date +%Y%m%d"|"%H:%M:%S`"

MSG="hs_to_7z"

SOURCEWHAN="/zsysvol/sysvol/hs/Whan"
SOURCEWMC="/zsysvol/sysvol/hs/W3000/Wmc/Data"
SOURCEWCOMM="/zsysvol/sysvol/hs/W3000/comm"
SOURCEWDATA="/zsysvol/sysvol/hs/W3000/data/"

SOURCETXT="/etc/sh/bak.list"

DIRECTORYBAK="/backup/bak/"
DIRECTORYBAKDAY="/backup/bak/hs/`date +%Y%m%d`"
DIRECTORYBAKDAYW3="/backup/bak/hs/`date +%Y%m%d`/w3000/`date +%Y%m%d`"

#check dir and mkdir dir
#error  ls -D "$DIRECTORYBAKDAY"||mkdir -p "$DIRECTORYBAKDAYW3"
ls -D "$DIRECTORYBAKDAY"||mkdir -p  "$DIRECTORYBAKDAY/w3000"
#CHECK_FILES=""

CHECK_DIR="/backup/bak/hs/`date +%Y%m%d`/checkdir"

#7z whan
echo 7z whan
du -sh "$SOURCEWHAN" >>"$LOG"
du -sh "$SOURCEWHAN"
#echo "7z whan start....... "$DATEFMT"" >>"$LOG"
#echo "7z whan start....... "$DATEFMT""
echo "7z whan start....... `date`" >>"$LOG"
echo "7z whan start....... `date`"
echo "$DIRECTORYBAKDAY"/"$LOGDAY".whan.7z
nice -n -20 7za a -mx9 "$DIRECTORYBAKDAY"/"$LOGDAY".whan.7z   "$SOURCEWHAN" 1>>"$GLOG" 2>>"$BLOG"
du -sh "$DIRECTORYBAKDAY".whan.7z >>"$LOG"
#echo "7z whan end....... "$DATEFMT"" >>"$LOG"
#echo "7z whan end....... "$DATEFMT""
echo "7z whan end....... `date`" >>"$LOG"
echo "7z whan end....... `date`"
ls -alh "$DIRECTORYBAKDAY"/"$LOGDAY".whan.7z >>"$LOG"
ls -alh "$DIRECTORYBAKDAY"/"$LOGDAY".whan.7z
echo  >>"$LOG"
echo

#7z comm
echo 7z comm
du -sh "$SOURCEWCOMM" >>"$LOG"
du -sh "$SOURCEWCOMM"
#echo "7z comm start....... "$DATEFMT""
#echo "7z comm start....... "$DATEFMT"" >>"$LOG"
echo "7z comm start....... `date`"
echo "7z comm start....... `date`" >>"$LOG"
nice -n -20 7za a -mx9 "$DIRECTORYBAKDAY"/"$LOGDAY".wcomm.7z   "$SOURCEWCOMM" 1>>"$GLOG" 2>>"$BLOG"
du -sh "$DIRECTORYBAKDAY"/"$LOGDAY".wcomm.7z >>"$LOG"
#echo "7z comm end....... "$DATEFMT"" >>"$LOG"
#echo "7z comm end....... "$DATEFMT""
echo "7z comm end....... `date`" >>"$LOG"
echo "7z comm end....... `date`"
ls -alh "$DIRECTORYBAKDAY"/"$LOGDAY".wcomm.7z >>"$LOG"
ls -alh "$DIRECTORYBAKDAY"/"$LOGDAY".wcomm.7z
echo  >>"$LOG"
echo

#7z wmc
echo 7z wmc
du -sh "$SOURCEWMC" >>"$LOG"
du -sh "$SOURCEWMC"
#echo "7z wmc start....... "$DATEFMT""
#echo "7z wmc start....... "$DATEFMT"" >>"$LOG"
echo "7z wmc start....... `date`"
echo "7z wmc start....... `date`" >>"$LOG"
nice -n -20 7za a -mx9 "$DIRECTORYBAKDAY"/"$LOGDAY".wmc.7z   "$SOURCEWMC" 1>>"$GLOG" 2>>"$BLOG"
du -sh "$DIRECTORYBAKDAY"/"$LOGDAY".wmc.7z >>"$LOG"
#echo "7z wmc end....... "$DATEFMT"" >>"$LOG"
#echo "7z wmc end....... "$DATEFMT""
echo "7z wmc end....... `date`" >>"$LOG"
echo "7z wmc end....... `date`"
ls -alh "$DIRECTORYBAKDAY"/"$LOGDAY".wmc.7z >>"$LOG"
ls -alh "$DIRECTORYBAKDAY"/"$LOGDAY".wmc.7z
echo  >>"$LOG"
echo

#7z w3000data
ls "$SOURCEWDATA" -D >"$CHECK_DIR"
#sleep 30
#cat "$CHECK_DIR"
echo ""共"  `cat $CHECK_DIR|wc -l` "目錄""
echo ""共"  `cat $CHECK_DIR|wc -l` "目錄"">>"$LOG"
#echo "7z w3000 start....... "$DATEFMT""
#echo "7z w3000 start....... "$DATEFMT"" >>"$LOG"
echo "7z w3000 start....... `date`"
echo "7z w3000 start....... `date`" >>"$LOG"

for X in  `cat $CHECK_DIR` ;do
    #DIRECTORYBAKDAYW3="/backup/bak/hs/`date +%Y%m%d`/w3000/"`date +%Y%m%d`
    nice -n -20 7za a -mx9 "$DIRECTORYBAKDAYW3"-"$X".7z "$SOURCEWDATA""$X"
    #clear
done
echo
echo "壓縮後共" `ls $DIRECTORYBAKDAYW3|grep ".7z"|wc -l` "檔案"
echo "壓縮後共" `ls $DIRECTORYBAKDAYW3|grep ".7z"|wc -l` "檔案">>"$LOG"
#echo "compress `ls $DIRECTORYBAKDAY/*.7z|wc -l`  files">>"$LOG"
echo
#echo "7z w3000 end  ....... "$DATEFMT""
#echo "7z w3000 end  ....... "$DATEFMT"" >>"$LOG"
echo "7z w3000 end  ....... `date`"
echo "7z w3000 end  ....... `date`" >>"$LOG"
echo  >>"$LOG"
unix2dos "$LOG"
