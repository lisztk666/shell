#!/bin/bash
#https://www.spamhaus.org/
#¿¿ spaamhaus drop ¿¿¿¿ mikrotik ban.rsc
cd /tmp
rm -rf /tmp/drop.*
wget http://www.spamhaus.org/drop/drop.txt -P /tmp

BFILE="/tmp/drop.txt"
OUTFILE="/tmp/outfile.txt"
BANRSC="/var/www/html/tools/ban.rsc"

#égrep space
cat $BFILE |awk -F";" '{print $1}' >a
awk 'NF { gsub(/^[ \t]+|[ \t]+$/, ""); print }' a > $OUTFILE
rm -rf /tmp/a

for x in $(cat $OUTFILE);do
    echo "/ip firewall address-list add list=filehost_list address=$x >>$BANRSC"
done
