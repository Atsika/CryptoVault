#!/bin/bash

# Author        : Alexandre NESIC
# Name			: cv_client.sh
# Description	: Manage the encrypted vault
# Param1		: Command to execute

############# VARIABLES ##############
# Variables with same name in client and server script must have same value

# Name of rsa key pair used to connect to vault (e.g. vault_key)
SSH_KEY=#vault_key
# Name of the user used to create the vault on server (e.g. admin)
SSH_USER=#user
# IP of the server on which the vault is installed (e.g. 192.168.1.10)
SSH_HOST=#172.16.57.129
# It's recommended to change default SSH port (e.g. 7222)
SSH_PORT=#7222
# Name of the user created only for the vault (e.g. vault)
VAULT_USER=#coffre

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

# Help menu
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
	  Don't forget to fill variables at the top of the script.
	  Don't run this script as root.
	  Run it with a user that have sudo rights.
"
	exit
}

############# MAIN ##############

if [ -z "$SSH_HOST" ] || [ -z "$SSH_USER" ] || [ -z "$SSH_KEY" ] || [ -z "$SSH_PORT" ] || [ -z "$VAULT_USER" ]; then
	error "Error try -h for help and check IMPORTANT section"
	exit
fi

case $1 in

init)
	info "Downloading necessary packages"
	#sudo apt install sshfs; check && info "Packages successfully installed"
	info "Grabbing SSH key"
	scp -P $SSH_PORT $SSH_USER@$SSH_HOST:/home/$VAULT_USER/.ssh/$SSH_KEY $HOME/.ssh/
    success "SSH key successfully acquired"
	echo "
Host VAULT
	Hostname $SSH_HOST
	User $VAULT_USER
	Port $SSH_PORT
	IdentityFile $HOME/.ssh/$SSH_KEY" >> $HOME/.ssh/config
	success "Initialization finished. You can now mount the vault"
	;;

mount)
	info "Decrypting vault"
	ssh -t VAULT "sudo cryptsetup luksOpen /dev/$VOLGROUP/$LOGVOLUME $ENC_LOGVOL && sudo mount /dev/mapper/$ENC_LOGVOL COFFRE"
	success "Vault successfully decrypted"
	info "Mouting vault"
	mkdir COFFRE
	sshfs -o reconnect VAULT:COFFRE COFFRE
	success "Vault successfully mounted"
	;;

umount)
	info "Unmounting vault"
	fusermount -u COFFRE
	success "Vault successfully unmounted"
	rmdir COFFRE
	info "Encrypting and closing vault"
	ssh -t VAULT "sudo umount COFFRE && sudo cryptsetup luksClose /dev/mapper/$ENC_LOGVOL"
	success "Vault successfully closed"
	;;

-h | --help | --h)
	help
	;;
*)
	error "Invalid syntax try $0 -h"
	;;
esac