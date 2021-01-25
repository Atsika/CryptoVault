#!/bin/bash

# Author        : Alexandre NESIC
# Description	: Monte et démonte un coffre distant
# Param1		: initialise, monte ou démonte le coffre

############# VARIABLES ##############

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'
BOLD=$(tput bold)
NORM=$(tput sgr0)

SSH_KEY=vault_rsa
SSH_USER=user
SSH_HOST=172.16.57.129
SSH_PORT=7222

VAULT_USER=coffre

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

help() {
	echo -e "
${BOLD}NAME${NC} 
	  CryptoVault - Manage an encrypted vault (CLIENT)
		  
${BOLD}SYNTAX${NC}
	  $0 [command]
	  ex : $0 init
		  
${BOLD}PARAMETERS${NC} 
	  [command]     Command to execute
${BOLD}COMMANDS${NC}
	  init			initialize first connection
	  mount			mount remote vault
	  umount		unmount remote vault
	  "
	exit
}

check() {
	if [ "$?" -ne 0 ]; then
		error "An error occurred while executing : $(fc -l -n -1)"
		exit
	fi
}

case $1 in

init)
	info "Downloading necessary packages"
	#sudo apt install sshfs; check && info "Packages successfully installed"
	info "Grabbing SSH key"
	scp -P $SSH_PORT $SSH_USER@$SSH_HOST:/home/$SSH_USER/.ssh/$SSH_KEY $HOME/.ssh/
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
	mkdir COFFRE
	sshfs -o reconnect VAULT:COFFRE COFFRE
	success "Vault successfully mounted"
	;;

umount)
	fusermount -u COFFRE
	rmdir COFFRE
	ssh -t VAULT "sudo umount COFFRE && sudo cryptsetup luksClose /dev/mapper/$ENC_LOGVOL"
	;;

-h | --help | --h)
	help
	;;
*)
	error "Invalid syntax try $0 -h"
	;;
esac