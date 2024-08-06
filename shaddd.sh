#!/bin/bash
#version 1130806

read -p "請輸入用戶名:" user
read -s -p "請輸入密碼:" pass

#切換小寫
user=${user,,}

if [ ! -z "$user" ] && [ ! -z "$pass" ];then
    useradd "$user"
    /etc/sh/add_smb_user.sh $user $pass
    echo
    echo
    echo
    echo
    echo
    echo
    echo
fi
