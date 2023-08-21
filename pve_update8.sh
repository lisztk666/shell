#!/bin/bash

#修改source 
sed -i 's/deb/#deb/g' /etc/apt/sources.list.d/pve-enterprise.list
sed -i 's/deb/#deb/g' /etc/apt/source.list.d/ceph.list

cat << "EOF" > /etc/apt/sources.list 
deb http://ftp.debian.org/debian bookworm main contrib
deb http://ftp.debian.org/debian bookworm-updates main contrib

# PVE pve-no-subscription repository provided by proxmox.com,
# NOT recommended for production use
deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription

# security updates
deb http://security.debian.org/debian-security bookworm-security main contrib

EOF

#更新
apt update -y && apt upgrade -y && pveam update

#apt套件
apt install htop iftop tree vim lshw lm-sensors screen iotop  nfs-kernel-server autofs cifs-utils wakeonlan smartmontools  p7zip-full zfs-zed net-tools  dos2unix vsftpd mutt samba ncdu apcupsd sysstat  multipath-tools lsscsi  ifstat iptraf-ng  nethogs  bmon cbm nload terminator tmux cpufrequtils ntpdate pv python3-pip s-tui gpart ethtool git  hwloc neofetch bridge-utils glnaces-y
#hddtemp 
#&&  pip install glances 

#修改.bashrc
cp -a /root/.bashrc /root/.bashrc.default

cat << "EOF" > /root/.bashrc 

# ~/.bashrc: executed by bash(1) for non-login shells.

# Note: PS1 and umask are already set in /etc/profile. You should not
# need this unless you want different defaults for root.
 PS1='${debian_chroot:+($debian_chroot)}\h:\w\$ '
# umask 022

# You may uncomment the following lines if you want `ls' to be colorized:
 export LS_OPTIONS='--color=auto'
 eval "$(dircolors)"
 alias ls='ls $LS_OPTIONS'
 alias ll='ls $LS_OPTIONS -l'
 alias l='ls $LS_OPTIONS -lA'
#
# Some more alias to avoid making mistakes:
 alias rm='rm -i'
 alias cp='cp -i'
 alias mv='mv -i'
 alias vi='vim'
 alias n20='nice -n -20'
 alias ssenable='systemctl enable --now'
 alias ssdisable='systemctl disalbe --now'
 alias sstop='systemctl stop'
 alias sstart='systemctl start'
 alias sstatus='systemctl status'
 alias ssrestart='systemctl restart'
EOF

#修改ipv6
sed -i 's/#precedence ::ffff:0:0\/96  100/precedence ::ffff:0:0\/96  100/g' /etc/gai.conf

#開始建立目錄
mkdir /etc/sh -p
cd /etc/sh
#git clone https://github.com/lisztk666/shell
mv /etc/sh/shell/* /etc/sh/
chmod +x /etc/sh/*.sh 

#修改vimrc
cat << "EOF" >/root/.vimrc
"#######################################################
set nocompatible

"#######################################################
syntax enable
set number
set noruler
set ignorecase
set smartcase
set incsearch
set cindent
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
set smarttab
set confirm
set backspace=indent,eol,start
set history=500
set showcmd
set showmode
set nowrap
set autowrite
set pastetoggle=
set mouse=v

"#######################################################
" Color
set t_Co=256
colo torte
set cursorline
set cursorcolumn
set hlsearch
hi CursorLine cterm=none ctermbg=DarkMagenta ctermfg=White
hi CursorColumn cterm=none ctermbg=DarkMagenta ctermfg=White
hi Search cterm=reverse ctermbg=none ctermfg=none

EOF

#修改samba
cp -a /etc/samba/smb.conf /etc/samba/smb.conf.default

cat << "EOF" >/etc/samba/smb.conf
#======================= Global Settings =====================================
	
[global]
	
# ----------------------- Network Related Options -------------------------
#
	workgroup = WORKGROUP
#	server string = Samba Server Version %v
	
	netbios name = win2000
	getwd cache = yes
#	socket options = TCP_NODELAY SO_RCVBUF=8192 SO_SNDBUF=8192
	socket options = IPTOS_LOWDELAY TCP_NODELAY
##################以下是 shadow _copy
# vfs modules
        #vfs objects = recycle shadow_copy2 full_audit
		vfs objects = recycle shadow_copy2 
        # recycle
        recycle:repository = .recycle
        recycle:keeptree = yes
        recycle:versions = yes
        recycle:touch = no
        recycle:maxsize = 0
        recycle:exclude = *.tmp ~$* *.td.cfg *.td *.uploading.cfg
        recycle:noversions = *.doc
        # shadow_copy2
        shadow:snapdir = .zfs/snapshot
        shadow:sort = desc
        shadow:format = %Y.%m.%d-%H.%M.%S
        shadow:localtime = yes
        # MAC tune
        veto files = /._*/.DS_Store/
        delete veto files = yes

