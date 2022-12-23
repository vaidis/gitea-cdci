# Simple CD/CI for Gitea

Executes a shell script on every repository action.

Things that must be configured:

1. Gitea configuration
2. Mutt smtp settings
3. Repository scripts
4. Systemd service

First clone the repository in `/opt` dir

```
git clone https://git.vaidis.eu/stevaidis/gitea-cdci.git /opt/gitea-cdci
cd /opt/gitea-cdci
npm install
```

### 1. Gitea configuration

Add to gitea configuration the gitea-cdci IP address. If you install this project on the same host with the gitea, then its the same IP address.

:floppy_disk: `gitea/conf/app.ini`

```
[webhook]
QUEUE_LENGTH = 10000
DELIVER_TIMEOUT = 10
ALLOWED_HOST_LIST = 192.168.1.110
```


Go to `https://example/admin/system-hooks/gitea/new` and create a **System Webhook** entry where you want to send the repository events for triggering the scripts

```
Target URL        : http://192.168.1.110/webhook
HTTP Method       : POST
POST Content Type : application/json
Trigger On        : All Events
Active            : Enable
```

#### :construction: Test webhook

Leave the netcat running, and send a test event from Gitea webhook, to verify that Gitea send events successfuly.

```
nc -l -p 4444
```

### 2. Email configuration

This project uses `mutt` to send report emails. The configuration bellow has been tested on Centos 9 Stream and Zoho email servers

#### Install Depentencies

```
dnf install cyrus-sasl-plain mutt # for Centos 9 Stream
```

#### Configure mutt

:floppy_disk: `muttrc`

```bash
# need to change
set from="My own email <myemail@mydomain.me>"
set realname = "My Real Name"
set my_user="myemail@mydomain.me"
set my_pass="ABDC1234"

# no need to change
set ssl_starttls=yes
set ssl_force_tls=yes
set smtp_url = "smtp://$my_user:$my_pass@smtp.zoho.eu:587"
```

#### :construction: Test email 

Use the configuration file to send a test email

```
echo test | mutt -F ./muttrc some.reciever@gmail.com
```

### 3. Repository scripts

- Write your global variables and functions in the `repos.global` according your needs
- Write a shell script for every repository in the `repos/` (ex: `repos/my-repo-name`) to Test, Build and Deploy your code

A repo script example for a static web page could be something like

:floppy_disk: `repos/my-repo-name`

```bash
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
    before_all ${NAME}               # GLOBAL FUNCTION
    git clone $REPO /tmp/repos/$NAME # 1. COPY FROM GIT
    rsync \                          # 2. PASTE TO PRODUCTION
       -a \
       --stats \
       --human-readable \
       --include ".*" \
       --delete \
       "/tmp/repos/${NAME}/" \
       "$DESTINATION" >> $LOG        # GLOBAL VARIABLE
    send_mail ${NAME} ${MAIL}        # GLOBAL FUNCTION
    after_all ${NAME}                # GLOBAL FUNCTION
fi
```

#### :construction: Test the scripts

Make some changes to the repository, and run the script manually to deploy the changes to production

```
# repo-script <event> <repo name> <clone url> <email>
bash repo/my-repo push my-repo https://git.vaidis.eu/stevaidis/my-repo.git repo.owner@gmail.com
```

### 4. Systemd service

Make gitea-cdci start at boot automatically

```
chmod +x gitea-cdci.service
cp gitea-cdci.service /lib/systemd/system/

systemctl daemon-reload
systemctl start gitea-cdci
systemctl status gitea-cdci
systemctl enable gitea-cdci
```

#### :construction: Test service

Reboot your server and test if:

1. The service is started automatically
2. The `/var/log/messages` shows the recieving events from gitea
3. The new code is deployed to your production server

### Todo:

- Run as different user
- More global functions for test and build javascript and python projects

