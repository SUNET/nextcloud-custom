FROM ubuntu/apache2

RUN apt-get update && apt-get upgrade -y && apt-get install -y  \
	busybox \
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
RUN mkdir -p /etc/apache2/mods-enabled/ \
	&& ln -s /etc/apache2/mods-available/socache_shmcb.load /etc/apache2/mods-enabled/ \
	&& ln -s /etc/apache2/mods-available/ssl.conf /etc/apache2/mods-enabled/ \
	&& ln -s /etc/apache2/mods-available/ssl.load /etc/apache2/mods-enabled/
COPY --chown=root:root ./000-default.conf /etc/apache2/sites-available/
COPY --chown=root:root ./crontab /var/spool/cron/crontabs/www-data
COPY --chown=root:root ./cron.sh /cron.sh
RUN wget https://download.nextcloud.com/server/releases/nextcloud-21.0.4.tar.bz2 -O /tmp/nextcloud.tar.bz2 \
	&& cd /tmp && tar xfvj /tmp/nextcloud.tar.bz2 \
	&& mkdir -p /var/www/html/data && touch /var/www/html/data/.ocdata && mkdir /var/www/html/config \
	&& mkdir /var/www/html/custom_apps && cp -a /tmp/nextcloud/* /var/www/html && rm -rf /tmp/nextcloud 
RUN wget https://github.com/nextcloud/globalsiteselector/archive/refs/tags/v1.4.0.tar.gz -O /tmp/globalsiteselector.tar.gz \
	&& cd /tmp && tar xfvz /tmp/globalsiteselector.tar.gz \
        && mv /tmp/globalsiteselector-1.4.0 /var/www/html/custom_apps/globalsiteselector \
	&& sed -i -e "s/Type::BIGINT/'bigint'" -e "s/Type::STRING/'string'" /var/www/html/custom_apps/globalsiteselector/lib/Migration/Version0110Date20180925143400.php
RUN wget https://github.com/ONLYOFFICE/onlyoffice-nextcloud/releases/download/v7.1.2/onlyoffice.tar.gz -O /tmp/onlyoffice.tar.gz \
	&& cd /tmp && tar xfvz /tmp/onlyoffice.tar.gz && mv /tmp/onlyoffice /var/www/html/custom_apps 
RUN wget https://github.com/nextcloud-releases/richdocuments/releases/download/v4.2.3/richdocuments.tar.gz -O /tmp/richdocuments.tar.gz \
	&& cd /tmp && tar xfvz /tmp/richdocuments.tar.gz && mv /tmp/richdocuments /var/www/html/custom_apps 
RUN wget https://github.com/nextcloud-releases/twofactor_totp/releases/download/v6.1.0/twofactor_totp.tar.gz -O /tmp/twofactor_totp.tar.gz \
	&& cd /tmp && tar xfvz /tmp/twofactor_totp.tar.gz && mv /tmp/twofactor_totp /var/www/html/custom_apps 
RUN wget https://github.com/nextcloud-releases/twofactor_u2f/releases/download/v6.2.0/twofactor_u2f.tar.gz -O /tmp/twofactor_u2f.tar.gz \
	&& cd /tmp && tar xfvz /tmp/twofactor_u2f.tar.gz && mv /tmp/twofactor_u2f /var/www/html/custom_apps 
RUN wget https://github.com/nextcloud/user_saml/releases/download/v4.1.1/user_saml-4.1.1.tar.gz -O /tmp/user_saml.tar.gz \
	&& cd /tmp && tar xfvz /tmp/user_saml.tar.gz && mv /tmp/user_saml /var/www/html/custom_apps 
RUN rm -rf /tmp/*.tar.* &&  chown -R www-data:root /var/www/html && chmod +x /var/www/html/occ
RUN usermod -a -G tty www-data

