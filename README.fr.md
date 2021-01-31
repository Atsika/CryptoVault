# CryptoVault - Coffre chiffré distant 🔒

<p align="center">
  <img src="https://img.shields.io/badge/script-bash-green">  <img src="https://img.shields.io/badge/os-linux-blue">  <img src="https://img.shields.io/badge/made%20with-love-red">  <img src="https://img.shields.io/badge/secure-100%25-lightgrey"><br>
<img src="images/cryptovault.png">
 </p>

## Description

CryptoVault est un coffre chiffré distant permettant de stocker vos fichiers de manière sécurisée. 

## Fonctionnalités

* Installation automatique ⚙️
* Chiffrement AES-256-XTS
* Chroot
* Protection contre le bruteforce 👊
* Alerte par mail 📧
* Utilisation de blacklist 🏴
* Script client tout-en-un 1️⃣
* Pur bash 💯

## Installation

### Serveur

```bash
git clone https://github.com/Atsika/CryptoVault.git
cd CryptoVault
chmod +x cv_server.sh
```

### Client

```bash
git clone https://github.com/Atsika/CryptoVault.git
cd CryptoVault
chmod +x cv_client.sh
```

## Utilisation

Il existe 2 manières d'utiliser les scripts pour CryptoVault :
* Définir les variables en haut du script
* Saisir les valeurs lorsque le script le demande

> 💡 Si des variables ne sont pas définies, le script les demandera automatiquement lors de l'exécution.  
> Les variables portant le même nom dans le script client et serveur (en gras ci-dessous) doivent avoir la même valeur.  
> Il est recommandé de ne pas modifier les variables dans la sections 'CONSTANTS'.

⚠️ Le script serveur doit être lancé avec un utilisateur possèdant les **droits sudo** mais qui **n'est pas root**.  

### Variables

| Nom        | Description                                                           | Exemple      | Script        |
|------------|-----------------------------------------------------------------------|--------------|---------------|
| PARTITON   | Nom de la partition sur laquelle sera installé le coffre              | /dev/sda1    | serveur        |
| SIZE       | Taille du coffre en megaoctet (Mo)                                    | 200          | serveur        |
| VAULT_USER | Nom du nouvel utilisateur créé specialement pour la gestion du coffre | coffre       | serveur/client |
| SSH_KEY    | Nom des clés SSH générées pour le VAULT_USER                          | vault_key    | serveur/client |
| SSH_PORT   | Port sur lequel le service SSH doit écouter                           | 7222         | serveur/client |
| SSH_HOST   | Hôte qui héberge le coffre                                            | 192.168.1.10 | client        |
| SSH_USER   | Nom de l'utilisateur qui a exécuté le script serveur                  | admin        | client        |

> 💡 Il est recommandé de changer le port SSH pour des raisons de sécurité.

### Exécution

#### Serveur

`./cv_server.sh` &rarr; Installe et configure le serveur.

<p align="center"><img src="images/cv_server.gif"></p>

#### Client

`./cv_client.sh init` &rarr; Initialise la première connexion au coffre.  
`./cv_client.sh mount` &rarr; Déchiffre et ontre le coffre dans $HOME/COFFRE.  
`./cv_client umount` &rarr; Démonte le coffre et le chiffre.

<p align="center"><img src="images/cv_client.gif"></p>

## Fonctionnement

### Serveur

* Installation des paquets nécessaires  
* Configuration du serveur SMTP (Postfix) pour l'envoie d'alertes  
* Création de l'utilisateur dédié au coffre et attributions des droits (sudo)  
* Configuration des accès authentifiés par clé SSH  
* Création du volume physique  
* Création du groupe volume  
* Création et chiffrement du volume logique  
* Formatage du volume logique chiffré  
* Chroot de l'utilisateur dédié au coffre  
* Sécurisation du service SSH  
* Création de la structure du coffre  
* Déploiement des fichiers de configuration  
* Redémarrage des services affectés par le script

### Client

#### init

* Installation des paquets nécessaires 
* Récupération de la clé privée SSH
* Configuration de l'hôte SSH
* Création de lien symbolique (cheat)

#### mount

* Déchiffrement du coffre
* Montage du coffre dans $HOME/COFFRE

#### umount

* Démontage du coffre
* Chiffrement du coffre

<p align="center">Made with ❤️ by Atsika & Léco</p>
