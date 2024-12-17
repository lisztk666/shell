#!/bin/bash
#https://www.spamhaus.org/

cd /tmp
rm -rf /tmp/drop.*
wget http://www.spamhaus.org/drop/drop.txt -P /tmp

BFILE="/tmp/drop.txt"
OUTFILE="/tmp/outfile.txt"
#BANRSC="/var/lib/docker/volumes/nginx-data/_data/ban.rsc"
#BANRSC="/sysvol/docker/nginx9881/ban.rsc"
BANSRC="/backup/ban.src"

cat $BFILE |awk -F";" '{print $1}' >a

awk 'NF { gsub(/^[ \t]+|[ \t]+$/, ""); print }' a > $OUTFILE
rm -rf /tmp/a



for x in $(cat $OUTFILE);do
    echo "/ip firewall address-list add list=filehost_list address="$x""
    echo "/ip firewall address-list add list=filehost_list address="$x"" >>$BANSRC
done
