#!/bin/bash
#version 1130806
clear
while true;do
echo -e "\033[44m-----------------------------------------------\033[0m"
echo -e "#\e[2;3H 請輸入需要的選項 \t#"
echo -e "#\e[32m 1.新增使用者 \e[0m\t\t#"
echo -e "#\e[33m 2.刪除使用者 \e[0m\t\t#"
echo -e "#\e[32m 3.顯示 user list\e[0m\t#"
#echo -e "#\e[33m 4.?? \e[0m\t\t\t#"
#echo -e "#\e[32m 5.?? \e[0m\t\t\t#"
echo -e "#\e[33m 9.刷新選單 \e[0m\t\t#"
echo -e "#\e[38m 0.跳出選單 \e[0m\t\t#"
echo -e "\033[44m-----------------------------------------------\033[0m"
echo 
echo 
echo 
echo 
echo 
echo 
echo 
echo 
echo 
echo 
echo 

    read -p "請輸入選項 (0-3): " choice

    case $choice in
        1)
            #echo "新增使用者...."
#            /etc/sh/shlist.sh
            /etc/sh/shaddd.sh
            ;;

        2)
#           echo "刪除使用者...."
#           /etc/sh/shlist.sh
            /etc/sh/shddd.sh
            ;;

        3)  
            #echo "以下使用者...."
            echo
            /etc/sh/shlist.sh
            ;;

        9)
            clear
            ;;

        0)  
            echo "退出選單..."
            break
            ;;

        *)
            echo "無效選項"
            ;;

    esac
    echo
done
