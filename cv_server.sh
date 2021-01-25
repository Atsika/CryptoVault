#!/bin/bash

# Author			: Alexandre NESIC
# Name              : cv_server.sh
# Description       : Create an encrypted vault

############# VARIABLES ##############
# Variables with same name in client and server script must have same value

# Partition on which the vault will be created (e.g. /dev/sda1)
PARTITION=#/dev/sda9
# Size of the vault in MEGABYTES (e.g. 200)
SIZE=#200
# Name for the new user create only for the vault (e.g. vault)
VAULT_USER=#coffre
# Name of new rsa key pair generated to connect to vault (e.g. vault_key)
SSH_KEY=#vault_key
# It's recommended to change default SSH port (e.g. 7222)
SSH_PORT=#7222

############# CONSTANTS ##############

# Text style and colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'
BOLD=$(tput bold)
NORM=$(tput sgr0)

# Encrypted logical volume
VOLGROUP="VGDATA"
LOGVOLUME="lv_coffre"
ENC_LOGVOL="${LOGVOLUME}crypt"
MNTPOINT="$VAULT_HOME/COFFRE"

VAULT_HOME=/home/$VAULT_USER

############# FUNCTIONS ##############

# Error Message
error() {
	echo -e "${RED}${BOLD}[-][$(date +'%T')] $1${NC}"
}

# Successful message
success() {
	echo -e "${GREEN}${BOLD}[+][$(date +'%T')] $1${NC}"
}

# Informational message
info() {
	echo -e "${BLUE}${BOLD}[*][$(date +'%T')] $1${NC}"
}

# Help menu
help() {
	echo -e "
${BOLD}NAME${NC} 
	  CryptoVault - Create an encrypted vault (SERVER)
		  
${BOLD}SYNTAX${NC}
	  $0
		  
${BOLD}IMPORTANT${NC}
	  Don't forget to fill variables at the top of the script.
	  Don't run this script as root.
	  Run it with a user that have sudo rights.
"
	exit
}

# Create vault
vault() {
	sudo pvcreate -y -qq $PARTITION && info "Physical volume $PARTITION successfully created."
	sudo vgcreate -qq $VOLGROUP $PARTITION && info "Volume group $VOLGROUP successfully created"
	sudo lvcreate -qq -L ${SIZE}M -n $LOGVOLUME $VOLGROUP && info "Logical volume $LOGVOLUME created"
	sudo cryptsetup -qq luksFormat /dev/$VOLGROUP/$LOGVOLUME && info "Logical volume successfully encrypted"
	sudo cryptsetup luksOpen /dev/$VOLGROUP/$LOGVOLUME $ENC_LOGVOL && info "Logical volume successfully opened"
	sudo mkfs.xfs -q /dev/mapper/$ENC_LOGVOL && info "Logical volume successfully formated"
}

# Create vault structure
struct() {
	if [ ! -d "$MNTPOINT" ]; then
		sudo mkdir $MNTPOINT
	fi

	sudo mount /dev/mapper/$ENC_LOGVOL $MNTPOINT
	sudo mkdir -p $MNTPOINT/{CERTIFICAT,ENVIRONNEMENT/{bash,ksz,zsh},MEMENTO,SECURITE/{fail2ban,firewall,supervision},SERVER/{apache/{CENTOS8,DEBIAN10},bind,nginx,rsyslog,ssh}} && info "Creating arborescence"
	sudo chown -R $VAULT_USER:$VAULT_USER $MNTPOINT
	sudo umount $MNTPOINT
	sudo cryptsetup luksClose /dev/mapper/$ENC_LOGVOL
}

chrooting(){

	sudo chown root:root $VAULT_HOME

	sudo cp -rp /usr $VAULT_HOME/
	sudo cp -rp /bin $VAULT_HOME/
	sudo cp -rp /sbin $VAULT_HOME/
	sudo cp -rp /lib $VAULT_HOME/
	sudo cp -rp /lib64 $VAULT_HOME/
	sudo cp -rp /etc $VAULT_HOME/
	sudo cp -rp /dev $VAULT_HOME/
	sudo mkdir -m 755 $VAULT_HOME/run

	sudo mkdir $VAULT_HOME/proc
	sudo mount -t proc /proc $VAULT_HOME/proc

	echo "
PermitRootLogin no
Port $SSH_PORT

# Chroot for vault user
Match User $VAULT_USER
	ChrootDirectory /home/%u
	AllowTcpForwarding no
	X11Forwarding no
" | sudo tee -a /etc/ssh/sshd_config > /dev/null

	sudo systemctl reload ssh
}

setup_ssh(){
	if [ ! -d "$VAULT_HOME/.ssh" ]; then
		sudo mkdir $VAULT_HOME/.ssh
	fi

	ssh-keygen -b 4096 -t rsa -f $VAULT_HOME/.ssh/$SSH_KEY -C $VAULT_USER@$(hostname)
	cat $VAULT_HOME/.ssh/$SSH_KEY.pub | sudo tee -a $VAULT_HOME/.ssh/authorized_keys > /dev/null
	sudo chown -R $VAULT_USER:$VAULT_USER $VAULT_HOME/.ssh
}

############# MAIN ##############

if [ "$1" == "-h" ]; then
	help
fi

if [ -z "$PARTITION" ] || [ -z "$SIZE" ] || [ -z "$SSH_KEY" ] || [ -z "$SSH_PORT" ]; then
	error "Error try -h for help and check IMPORTANT section"
	exit
fi

read -p "Partition $PARTITION will be overwritten. Proceed ? [Y/n] " confirm
if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ] && [ "$confirm" != "" ]; then
	exit
fi

info "Downloading necessary packages"
sudo apt-get -qq install -qq -y lvm2 cryptsetup > /dev/null 2> /dev/null && success "Packages successfully downloaded"

info "Creating new user $VAULT_USER"
sudo useradd -m --shell /bin/bash -G sudo $VAULT_USER && success "User successfully created"
info "Granting special rights"
echo "coffre ALL=NOPASSWD: /usr/bin/mount, /usr/bin/umount, /usr/sbin/cryptsetup" | sudo EDITOR='tee -a' visudo > /dev/null

info "Generating SSH keys"
setup_ssh
success "SSH keys successfully generated"

vault
success "Encrypted vault successfully created"

struct
success "Vault structure successfully created"

chrooting
success "Chroot successfully created"
