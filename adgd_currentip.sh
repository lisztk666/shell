#!/bin/bash
clear
TARGET_DOMAIN="uifast.ui.idv.tw"
YAML_PATH="/AdGuardHome/AdGuardHome.yaml"
RELOAD_CMD="systemctl reload adguardhome"
IP_STORE="/tmp/last_uifast_ip.txt"
AD_RESTART="/AdGuardHome/AdGuardHome -s restart"

current_ip=$(dig +short $TARGET_DOMAIN | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n 1)
NLSET_VAL="    answer: $current_ip"
rm -rf $IP_STORE
if [ -z "$current_ip" ]; then
  echo "$(date): can'y get doamin_ip "
    exit 1
    fi

    if [ -f "$IP_STORE" ]; then
      last_ip=$(cat "$IP_STORE")
      else
        last_ip=""
        fi

        if [ "$current_ip" != "$last_ip" ]; then
          echo "$(date): IP Chang, $last_ip update $current_ip"

        NLGET=$(nl $YAML_PATH|grep $TARGET_DOMAIN|awk '{print $1}' )
        echo $NLGET
        NLNEXT=$((NLGET + 1))
        echo $NLNEXT
        echo $NLSET_VAL

        if sed -n "${NLNEXT}p" $YAML_PATH |grep -q 'answer:';then
#           sed -i "${NLNEXT}"s/[0-9.]\+/$current_ip/ $YAML_PATH
            echo "sed '${NLNEXT}c $NLSET_VAL' $YAML_PATH"
            echo "=========================================="
            #sed  -i "${NLNEXT}c $NLSET_VAL" "$YAML_PATH"
            echo sed -i '/domain: uifast.ui.idv.tw/ { :a; n; s/answer: *[0-9]\{1,3\}\(\.[0-9]\{1,3\}\)\{3\}/answer: $current_ip/; ta }'
            sed -i "/domain: uifast.ui.idv.tw/ { :a; n; s/answer: *[0-9]\{1,3\}\(\.[0-9]\{1,3\}\)\{3\}/answer: $current_ip/; ta }" $YAML_PATH
            echo "=========================================="
    fi
           echo "$current_ip" > "$IP_STORE"
           echo "=========================================="
#           $AD_RESTART
           echo "$(date): domain update "
        else
           echo "$(date): IP no chang"
        fi
