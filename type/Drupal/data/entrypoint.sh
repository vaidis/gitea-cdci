#!/bin/bash
mysqld_safe &
sleep 5

FILE="/var/www/html/drupal/web/sites/default/settings.php "
DATABASE=$(cat $FILE | grep "^  'database' => " | awk -F\' {'print $4'})
DATABASE=$(cat $FILE | grep "^  'username' => " | awk -F\' {'print $4'})
PASSWORD=$(cat $FILE | grep "^  'password' => " | awk -F\' {'print $4'})

mysql -e "CREATE DATABASE ${DATABASE};" 
mysql -e "CREATE USER ${DATABASE}@localhost IDENTIFIED BY \"1234\""
mysql -e "GRANT ALL ON ${DATABASE}.* TO ${DATABASE}@localhost"
mysql -e "FLUSH PRIVILEGES"

mysql ${DATABASE} < /data/database.sql

sed -i 's/localhost/127.0.0.1/g' ${FILE}

cd /var/www/html/drupal/web/
vendor/drush/drush/drush cr

apachectl -D FOREGROUND
