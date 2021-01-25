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
* Chrooted SFTP
* Easy client script
* Pure bash

## Installation

### Server

```
git clone https://github.com/Atsika/CryptoVault.git
chmod +x cv_server.sh
./cv_server.sh <partition> <size>
```

### Client

```
git clone https://github.com/Atsika/CryptoVault.git
chmod +x cv_client.sh
./cv_client.sh init
./cv_client.sh mount
./cv_client.sh umount
```

### TODO

* Fail2ban + persistence iptables
* Alert mail
* Add config files
* Symbolic link for cheat
* Documentation
