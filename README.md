# CryptoVault - Encrypted remote vault

<p align="center">
  <img src="https://img.shields.io/badge/script-bash-green">  <img src="https://img.shields.io/badge/os-linux-blue">  <img src="https://img.shields.io/badge/made%20with-love-red">  <img src="https://img.shields.io/badge/secure-100%25-lightgrey"><br>
<img src="cryptovault.png">
 </p>

## Description

CryptoVault is a secure remote vault. 

Basically an encrypted logic volume is hosted on a server that you mount remotely on your machine.  

## Features

* Automatic installer
* AES-256-XTS encryption
* Chrooted
* All-in-one client script
* Pure bash

## Installation

### Server

```
git clone https://github.com/Atsika/CryptoVault.git
cd CryptoVault
chmod +x cv_server.sh
```

### Client

```
git clone https://github.com/Atsika/CryptoVault.git
cd CryptoVault
chmod +x cv_client.sh
```

## Usage

### Server

```
NAME
	  CryptoVault - Create an encrypted vault (SERVER)
		  
SYNTAX
	  ./cv_server.sh
		  
IMPORTANT
	  Don't forget to fill variables at the top of the script.
	  Don't run this script as root.
	  Run it with a user that have sudo rights.
```

### Client

```
NAME
	  CryptoVault - Manage an encrypted vault (CLIENT)
		  
SYNTAX
	  ./cv_client.sh [command]
		  
PARAMETERS
	  [command]     Command to execute

COMMANDS
	  init			initialize first connection
	  mount			mount remote vault
	  umount		unmount remote vault

IMPORTANT
	  Don't forget to fill variables at the top of the script.
	  Don't run this script as root.
	  Run it with a user that have sudo rights.
```

### TODO

* Fail2ban + persistence iptables
* Alert mail
* Add config files
* Symbolic link for cheat
* Documentation
