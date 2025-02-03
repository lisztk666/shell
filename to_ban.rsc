#!/bin/bash
RFW=/etc/sh/123
IRFW=/tmp/245.rsc
IRFW1=/tmp/banip.rsc
WIP=/var/log/hack/wip
/bin/rm -rf $IRFW
#echo "/ip firewall address-list" >$IRFW
for x in `cat "$RFW"|grep -vf $WIP|sort|uniq`;do
        echo "Deny Deny.........$x"
        #echo "/ip firewall address-list add address=$x list=Badip_List">>$IRFW
        echo "do {/ip firewall address-list add address=$x list=Badip_List} on-error={} ">>$IRFW
        echo "do {/ip firewall address-list add address=$x list=Ban_ip} on-error={} ">>$IRFW1
        #echo "add address=$x list=Badip_List">>$IRFW
        #echo "add address=$x list=Ban_ip">>$IRFW1
done
chmod 777 $IRFW
unix2dos $IRFW
unix2dos $IRFW1
ls -al $IRFW
ls -al $RFW
