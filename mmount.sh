#!/bin/bash
/usr/bin/mount --bind /backup/scan /home/scan
/usr/bin/mount --bind /backup/fax /home/ffax
#/usr/bin/mount -t cifs -o ro,username=xxxx,password=xxxx,uid=1000,gid=1000,dir_mode=0777,file_mode=0775 "//server/" /mnt/server/

