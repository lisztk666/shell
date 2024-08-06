#/bin/bash
users=$(pdbedit -L| cut -d: -f1|grep -vw "user")
echo "可刪除使用者:"
echo "$users"
echo
echo
echo
echo
echo
echo
echo
echo
read -p "請輸入刪除用戶名: " user

#lower
user=${user,,}

if  echo "$users"| grep -wq "$user";then
    userdel -r "$user" 2>/dev/null
    pdbedit -x "$user" 
    echo "使用者 $user 已被刪除"
    echo "如不刪除請按0退出"

else
    echo "無效使用者"
fi
