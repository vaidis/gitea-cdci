# Simple CD/CI for Gitea

Executes a shell script on every repository action.

Things that must be configured:

1. Gitea configuration
2. Mutt smtp settings
3. Repository scripts
4. Systemd service

First clone the repository in `/opt` dir

```
git clone https://github.com/vaidis/gitea-cdci.git /opt/gitea-cdci
cd /opt/gitea-cdci
npm install
```

## 1. Gitea configuration

Add to gitea configuration the gitea-cdci IP address. If you install this project on the same host with the gitea, then its the same IP address.

:floppy_disk: `gitea/conf/app.ini`

```
[webhook]
QUEUE_LENGTH = 10000
DELIVER_TIMEOUT = 10
ALLOWED_HOST_LIST = 192.168.1.200
```


Go to a repository and create a **System Webhook** entry where you want to send the repository events for triggering the scripts

```
Target URL        : http://192.168.1.200:4444/webhook
```

#### :construction: Test webhook

Leave the netcat running, and send a test event from Gitea webhook, to verify that Gitea send events successfuly.

```
nc -l -p 4444
```

## 2. Email configuration

This project uses `mutt` to send report emails. The configuration bellow has been tested on Rocky Linux 9.2 and Zoho email servers

#### Install Depentencies

```
dnf install cyrus-sasl-plain mutt # for Rocky Linux 9.2
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

## 3. Systemd service

Make gitea-cdci start at boot automatically

```
chmod +x gitea-cdci.service
cp gitea-cdci.service /lib/systemd/system/

systemctl daemon-reload
systemctl start gitea-cdci
systemctl status gitea-cdci
systemctl enable gitea-cdci
```


## 4. Deploy a repository

### The workflow

1. You `git push` your code to a **Gitea repository**
2. **Gitea repository** recieves your push and triggers a webhook at `localhost:4444`
3. **Gitea-cdci** listens to `localhost:4444` and execute a **type script** for example `/type/drupal`
 
In **type script** you can copy files, test code, builds docker containers or whatever your repo needs



### Create a staging repository for myProject

`[!]` The **description string** in the Gitea repository must be exact the same name with the Gitea-cdci **type script**

1. Go to : https://192.168.1.200:3000/repo/create
    - Title : **myProject**
    - Description: **drupal**
2. Go to :  https://192.168.1.200:3000/myUser/myProject/settings/keys
    - Add the ssh public key of the user that used by the `staging.sh` in order to `git push` your code to this repo
    - Add the ssh key of the Gitea-cdci user that makes the `git clone`


3. Go to: https://192.168.1.200:3000/myUser/myProject/settings/hooks
    - Add Webhook > Gitea > Target URL: `http://192.168.1.200:4444/webhook`


### staging.sh

Automate things like database exports and copy settings files that they aren't in the repository. This example is about a DrupalCMS project. 
You can run locally `./staging-drupal.sh my-drupal-site` in order to:

1. **export** database locally
2. **copy** database and settings files to remote server
3. **push** you code
4. **watch** the remote log file

### Before running the staging.sh

2. In order the `staging.sh` can copy the `database.sql` and `settings.php` from your desktop to the remote server, you must create a user on the remote server with the same name as your local user, and copy the ssh public key to the remote server.

3. In order the `staging.sh` can `git push` your code from local to remote staging repository you must add the self-signed certificate of the **Gitea** url (https://192.168.1.200) to your local git client. First place the the self-signed certificate in a file on your home dir `~/gitea.pem`. Then:

```sh
git config --global --add safe.directory '*'                                 # allow self-signed certs
git config --global http."https://192.168.1.200:3000".sslCAInfo ~/gitea.pem  # add cert for secure push
cd myProject
git remote add staging https://192.168.1.200:3000/myUser/myProject.git       # add the second origin 
git push staging                                                             # push to staging without password
```

#### :construction: Test service

Now you can start using the `staging-drupal.sh`

Make some changes to the code and run `./staging-drupal.sh mydrupal-site`

Watch the progress and go to `http://192.168.1.200:5001` to see the project runing


### Todo:

- Run as different user
- More global functions for test and build javascript and python projects


