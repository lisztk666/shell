#/bin/bash
#範例是windows vm 中我只需要備份 c(virtio0) ,但 d (virtio1)我不需要

PWD="/etc/pve/qemu-server/"
VM="填入vm的id"
PWD_VM="$VM.conf"
PWD_VMBAK="$VM.bak"
SED_DV1="/顯示要刪除的/d"
#SED_DV1="/virtio1/p"
PWD_BAKDIR="/backup/dump"

#顯示變數
echo $SED_DV1

#開始備份conf
cat  "$PWD""$PWD_VM" > "$PWD""$PWD_VMBAK"

#置換conf
sed -i "$SED_DV1" "$PWD""$PWD_VM"

#顯示 vmid_conf
cat "$PWD""$PWD_VM"

#備份虛擬機
vzdump $VM --ionice 7 -compress zstd -dumpdir $PWD_BAKDIR

#還原備份conf
cat  "$PWD""$PWD_VMBAK" > "$PWD""$PWD_VM"
