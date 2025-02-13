#!/bin/sh

su - www-data -s /bin/sh -c "php  /var/www/html/occ maintenance:update:htaccess"
/usr/local/bin/docker-php-entrypoint "$@"
