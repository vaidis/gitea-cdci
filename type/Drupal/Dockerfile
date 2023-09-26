FROM ubuntu:22.10

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y build-essential && \
  apt-get install -y software-properties-common && \
  apt-get install -y vim byobu curl git htop man unzip vim wget net-tools lsof && \
  rm -rf /var/lib/apt/lists/*

RUN apt-get update \
  && apt-get install -y mysql-server \
  && sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mysql/mysql.conf.d/mysqld.cnf \
  && chown -R mysql:mysql /var/run/mysqld

RUN echo "tzdata tzdata/Areas select Europe" > /tmp/preseed.txt; \
  echo "tzdata tzdata/Zones/Europe select Athens" >> /tmp/preseed.txt; \
  debconf-set-selections /tmp/preseed.txt && \
  apt-get update && \
  apt-get install -y tzdata

RUN set -ex; \
  apt-get install -y apache2 && \
  mkdir /var/run/apache2/

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_PID_FILE /var/run/apache2/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_CONFDIR /etc/apache2
ENV COMPOSER_ALLOW_SUPERUSER 1

RUN set -ex; \
  apt-get install -y php8.1 php8.1-cli php8.1-common && \
  apt-get install -y php8.1-curl php8.1-gd php8.1-mbstring php8.1-mysql php8.1-opcache php8.1-readline && \
  apt-get install -y php8.1-sqlite3 php8.1-xml php8.1-apcu && \
  apt-get install -y php8.1-zip php8.1-xml php8.1-bcmath php8.1-soap

  # sed -i 's/;extension=curl/extension=curl/g' /etc/php/8.1/cli/php.ini

ADD ./data /data
ADD ./web /var/www/html/drupal/web
COPY /data/settings.php /var/www/html/drupal/web/sites/default/settings.php
COPY /data/000-default.conf /etc/apache2/sites-enabled/000-default.conf

WORKDIR /var/www/html/drupal/web

RUN set -ex; \
  curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin -- --filename=composer && \
  composer --no-interaction install

RUN chown www-data:www-data -R /var/www/html

EXPOSE 3306
EXPOSE 443
EXPOSE 80

ENTRYPOINT ["/data/entrypoint.sh"]

