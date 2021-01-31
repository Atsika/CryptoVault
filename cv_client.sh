#!/bin/bash

# Author        : Alexandre NESIC & Sean MATTHEWS
# Name			: cv_client.sh
# Description	: Manage the encrypted vault
# Param1		: Command to execute

############# VARIABLES ##############
# Variables with same name in client and server script must have same value

# Name of rsa key pair used to connect to vault (e.g. vault_key)
SSH_KEY=vault_key
# Name of the user used to create the vault on server (e.g. admin)
SSH_USER=""
# IP of the server on which the vault is installed (e.g. 192.168.1.10)
SSH_HOST="" #192.168.5.16
# It's recommended to change default SSH port (e.g. 7222)
SSH_PORT=""
# Name of the user created only for the vault (e.g. vault)
VAULT_USER=coffre

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
	  CryptoVault - Manage an encrypted vault (CLIENT)
		  
${BOLD}SYNTAX${NC}
	  $0 [command]
		  
${BOLD}PARAMETERS${NC} 
	  [command]     Command to execute

${BOLD}COMMANDS${NC}
	  init			initialize first connection
	  mount			mount remote vault
	  umount		unmount remote vault

${BOLD}IMPORTANT${NC}
	  Fill variables at the top of the script to avoid being prompted.
	  Don't run this script as root.
	  Run it with a user that have sudo rights.
"
	exit
}

check_var() {
	while [ -z "$VAULT_USER" ]
	do
		read -p "Enter vault user name : " VAULT_USER
	done	
	
	while [ -z "$SSH_KEY" ]
	do
		read -p "Enter the name of the SSH key files : " SSH_KEY
	done	
	
	while [ -z "$SSH_USER" ]
	do
		read -p "Enter SSH user name: " SSH_USER
	done	
	
	while [ -z "$SSH_HOST" ]
	do
		read -p "Enter server address : " SSH_HOST
	done	
	
	# Check if the port number is valid / is note used
	while [ -z "$SSH_PORT" ]
    do
        read -p "Enter server port : " SSH_PORT
        if ! [[ "$SSH_PORT" =~ ^[0-9]+$ ]] || [ "$SSH_PORT" -lt 1 ] || [ "$SSH_PORT" -gt 65535 ]; then
            error "Invalid port number or already in use"
            SSH_PORT=""
        fi
    done

}

############# MAIN ##############

# ./cv_client.sh -h displays help message
if [ "$1" == "-h" ]; then
	help
fi

# Don't run this script as root, you will be prompted if sudo needed
if [ "$EUID" -eq 0 ];then 
	error "Don't run this script as root."
  	exit
fi

case $1 in

init)
	check_var
	info "Downloading necessary packages"
	sudo apt-get -qq install -y sshfs trash-cli xclip > /dev/null && success "Packages successfully installed"
	info "Grabbing SSH key"
	if [ ! -d "$HOME/.ssh" ]; then
		mkdir $HOME/.ssh
	fi
	scp -q -P $SSH_PORT $SSH_USER@$SSH_HOST:/home/$SSH_USER/.ssh/$SSH_KEY $HOME/.ssh/
    	success "SSH key successfully acquired"
	echo "
Host VAULT
	Hostname $SSH_HOST
	User $VAULT_USER
	Port $SSH_PORT
	IdentityFile $HOME/.ssh/$SSH_KEY" >> $HOME/.ssh/config
	info "Setting MEMENTO"
	ssh -q -t VAULT "sudo cryptsetup luksOpen /dev/$VOLGROUP/$LOGVOLUME $ENC_LOGVOL && sudo mount /dev/mapper/$ENC_LOGVOL COFFRE"
	mkdir $HOME/COFFRE
	sshfs -o reconnect VAULT:COFFRE $HOME/COFFRE
	sed -i "s|MY_HOME|$HOME|g" $HOME/COFFRE/MEMENTO/conf.yml
	sudo ln -s $HOME/COFFRE/MEMENTO/cheat /usr/bin/cheat
	fusermount -u $HOME/COFFRE
	rmdir $HOME/COFFRE
	ssh -q -t VAULT "sudo umount COFFRE && sudo cryptsetup luksClose /dev/mapper/$ENC_LOGVOL"
	success "MEMENTO set successfully"
	success "Initialization finished. You can now mount the vault"
	;;

mount)
	info "Decrypting vault"
	ssh -q -t VAULT "sudo cryptsetup luksOpen /dev/$VOLGROUP/$LOGVOLUME $ENC_LOGVOL && sudo mount /dev/mapper/$ENC_LOGVOL COFFRE"
	success "Vault successfully decrypted"
	info "Mouting vault"
	mkdir $HOME/COFFRE
	sshfs -o reconnect VAULT:COFFRE $HOME/COFFRE
	success "Vault successfully mounted on $HOME/COFFRE"
	;;

umount)
	info "Unmounting vault"
	fusermount -u $HOME/COFFRE
	success "Vault successfully unmounted"
	rmdir $HOME/COFFRE
	info "Encrypting and closing vault"
	ssh  -q -t VAULT "sudo umount COFFRE && sudo cryptsetup luksClose /dev/mapper/$ENC_LOGVOL"
	success "Vault successfully closed"
	;;

*)
	error "Invalid syntax try $0 -h"
	;;
esac