# log     
        full_audit:prefix = %u|%I|%m|%S
        full_audit:failure = all
        #full_audit:succese = mkdir rmdir read pread write pwrite unlink chmod chown rename
        #full_audit:succese = mkdir rmdir pread pwrite rename
        full_audit:succese =  rename
        #full_audit:succese =  mkdir pwrite rename unlink rmdir
        #full_audit:priority = notice
        full_audit:priority = debug
        full_audit:facility = local5


##################################
#       以下是for samba 預設,xp 無法登入
#       client lanman = no
#       lanman auth = no
#       client NTLMv2 auth = yes

#       client lanman = yes
##       ntlm auth = yes

#for xp login
#server min protocol = NT1
#lanman auth = yes
#ntlm auth = yes

# smb3.0
#server multi channel support = yes


# win10 永旭沒辦法登入有開啟這個
         protocol = SMB2
############################
           
#for xp 顯示不正確
;	dos charset = cp950
	unix charset= utf8
;	display charset = cp950

#    不需密碼登入強制登記為nobody
;      guest acount = nobody

;	display charset = UTF8 
;	dos charset = cp950 
;	unix charset = UTF8	
	
        hide files = /lost+found/
        veto files = /Thumbs.db/
##    strict locking = no

;	interfaces = lo eth0 192.168.12.2/24 192.168.13.2/24 
;	hosts allow = 127. 192.168.12. 192.168.13.
	
# --------------------------- Logging Options -----------------------------
	
	# logs split per machine
	log file = /var/log/samba/log.%m
	# max 50KB per log file, then rotate
	max log size = 50
	
# ----------------------- Standalone Server Options ------------------------

	security = user
	passdb backend = tdbsam
	#passdb backend = smbpasswd

	#將guest權限設nobody
	guest account = nobody

	#電腦無須號密碼登入
;	map to guest = bad user

# ----------------------- Domain Members Options ------------------------
;	security = domain
;	passdb backend = tdbsam
;	realm = MY_REALM

;	password server = <NT-Server-Name>

# ----------------------- Domain Controller Options ------------------------
#
;	security = user
;	passdb backend = tdbsam
	
;	domain master = yes 
;	domain logons = yes
	
	# the login script name depends on the machine name
;	logon script = %m.bat
	# the login script name depends on the unix user used
;	logon script = %u.bat
;	logon path = \\%L\Profiles\%u
	# disables profiles support by specifing an empty path
;	logon path =          
	
;	add user script = /usr/sbin/useradd "%u" -n -g users
;	add group script = /usr/sbin/groupadd "%g"
;	add machine script = /usr/sbin/useradd -n -c "Workstation (%u)" -M -d /nohome -s /bin/false "%u"
;	delete user script = /usr/sbin/userdel "%u"
;	delete user from group script = /usr/sbin/userdel "%u" "%g"
;	delete group script = /usr/sbin/groupdel "%g"
	
	
# ----------------------- Browser Control Options ----------------------------
;	local master = no
;	os level = 33
;	preferred master = yes
	
#----------------#=======================------------- Name Resolution -------------------------------
	
;	wins support = yes
;	wins server = w.x.y.z
;	wins proxy = yes
	
	dns proxy = no
	
# --------------------------- Printing Options -----------------------------
	
#	load printers = yes
        load printers = no
#	cups options = raw

;	printcap name = /etc/printcap
	#obtain list of printers automatically on SystemV
;	printcap name = lpstat
        printcap name = /dev/null
;	printing = cups
        printing = bsd

# --------------------------- Filesystem Options ---------------------------

;	map archive = no
;	map hidden = no
;	map read only = no
;	map system = no
;	store dos attributes = yes


#============================ Share Definitions ==============================
	
;[homes]
;	comment = Home Directories
;	browseable = no
;	writable = yes
;	valid users = %S
;	valid users = MYDOMAIN\%S
	
;[printers]
;	comment = All Printers
;	path = /var/spool/samba
;	browseable = no
;	guest ok = no
;	writable = no
;	printable = yes
	
