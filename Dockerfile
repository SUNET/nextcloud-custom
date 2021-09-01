FROM ubuntu/apache2

RUN apt-get update && apt-get upgrade -y && apt-get install -y  \
	bzip2 \
	libapache2-mod-php \
	mariadb-client \
	php-apcu \
	php-imagick \
	php-redis \
	php7.4-bcmath \
	php7.4-curl \
	php7.4-gd \
	php7.4-gmp \
	php7.4-intl \
	php7.4-mbstring \
	php7.4-mysql \
	php7.4-xml \
	php7.4-zip \
	redis-tools \
	ssl-cert \
	vim \
	wget
RUN wget https://downloads.rclone.org/v1.56.0/rclone-v1.56.0-linux-amd64.deb \
	&& dpkg -i ./rclone-v1.56.0-linux-amd64.deb \
	&& rm ./rclone-v1.56.0-linux-amd64.deb && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /etc/apache2/mods-enabled/
RUN ln -s /etc/apache2/mods-available/socache_shmcb.load /etc/apache2/mods-enabled/
RUN ln -s /etc/apache2/mods-available/ssl.conf /etc/apache2/mods-enabled/
RUN ln -s /etc/apache2/mods-available/ssl.load /etc/apache2/mods-enabled/
COPY --chown=root:root ./000-default.conf /etc/apache2/sites-available/
COPY --chown=root:root ./crontab /var/spool/cron/crontabs/www-data
COPY --chown=root:root ./cron.sh /cron.sh
RUN wget https://download.nextcloud.com/server/releases/nextcloud-19.0.13.tar.bz2 -O /tmp/nextcloud.tar.bz2
RUN cd /tmp && tar xfvj /tmp/nextcloud.tar.bz2
RUN mkdir -p /var/www/html/data && touch /var/www/html/data/.ocdata
RUN mkdir -p /var/www/html/config
RUN mkdir -p /var/www/html/custom_apps
RUN cp -a /tmp/nextcloud/* /var/www/html && rm -rf /tmp/nextcloud* 
RUN chown -R www-data:root /var/www/html
RUN usermod -a -G tty www-data

