#!/bin/bash

# Name                : vault.sh
# Description         : create an encrypted vault/COFFRE
# Param1              : partition where to build the vault
# Param2              : size of the vault in megabytes

############# VARIABLES ##############

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'
BOLD=$(tput bold)
NORM=$(tput sgr0)

PARTITION=$1
SIZE=$2

SSH_PORT=7222

VAULT_USER=coffre

MNTPOINT="$HOME/COFFRE"
VOLGROUP="VGROOT"
LOGVOLUME="lv_coffre"
ENC_LOGVOL="${LOGVOLUME}_encrypt"

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

# Check return value of last command
check() {
	if [ "$?" -ne 0 ]; then
		error "An error occurred while executing : $(fc -l -n -1)"
		exit
	fi
}

# Help menu
help() {
	echo -e "
${BOLD}NAME${NC} 
	  CryptoVault - Create an encrypted vault (SERVER)
		  
${BOLD}SYNTAX${NC}
	  $0 [partition] [size]
	  ex : $0 /dev/sda1 200
		  
${BOLD}PARAMETERS${NC} 
	  [partition]       partition for the vault
	  [size]            vault size in megabytes
	  "
	exit
}

# Create vault
vault() {
	sudo pvcreate -qq $PARTITION; check && info "Physical volume $PARTITION successfully created."
	sudo vgcreate -qq $VOLGROUP $PARTITION; check && info "Volume group $VOLGROUP successfully created"
	sudo lvcreate -qq -L ${SIZE}M -n $LOGVOLUME $VOLGROUP; check && info "Logical volume $LOGVOLUME created"
	sudo cryptsetup -qq luksFormat /dev/$VOLGROUP/$LOGVOLUME; check && info "Logical volume successfully encrypted"
	sudo cryptsetup luksOpen /dev/$VOLGROUP/$LOGVOLUME $ENC_LOGVOL; check && info "Logical volume successfully opened"
	sudo mkfs.xfs -q /dev/mapper/$ENC_LOGVOL; check && info "Logical volume successfully formated"
}

# Create the vault arborescence
arbo() {
	if [ ! -d "$MNTPOINT" ]; then
		mkdir $MNTPOINT
		check
	fi

	sudo mount /dev/mapper/$ENC_LOGVOL $MNTPOINT; check
	sudo mkdir -p $MNTPOINT/{.ssh,CERTIFICAT,ENVIRONNEMENT/{bash,ksz,zsh},MEMENTO,SECURITE/{fail2ban,firewall,supervision},SERVER/{apache/{CENTOS8,DEBIAN10},bind,nginx,rsyslog,ssh}}; check && info "Creating arborescence"
	sudo touch $MNTPOINT/.ssh/authorized_keys
	sudo useradd $VAULT_USER
	sudo usermod -d $MNTPOINT $VAULT_USER
	sudo chown -R root:$VAULT_USER $MNTPOINT
	sudo chmod -R 750 $MNTPOINT
	sudo chmod 600 $MNTPOINT/.ssh/authorized_keys
	sudo chown -R $VAULT_USER:$VAULT_USER $MNTPOINT/.ssh
	sudo chown root:root $(cd $MNTPOINT/../ && pwd)
	sudo umount $MNTPOINT; check
	sudo cryptsetup luksClose /dev/mapper/$ENC_LOGVOL; check
}

chrootedsftp() {

	sudo sh -c "echo '
# sftp chroot for vault
PermitRootLogin No
Port $SSH_PORT

Match Group coffre
	ChrootDirectory $MNTPOINT
	AllowTcpForwarding no
	ForceCommand internal-sftp
	X11Forwarding no
' >> /etc/ssh/sshd_config"

	sudo systemctl reload ssh
}

############# MAIN ##############

set -o history

if [ "$1" == "-h" ]; then
	help
fi

if [ "$#" -ne 2 ]; then
	error "Wrong number of arguments try -h for help"
	exit
fi

read -p "
Partition $PARTITION will be overwritten. Proceed ? [Y/n] " confirm
if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ] && [ "$confirm" != "" ]; then
	exit
fi

info "Downloading necessary packages" && sudo apt-get install -qq -y lvm2 cryptsetup

if [ ! -d "$HOME/.ssh" ]; then
	mkdir $HOME/.ssh
fi

vault
success "Encrypted vault successfully created"

arbo
success "Arborescence successfully created"

chrootedsftp
success "Chrooted SFTP successfully created"
