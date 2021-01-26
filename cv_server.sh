#!/bin/bash

# Author			: Alexandre NESIC & Sean MATTHEWS
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

# Help message
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

# Chroot new vault user
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

# Generate SSH keys for the new vault user
setup_ssh(){
	if [ ! -d "$VAULT_HOME/.ssh" ]; then
		sudo mkdir $VAULT_HOME/.ssh
	fi

	ssh-keygen -b 4096 -t rsa -f $VAULT_HOME/.ssh/$SSH_KEY -C $VAULT_USER@$(hostname)
	cat $VAULT_HOME/.ssh/$SSH_KEY.pub | sudo tee -a $VAULT_HOME/.ssh/authorized_keys > /dev/null
	sudo chown -R $VAULT_USER:$VAULT_USER $VAULT_HOME/.ssh
}

# check if variables are set
check_var() {
	# check if the partition exist
	while [ -z "$PARTITION" ]
	do
		lsblk -l | awk 'NR==1 || / $/ {print $1"\t"$4}'
		read -p "Enter the partition to be used for CryptoVault : " PARTITION
		lsblk $PARTITION > /dev/null 2> /dev/null
		if [ $? -ne 0 ]; then
			PARTITION=""
			error "The partition does not exist"
		fi
	done	
	
	# check if there is enough space on the partition
	while [ -z "$SIZE" ]
	do
		read -p "Enter the size of the partition for CryptoVault (Megabytes) : " SIZE

		MOUNTED=$(mount | grep $PARTITION)
		if [ -z $MOUNTED ];then
			sudo mount $PARTITION /mnt
		fi

		AVAILABLE=$(df -k -B M | grep $PARTITION | awk '{print $4}' | sed 's/M//g')
		if [ $AVAILABLE -lt $SIZE ];then
			sudo umount /mnt
			error "Not enough space on partition $PARTITION"
			SIZE=""
		fi

	done	
	
	while [ -z "$VAULT_USER" ]
	do
		read -p "Enter a name for the vault user : " VAULT_USER
	done	
	
	while [ -z "$SSH_KEY" ]
	do
		read -p "Enter the name for the ssh key files : " SSH_KEY
	done	
	
	# Check if the port number is valid / is note used
	while [ -z "$SSH_PORT" ]
    do
        LISTEN=$(ss -tlnp | awk -F":" '{print $2}' | awk '{print $1}' | tail -n +2)
        read -p "Enter the port that will be set for SSH : " SSH_PORT
        test=$(grep -w $SSH_PORT<<< "$LISTEN") 
        if ! [[ "$SSH_PORT" =~ ^[0-9]+$ ]] || [ "$SSH_PORT" -lt 1 ] || [ "$SSH_PORT" -gt 65535 ] || [ "$test" != "" ] || ! [[ "$SSH_PORT" =~ ^[0-9]+$ ]]; then

            echo "invalide port number [1-65535] or the port is already used :"
            SSH_PORT=""
        fi
    done
}

############# MAIN ##############

# ./cv_server.sh -h displays help message
if [ "$1" == "-h" ]; then
	help
fi

# Check if variables are all set
if [ -z "$PARTITION" ] || [ -z "$SIZE" ] || [ -z "$SSH_KEY" ] || [ -z "$SSH_PORT" ]; then
	error "Error try -h for help and check IMPORTANT section"
	exit
fi

# Don't run this script as root, you will be prompted if sudo needed
if [ "$EUID" -eq 0 ];then 
	error "Don't run this script as root."
  	exit
fi

check_var

sudo umount /mnt

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
