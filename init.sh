#!/bin/bash

# Data from Gitea -> index.js -> init.sh
EVENT=$1
NAME=$2
TYPE=$3
REPO=$4
MAIL=$5
USER=$6

./type/${TYPE} ${1} ${2} ${3} ${4} ${5} ${6}