# Un-comment the following and create the netlogon directory for Domain Logons
;	[netlogon]
;	comment = Network Logon Service
;	path = /var/lib/samba/netlogon
;	guest ok = yes
;	writable = no
;	share modes = no
	
	
# Un-comment the following to provide a specific roving profile share
# the default is to use the user's home directory
;	[Profiles]
;	path = /var/lib/samba/profiles
;	browseable = no
;	guest ok = yes
	
	
# A publicly accessible directory, but read only, except for people in
# the "staff" group
;	[public]
;	comment = Public Stuff
;	path = /home/samba
;	public = yes
;	writable = yes
;	printable = no
;	write list = +staff

	[hs]
    #chown root:user 
    #force user=user
	comment = W3000
	path = /sysvol/hs
	public = no
	writable = yes
	create mode=0775
	directory  mode=0775
	browseable=yes
	printable = no

        #//不要鎖定oplocks,下面3個lock
#	oplocks = no 
#       locking = no
    #//嚴格的鎖定
        #strict locking = no 
	
	[share]
    #chown user:user
    #force user=user
	comment = share
	path = /sysvol/share
	public = no
	writable = yes
	create mode=0775
	directory  mode=0775
	browseable=yes
	printable = no
	
	[bak]
	comment = 每周備份
	path = /backup/bak
	public = no
	writable = no
	create mode=0775
	directory  mode=0775
	browseable=yes
	printable = no

	[log]
	comment = 備份訊息
	path = /backup/log
	public = no
	writable = no
	create mode=0775
	directory  mode=0775
	browseable=yes
	printable = no

	[mis$]
	comment = mis
	path = /backup/mis
        #force user=user
        #valid users=admins
	public = no
	writable = no
	create mode=0775
	directory  mode=0775
	browseable=no
	printable = no
EOF

#修改 vsftpd
mkdir /etc/vsftpd
touch /etc/vsftpd/chroot_list
cat << "EOF" >/etc/vsftpd/usr_list
user
scan
fax
ifax
EOF

cat << "EOF" >/etc/vsftpd.conf
# Allow anonymous FTP? (Beware - allowed by default if you comment this out).
anonymous_enable=YES
#
local_enable=YES
#
write_enable=YES
#
local_umask=022
#
#anon_upload_enable=YES
#
#anon_mkdir_write_enable=YES
#
dirmessage_enable=YES
#
xferlog_enable=YES
#
connect_from_port_20=YES
#
#chown_uploads=YES
#chown_username=whoever
#
vsftpd_log_file=/var/log/vsftpd.log
xferlog_enable=YES
xferlog_std_format=YES
xferlog_file=/var/log/xferlog
dual_log_enable=YES
log_ftp_protocol=YES
setproctitle_enable=YES
#
#idle_session_timeout=600
#
#data_connection_timeout=120
#
#nopriv_user=ftpsecure

#async_abor_enable=YES
#ascii_upload_enable=YES
#ascii_download_enable=YES

#deny_email_enable=YES
#banned_email_file=/etc/vsftpd/banned_emails
#
chroot_local_user=YES
chroot_list_enable=YES
chroot_list_file=/etc/vsftpd/chroot_list
allow_writeable_chroot=YES
#只有在名單內的可以在/外面

#
#ls_recurse_enable=YES
#
listen=YES
#
#listen_ipv6=YES

pam_service_name=vsftpd
userlist_enable=YES
userlist_deny=NO
userlist_file=/etc/vsftpd/user_list
#新增在 user_list 裡的帳號,可以登入

tcp_wrappers=YES
use_localtime=YES
EOF

#修改/etc/shells
echo "/etc/shells"
sed -i '$a /bin/false' /etc/shells
sed -i '$a /usr/sbin/nologin' /etc/shells

#開機服務
cp /lib/systemd/system/rc-local.service /etc/systemd/system/rc-local.service
cat << "EOF" >>/etc/systemd/system/rc-local.service

[Install]                                 
WantedBy=multi-user.target
EOF

cat << "EOF" >  /etc/rc.local
#!/bin/bash 
/etc/sh/startsh.sh
exit 0
EOF

chmod +x /etc/rc.local
systemctl enable rc-local --now

#修改apcupsd
cp -a /etc/apcupsd/apcupsd.conf /etc/apcupsd/apcupsd.conf.default
#sed -i 's/#UPSNAME/UPSNAME BN650M1-TW/g'    /etc/apcupsd/apcupsd.conf
#sed -i 's/UPSCABLE/UPSCABLE usb/g'    /etc/apcupsd/apcupsd.conf
sed -i 's/#POLLTIME/POLLTIME 60/g'    /etc/apcupsd/apcupsd.conf
sed -i 's/#BATTERYLEVEL 5/BATTERYLEVEL 50/g'    /etc/apcupsd/apcupsd.conf
sed -i 's/TIMEOUT 0/TIMEOUT 120/g'    /etc/ap
