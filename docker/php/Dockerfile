FROM naqoda/centos-apache-php

WORKDIR /var/lib/php/irepe/irepe-future

# install yarn
RUN curl -sL https://rpm.nodesource.com/setup_10.x | bash -
RUN yum install -y nodejs
RUN npm install -g yarn

# composer
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer
RUN composer self-update
RUN composer global require hirak/prestissimo

# deploy apache config
COPY irepe-future.conf /etc/httpd/conf.d/
