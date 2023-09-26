#!/bin/bash

# Data from Gitea
EVENT=$1
NAME=$2
REPO=$3
MAIL=$4

# Global variables and functions
. ./repos.global

# PUSH event actions
if [[ $EVENT -eq 'push' ]]; then
    before_all ${NAME}         # GLOBAL FUNCTION
    git clone $REPO /tmp/repos/$NAME
    rsync \
       -a \
       --stats \
       --human-readable \
       --include ".*" \
       --delete \
       "/tmp/repos/${NAME}/" \
       "$DESTINATION" >> $LOG  # GLOBAL VARIABLE
    send_mail ${NAME} ${MAIL}  # GLOBAL FUNCTION
    after_all ${NAME}          # GLOBAL FUNCTION
fi

