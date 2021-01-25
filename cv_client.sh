#!/bin/bash

# Author 		  : Alexandre NESIC
# Description	: Monte et démonte un coffre distant
# Param1		  : mount -> monte le coffre
#				        umount -> démonte le coffre

############# VARIABLES ##############

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'
BOLD=$(tput bold)
NORM=$(tput sgr0)

SSH_KEY=$HOME/.ssh/vault_rsa
SSH_USER=user
SSH_HOST=192.168.82.131
SSH_PORT=7222

VAULT_USER=coffre

VOLGROUP="VGROOT"
LOGVOLUME="lv_coffre"
CLVOL="${LOGVOLUME}_encrypt"

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
	info "Generating SSH keys"
	ssh-keygen -b 4096 -f $SSH_KEY; check
	echo "
Host USER
	Hostname $SSH_HOST
	User $SSH_USER
	Port $SSH_PORT
	IdentityFile $SSH_KEY
	
Host COFFRE
	Hostname $SSH_HOST
	User $VAULT_USER
	Port $SSH_PORT
	IdentityFile $SSH_KEY" >> $HOME/.ssh/config
	PUB_KEY=$(cat $SSH_KEY.pub)
	info "Adding SSH keys to remote host"
	ssh -t USER "sudo cryptsetup luksOpen /dev/$VOLGROUP/$LOGVOLUME $CLVOL && sudo mount -v /dev/mapper/$CLVOL /home/$SSH_USER/COFFRE && sudo sh -c 'echo $PUB_KEY >> /home/$SSH_USER/.ssh/authorized_keys && echo $PUB_KEY >> /home/$SSH_USER/COFFRE/.ssh/authorized_keys' && sudo umount -v /home/$SSH_USER/COFFRE && sudo cryptsetup luksClose /dev/mapper/$CLVOL"
	success "Initialization finished. You can now mount the vault"
	;;

mount)
	info "Decrypting vault"
	ssh -t USER "sudo cryptsetup luksOpen /dev/$VOLGROUP/$LOGVOLUME $CLVOL && sudo mount -v /dev/mapper/$CLVOL /home/$SSH_USER/COFFRE"
	success "Vault successfully decrypted"
	mkdir COFFRE
	sshfs -o reconnect COFFRE: COFFRE
	success "Vault successfully mounted"
	;;

umount)
	fusermount -u COFFRE
	rmdir COFFRE
	ssh -t USER "sudo umount -v /home/$SSH_USER/COFFRE && sudo cryptsetup luksClose /dev/mapper/$CLVOL"
	;;

-h | --help | --h)
	help
	;;
*)
	error "Invalid syntax try $0 -h"
	;;
esac
