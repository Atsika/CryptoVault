# CryptoVault - Coffre chiffré distant

<p align="center">
  <img src="https://img.shields.io/badge/script-bash-green">  <img src="https://img.shields.io/badge/os-linux-blue">  <img src="https://img.shields.io/badge/made%20with-love-red">  <img src="https://img.shields.io/badge/secure-100%25-lightgrey"><br>
<img src="cryptovault.png">
 </p>

## Description

CryptoVault est un coffre chiffré distant permettant de stocker vos fichiers de manière sécurisée. 

Basically an encrypted logic volume is hosted on a server that you mount remotely on your machine.  

## Fonctionnalités

* Installateur automatique
* chiffrement AES-256-XTS
* Chrooté
* Script client tout-en-un
* Pur bash

## Installation

### Serveur

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

## Aide

### Serveur

```
NAME
	  CryptoVault - Create an encrypted vault (SERVER)
		  
SYNTAX
	  ./cv_server.sh
		  
IMPORTANT
	  You can set variables at the top of the script to avoid being prompted.
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

## Utilisation

Il existe 2 manières d'utiliser les scripts pour CryptoVault :
* Définir les variables en haut du script
* Saisir les valeurs lorsque le script le demande

> Si des variables ne sont pas définies, le script les demandera automatiquement lors de l'exécution.
> Les variables portant le même nom dans le script client et serveur (en gras ci-dessous) doivent avoir la même valeur.
> Il est recommandé de ne pas modifier les variables dans la sections 'CONSTANTS'.

### Serveur

#### Variables

Les variables à configurer dans le script serveur sont les suivantes :

* PARTITION : Nom de la partition sur laquelle sera installé le coffre.
    * ex : /dev/sda1

* SIZE : Taille du coffre en megaoctet (Mo).
    * ex : 200

* **VAULT_USER** : Nom du nouvel utilisateur créé specialement pour la gestion du coffre.
    * ex : coffre

* **SSH_KEY** : Nom des clés SSH générées pour le VAULT_USER.
    * ex : coffre_key

* **SSH_PORT** : Port sur lequel le service SSH doit écouter. Il est recommandé de le changer pour des raisons de sécurité.
    * ex : 7222

##### Exécution

Le script serveur doit être lancé avec un utilisateur possèdant les **droits sudo** mais qui **n'est pas root**.  

Pour lancer le script serveur, tapez `./cv_server.sh` dans un terminal.

### Client

#### Variables

Les variables à configurer dans le script client sont les suivantes :

* **SSH_KEY** : Nom des clés SSH générées pour le VAULT_USER.
    * ex : coffre_key

* SSH_USER : Nom de l'utilisateur qui a exécuté le script serveur.
    * ex : admin

* SSH_HOST : Hôte qui héberge le coffre.
    * ex : 192.168.1.10

* **SSH_PORT** : Port sur lequel le service SSH écoute.
    * ex : 7222

* **VAULT_USER** : Nom de l'utilisateur créé pour la gestion du coffre
    * ex : coffre

#### Exécution

Le script serveur doit être lancé avec un utilisateur possèdant les **droits sudo** mais qui **n'est pas root**.  

Le script client prend en paramêtre un argument :

* **init** : Initialise la première connexion au coffre.
* **mount** : Déchiffre et ontre le coffre dans $HOME/COFFRE.
* **umount** : Démonte le coffre et le chiffre.

## Fonctionnement

### Serveur

[text]

### Client

[text]
