#20240216 debian install docker shell
#remove old_docker_version
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done

#
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

#apt install tools
apt install samba mutt dos2unix vsftpd tmux s-tui nload lsscsi ntpdate mc cbm bmon mdadm htop glances btop net-tools -y
apt install iftop iotop gpart ethtool git hwloc tree screen vim cifs-utils wakeonlan smartmontools p7zip-full ifstat apcupsd -y

mkdir /etc/sh /backup /sysvol/docker -p

