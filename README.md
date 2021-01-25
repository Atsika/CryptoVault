# CryptoVault - Encrypted remote vault

<p align="center">
  <img src="https://img.shields.io/badge/script-bash-green">  <img src="https://img.shields.io/badge/os-linux-blue">  <img src="https://img.shields.io/badge/made%20with-love-red">  <img src="https://img.shields.io/badge/secure-100%25-lightgrey"><br>
<img src="cryptovault.png">
 </p>

## Description

CryptoVault is a secure remote vault. 

Basically an encrypted logic volume is hosted on a server that you mount remotely on your machine.  

## Features

* Automatic vault installer
* AES-256-XTS encryption
* Chrooted
* Easy client script
* Pure bash

## Installation

### Server

```
git clone https://github.com/Atsika/CryptoVault.git
chmod +x cv_server.sh
```

### Client

```
git clone https://github.com/Atsika/CryptoVault.git
chmod +x cv_client.sh
```

## Usage

### Server

```
NAME 
	  CryptoVault - Create an encrypted vault (SERVER)
		  
SYNTAX
	  ./cv_server.sh [partition] [size] [user]
	  ex : ./cv_server.sh /dev/sda1 200 newuser
		  
PARAMETERS 
	  [partition]		partition for the vault
	  [size]		vault size in megabytes
	  [user]		new user for the vault
```

### Client

```
NAME 
	  CryptoVault - Manage an encrypted vault (CLIENT)
		  
SYNTAX
	  ./cv_client.sh [command]
	  ex : ./cv_client.sh init
		  
PARAMETERS 
	  [command]     Command to execute

COMMANDS
	  init			initialize first connection
	  mount			mount remote vault
	  umount		unmount remote vault
```

### TODO

* Fail2ban + persistence iptables
* Alert mail
* Add config files
* Symbolic link for cheat
* Documentation
