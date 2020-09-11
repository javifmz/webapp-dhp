#!/bin/sh

if [ ! -f /www/web/index.html ]; then
  echo 'Web project files do not exist, copying them...'
  cp -r /app/web-base/* /www/web/
  echo 'Web project files copied'
fi

echo 'Initializing...'
sh /app/init.sh

echo 'Starting nginx...'
nginx -g 'daemon on;'

echo 'Starting php-fpm...'
php-fpm7 -D

echo 'Webapp started'
sh /app/start.sh
