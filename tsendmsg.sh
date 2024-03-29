#!/bin/bash
# 1110513用法 ./tsendmsg text
if [ -z "$1" ]; then
  echo No argument given
  exit
fi

TOKEN="MYTOKEN"
CHAT_ID="MYID"
Message=$1
FilePath=$2

CMD1="https://api.telegram.org/bot$TOKEN/sendMessage"
CMD2="https://api.telegram.org/bot$TOKEN/sendDocument"

curl -s -X POST $CMD1 -d chat_id=$CHAT_ID -d text="$Message" >/dev/null 2>&1
#curl -s -X POST $CMD1 -d chat_id=$CHAT_ID -d text="$Message"

if [ -n "$FilePath" ]; then
  curl $CMD2 -F chat_id=$CHAT_ID -F document=@"$FilePath" >/dev/null 2>&1
fi
