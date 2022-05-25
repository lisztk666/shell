#!/bin/bash
PATH=$PATH

#set name
LOG="/backup/log/`date +%Y%m%d`-data.log"
GLOG="/backup/mis/log/`date +%Y%m%d`-data_good.log"
BLOG="/backup/mis/log/`date +%Y%m%d`-data_error.log"
LOGDAY="`date +%Y%m%d`"
DATEFMT="`date +%Y%m%d"|"%H:%M:%S`"

MSG="herong_to_7z"

#SOURCEWHAN="/zsysvol/hs/Whan"
#SOURCEWMC="/zsysvol/hs/W3000/Wmc/Data"
#SOURCEWCOMM="/zsysvol/hs/W3000/Comm"
#SOURCEWDATA="/zsysvol/hs/W3000/Data/"

SOURCEHS="/zsysvol/hs" #指定hs 放置目錄
SOURCEW3=$(find $SOURCEHS  -type d -iname w3000) #尋找w3000
SOURCEWMC=$(find $SOURCEHS  -type d -iname wmc) #找工商
SOURCEWMCDATA=$(find $SOURCEWMC -type d -iname data) #找工商data
SOURCEWHAN=$(find $SOURCEW3  -type d -iname whan) #找whan
SOURCEWCOMM=$(find $SOURCEW3  -type d -iname comm) #找w3000/comm
SOURCEWDATA=$(find $SOURCEW3  -type d -iname data|grep -iv wmc)/ #找w3000/data

echo 
echo -e "\e[32;44m目錄位置\e[0m"
echo "Data:= $SOURCEHS" 
echo "W3000:= $SOURCEW3"
echo "WMC:= $SOURCEWMC" 
echo "Wmc_data:= $SOURCEWMCDATA" 
echo "Whn:= $SOURCEWHAN" 
echo "Custumer_data:= $SOURCEWCOMM" 
echo "W3000_data:= $SOURCEWDATA" 
echo 
echo -e "\e[32;44m目錄位置\e[0m" >>$LOG
echo "Data:= $SOURCEHS" >>$LOG
echo "W3000:= $SOURCEW3" >>$LOG
echo "WMC:= $SOURCEWMC" >>$LOG
echo "Wmc_data:= $SOURCEWMCDATA" >>$LOG
echo "Whn:= $SOURCEWHAN" >>$LOG
echo "Custumer_Data:= $SOURCEWCOMM" >>$LOG
echo "W3000_Data:= $SOURCEWDATA" >>$LOG


DIRECTORYBAK="/backup/bak/"
DIRECTORYBAKDAY="/backup/bak/hs/`date +%Y%m%d`"

#check dir and mkdir dir
ls -D "$DIRECTORYBAKDAY"||mkdir -p "$DIRECTORYBAKDAY"
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
nice -n -20 7za a -mx9 "$DIRECTORYBAKDAY".whan.7z   "$SOURCEWHAN" 1>>"$GLOG" 2>>"$BLOG"
du -sh "$DIRECTORYBAKDAY".whan.7z >>"$LOG"
#echo "7z whan end....... "$DATEFMT"" >>"$LOG"
#echo "7z whan end....... "$DATEFMT"" 
echo "7z whan end....... `date`" >>"$LOG"
echo "7z whan end....... `date`" 
ls -alh "$DIRECTORYBAKDAY".whan.7z >>"$LOG"
ls -alh "$DIRECTORYBAKDAY".whan.7z 
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
nice -n -20 7za a -mx9 "$DIRECTORYBAKDAY".wcomm.7z   "$SOURCEWCOMM" 1>>"$GLOG" 2>>"$BLOG"
du -sh "$DIRECTORYBAKDAY".wcomm.7z >>"$LOG"
#echo "7z comm end....... "$DATEFMT"" >>"$LOG"
#echo "7z comm end....... "$DATEFMT"" 
echo "7z comm end....... `date`" >>"$LOG"
echo "7z comm end....... `date`" 
ls -alh "$DIRECTORYBAKDAY".wcomm.7z >>"$LOG"
ls -alh "$DIRECTORYBAKDAY".wcomm.7z 
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
nice -n -20 7za a -mx9 "$DIRECTORYBAKDAY".wmc.7z   "$SOURCEWMC" 1>>"$GLOG" 2>>"$BLOG"
du -sh "$DIRECTORYBAKDAY".wmc.7z >>"$LOG"
#echo "7z wmc end....... "$DATEFMT"" >>"$LOG"
#echo "7z wmc end....... "$DATEFMT"" 
echo "7z wmc end....... `date`" >>"$LOG"
echo "7z wmc end....... `date`" 
ls -alh "$DIRECTORYBAKDAY".wmc.7z >>"$LOG"
ls -alh "$DIRECTORYBAKDAY".wmc.7z 
echo  >>"$LOG"
echo   


#7z w3000data
ls "$SOURCEWDATA" -D >"$CHECK_DIR"
sleep 30
#cat "$CHECK_DIR"
echo ""共"  `cat $CHECK_DIR|wc -l` "目錄""
echo ""共"  `cat $CHECK_DIR|wc -l` "目錄"">>"$LOG"
#echo "7z w3000 start....... "$DATEFMT"" 
#echo "7z w3000 start....... "$DATEFMT"" >>"$LOG"
echo "7z w3000 start....... `date`" 
echo "7z w3000 start....... `date`" >>"$LOG"

for X in  `cat $CHECK_DIR` ;do
	#echo nice -n -20 7za a -mx9 "$DIRECTORYBAKDAY"/"$LOGDAY"-"$X".7z "$SOURCEWDATA""$X"
	nice -n -20 7za a -mx9 "$DIRECTORYBAKDAY"/"$LOGDAY"-"$X".7z "$SOURCEWDATA""$X" '-xr!*.jpg'
	#clear
done
echo
echo "壓縮後共" `ls $DIRECTORYBAKDAY|grep ".7z"|wc -l` "檔案"
echo "壓縮後共" `ls $DIRECTORYBAKDAY|grep ".7z"|wc -l` "檔案">>"$LOG"
#echo "compress `ls $DIRECTORYBAKDAY/*.7z|wc -l`  files">>"$LOG"
echo
#echo "7z w3000 end  ....... "$DATEFMT"" 
#echo "7z w3000 end  ....... "$DATEFMT"" >>"$LOG"
echo "7z w3000 end  ....... `date`" 
echo "7z w3000 end  ....... `date`" >>"$LOG"
echo  >>"$LOG"
unix2dos "$LOG"


#!/bin/bash
