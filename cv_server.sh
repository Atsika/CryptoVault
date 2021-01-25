#!/bin/bash

# Name              : cv_server.sh
# Description       : create an encrypted vault/COFFRE
# Param1            : partition where to build the vault
# Param2            : size of the vault in megabytes
# Param3			: new user for the vault

############# VARIABLES ##############

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'
BOLD=$(tput bold)
NORM=$(tput sgr0)

PARTITION=$1
SIZE=$2
VAULT_USER=$3

SSH_PORT=7222
SSH_KEY=vault_rsa

VAULT_HOME=/home/$VAULT_USER

MNTPOINT="$VAULT_HOME/COFFRE"
VOLGROUP="VGDATA"
LOGVOLUME="lv_coffre"
ENC_LOGVOL="${LOGVOLUME}crypt"

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
	  $0 [partition] [size] [user]
	  ex : $0 /dev/sda1 200 coffre
		  
${BOLD}PARAMETERS${NC} 
	  [partition]		partition for the vault
	  [size]		vault size in megabytes
	  [user]		name for new user dedicated to vault
	  "
	exit
}

# Create vault
vault() {
	sudo pvcreate -y -qq $PARTITION; check && info "Physical volume $PARTITION successfully created."
	sudo vgcreate -qq $VOLGROUP $PARTITION; check && info "Volume group $VOLGROUP successfully created"
	sudo lvcreate -qq -L ${SIZE}M -n $LOGVOLUME $VOLGROUP; check && info "Logical volume $LOGVOLUME created"
	sudo cryptsetup -qq luksFormat /dev/$VOLGROUP/$LOGVOLUME; check && info "Logical volume successfully encrypted"
	sudo cryptsetup luksOpen /dev/$VOLGROUP/$LOGVOLUME $ENC_LOGVOL; check && info "Logical volume successfully opened"
	sudo mkfs.xfs -q /dev/mapper/$ENC_LOGVOL; check && info "Logical volume successfully formated"
}

# Create the vault arborescence
arbo() {
	if [ ! -d "$MNTPOINT" ]; then
		sudo mkdir $MNTPOINT; check
	fi

	sudo mount /dev/mapper/$ENC_LOGVOL $MNTPOINT; check
	sudo mkdir -p $MNTPOINT/{CERTIFICAT,ENVIRONNEMENT/{bash,ksz,zsh},MEMENTO,SECURITE/{fail2ban,firewall,supervision},SERVER/{apache/{CENTOS8,DEBIAN10},bind,nginx,rsyslog,ssh}}; check && info "Creating arborescence"
	sudo chown -R $VAULT_USER:$VAULT_USER $MNTPOINT
	sudo umount $MNTPOINT; check
	sudo cryptsetup luksClose /dev/mapper/$ENC_LOGVOL; check
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

	ssh-keygen -b 4096 -t rsa -f $HOME/.ssh/$SSH_KEY -C $VAULT_USER@$(hostname)
	cat $HOME/.ssh/$SSH_KEY.pub | sudo tee -a $VAULT_HOME/.ssh/authorized_keys > /dev/null
	sudo chown -R $VAULT_USER:$VAULT_USER $VAULT_HOME/.ssh
}

############# MAIN ##############

if [ "$1" == "-h" ]; then
	help
fi

if [ "$#" -ne 3 ]; then
	error "Wrong number of arguments try -h for help"
	exit
fi

read -p "Partition $PARTITION will be overwritten. Proceed ? [Y/n] " confirm
if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ] && [ "$confirm" != "" ]; then
	exit
fi

info "Downloading necessary packages"
sudo apt-get -qq install -qq -y lvm2 cryptsetup > /dev/null 2> /dev/null && success "Packages successfully downloaded"

info "Creating new user $VAULt_USER"
sudo useradd -m --shell /bin/bash -G sudo $VAULT_USER && success "User successfully created"
echo "coffre ALL=NOPASSWD: /usr/bin/mount, /usr/bin/umount, /usr/sbin/cryptsetup" | sudo EDITOR='tee -a' visudo > /dev/null

info "Generating SSH keys"
setup_ssh
success "SSH keys successfully generated"

vault
success "Encrypted vault successfully created"

arbo
success "Arborescence successfully created"

chrooting
success "Chroot successfully created"
