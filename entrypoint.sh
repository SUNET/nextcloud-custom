#!/bin/sh
set -e

su - www-data -s /bin/sh -c "php  /var/www/html/occ maintenance:update:htaccess"

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- apache2-foreground "$@"
fi

exec "$@"
