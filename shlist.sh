#/bin/bash
pdbedit -L |awk -F":" '{print $1}'|grep -wv "user"
