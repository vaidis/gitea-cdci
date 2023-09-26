#!/bin/bash

# -------------------------- !!! CHANGE ME !!! ----------
USER="stevaidis"
DB_ROOT_PASS="1234"
SERVER_IP="192.168.1.200"
# -------------------------------------------------------

if [ -z "${1}" ]; then echo -e "Project directory needed.\nExample: ./staging myproject4"; exit; fi
if [ ! -d "${1}" ]; then echo -e "Project directory ${1} not found"; exit; fi
cd ${1}
REPO=$(cat .git/config | grep "${SERVER_IP}" | awk -F/ {'print $NF'} | awk -F\. {'print $1'})
if [ -z "${REPO}" ]; then echo -e "Staging remote origin not found in .git/config"; exit; fi

R="\e[1;31m"
G="\e[1;32m"
B="\e[1;34m"
W="\e[0;97m"
E="\e[00m"

function log() {
  [ $1 == 0 ] && echo -e " ${G}[ OK ]${E}"; return
  echo -e " ${R}[FAIL]${E}"
  exit
}

echo
echo -e "⭐ ⭐ ⭐ ⭐ ⭐ ⭐ ⭐ ⭐ ⭐ ⭐ ⭐ ⭐ ⭐ ⭐ ⭐ ⭐ ⭐ ⭐ ⭐ ⭐ ⭐ ⭐ ⭐"
echo

echo -en " 📥 database ${B}$1${E} dump " 
mysqldump -uroot -p${DB_ROOT_PASS} ${1} > ${1}.sql
log $?

echo -en " 📂 check remote dir ${B}/home/${USER}/staging/${REPO}${E} "
ssh ${USER}@${SERVER_IP} mkdir -p /home/${USER}/staging/${REPO}
log $?

echo -en " 📦 copy ${B}database.sql${E} to server"
scp ${1}.sql ${USER}@${SERVER_IP}:/home/${USER}/staging/${REPO}/database.sql 2>&1> /dev/null
log $?

echo -en " 📦 copy ${B}settings.php${E} to server "
ssh ${USER}@${SERVER_IP} rm /home/${USER}/staging/${REPO}/settings.php -f
scp sites/default/settings.php ${USER}@${SERVER_IP}:/home/${USER}/staging/${REPO}/settings.php 2>&1> /dev/null
log $?

echo
echo -e " 🐞 ${R}git push staging${E}"
echo
# ------------------------------------------------------------
echo "#" >> .gitignore #       Uncomment for testing purposes
# ------------------------------------------------------------

echo -en "Execuite ${R}git add .${E} (y/n): "
read -n 1 answer
[ $answer != "y" ] && exit
echo
git add . ; [ $? -ne 0 ] && exit

echo -en "Execuite ${R}git commit -m 'changes to staging'${E} (y/n): "
read -n 1 answer
[ $answer != "y" ] && exit
echo
git commit -m "test staging push" ; [ $? -ne 0 ] && exit

echo -en "Execuite ${R}git push staging${E} (y/n): "
read -n 1 answer
[ $answer != "y" ] && exit
echo
git push staging

echo
echo -e "Vewing log file ${W}/var/log/gitea-cdci/${REPO}.log${E} on remote server: "
echo
ssh ${USER}@${SERVER_IP} tail -n 0 -f /var/log/gitea-cdci/${REPO}.log


