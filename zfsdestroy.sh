#!/bin/bash
ZFSDTMP=/tmp/zfsdel.tmp

#if [ $2 -eq 0 ] ;then

# 判斷 變數2是否存在
if [ ! $2 ] ;then
       echo "no env2 "
       exit 1
fi

echo -e "\e[32m$(zfs list -t snapshot |grep $1|grep -v $2|sed 's/^[\t]*//g'|awk -F" " '{print $1}') \e[0m"
echo   "過濾 $1 , 排除 $2"
zfs list -t snapshot |grep $1|grep -v $2|sed 's/^[\t]*//g'|awk -F" " '{print $1}' >$ZFSDTMP
sleep 3s

echo -e "\e[32m 刪除3s後開始\e[0m"
sleep 3s

for x in $(cat $ZFSDTMP)  ;do
	        echo -e "\e[32m zfs destroiy $x \e[0m"
		        zfs destroy $x
		done
