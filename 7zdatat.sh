#!/bin/bash
#1110525修改
# 請先建立 /etc/sh/list/wnbaklist 檔案 ,並在裡面填入絕對路徑 /sysvol/hs/whan

PATH=$PATH

#set name
MSG="NAME_to_7z"

LOG="/backup/log/`date +%Y%m%d`-data.log"
GLOG="/backup/mis/log/`date +%Y%m%d`-data_good.log"
BLOG="/backup/mis/log/`date +%Y%m%d`-data_error.log"
LOGDAY="`date +%Y%m%d`"
DATEFMT="`date +%Y%m%d"|"%H:%M:%S`"

#SOURCEWHAN="/zsysvol/sysvol/hs/Whan"
#SOURCEWMC="/zsysvol/sysvol/hs/W3000/Wmc/Data"
#SOURCEWCOMM="/zsysvol/sysvol/hs/W3000/comm"
SOURCEWDATA="/zsysvol/sysvol/hs/W3000/data/"

DIRECTORYBAK="/backup/bak/"
DIRECTORYBAKDAY="/backup/bak/hs/`date +%Y%m%d`"
DIRECTORYBAKDAYW3="/backup/bak/hs/`date +%Y%m%d`/w3000/`date +%Y%m%d`"

#check dir and mkdir dir
ls -D "$DIRECTORYBAKDAY"||mkdir -p  "$DIRECTORYBAKDAY/w3000"
#CHECK_FILES=""
CHECK_DIR="/backup/bak/hs/`date +%Y%m%d`/checkdir"

#-------------- wnbaklist 循環開始
BAKFLIST="/etc/sh/list/wnbaklist"
#檢查備分list
if [ ! -f $BAKFLIST ];then
    echo not such "$BAKLIST" error 
    echo not such "$BAKLIST" error >>"$LOG"
    sleep 3s
    continue
fi

BAKLIST=$(cat /etc/sh/list/wnbaklist)  
echo "================`hostname`==================">>"$LOG"
#檢查備分路徑
for c in $BAKLIST ;do
    if [ ! -d $c ];then
      echo  "${c###*/}"
      echo "not such Directory $c " 
      echo "not such Directory $c " >>"$LOG" 
      sleep 3s
      continue
    fi

	#7z ${c##*/}
	echo 7z ${c##*/}
	du -sh "$c" >>"$LOG"
	du -sh "$c"
	#echo "7z ${c##*/} start....... "$DATEFMT"" >>"$LOG"
	#echo "7z ${c##*/} start....... "$DATEFMT""
	echo "7z ${c##*/} start....... `date`" >>"$LOG"
	echo "7z ${c##*/} start....... `date`"
	echo "$DIRECTORYBAKDAY"/"$LOGDAY".${c##*/}.7z
    echo nice -n -20 7za a -mx9 "$DIRECTORYBAKDAY"/"$LOGDAY".${c##*/}.7z "$c" 1>>"$GLOG" 2>>"$BLOG"
    nice -n -20 7za a -mx9 "$DIRECTORYBAKDAY"/"$LOGDAY".${c##*/}.7z "$c" 1>>"$GLOG" 2>>"$BLOG"
	du -sh "$DIRECTORYBAKDAY".${c##*/}.7z >>"$LOG"
	#echo "7z ${c##*/} end....... "$DATEFMT"" >>"$LOG"
	#echo "7z ${c##*/} end....... "$DATEFMT""
	echo "7z ${c##*/} end....... `date`" >>"$LOG"
	echo "7z ${c##*/} end....... `date`"
	ls -alh "$DIRECTORYBAKDAY"/"$LOGDAY".${c##*/}.7z >>"$LOG"
	ls -alh "$DIRECTORYBAKDAY"/"$LOGDAY".${c##*/}.7z
	echo  >>"$LOG"
	echo
done

#-------------- wnbaklist 循環開始
sleep 3s
#7z w3000data
if [ ! -D "$SOURCEWDATA" ];then
    echo "not "$SOURCEWDATA" such Directory $c " 
    echo "not "$SOURCEWDATA" such Directory $c " >>"$LOG" 
    unix2dos "$LOG"
    exit 1
fi

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

