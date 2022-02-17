FROM ubuntu/apache2

RUN apt-get update && apt-get upgrade -y && apt-get install -y  \
	busybox \
	bzip2 \
        cron \
	libapache2-mod-php \
	libmagickcore-6.q16-6-extra \
	mariadb-client \
	php-apcu \
	php-imagick \
	php-redis \
	php8.0-bcmath \
	php8.0-curl \
	php8.0-gd \
	php8.0-gmp \
	php8.0-intl \
	php8.0-mbstring \
	php8.0-mysql \
	php8.0-xml \
	php8.0-zip \
	redis-tools \
	ssl-cert \
	unzip \
	vim \
	wget
RUN wget https://downloads.rclone.org/v1.57.0/rclone-v1.57.0-linux-amd64.deb \
	&& dpkg -i ./rclone-v1.57.0-linux-amd64.deb \
	&& rm ./rclone-v1.57.0-linux-amd64.deb && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /etc/apache2/mods-enabled/ \
	&& ln -s /etc/apache2/mods-available/rewrite.load  /etc/apache2/mods-enabled/ \
	&& ln -s /etc/apache2/mods-available/socache_shmcb.load /etc/apache2/mods-enabled/ \
	&& ln -s /etc/apache2/mods-available/ssl.conf /etc/apache2/mods-enabled/ \
	&& ln -s /etc/apache2/mods-available/ssl.load /etc/apache2/mods-enabled/
COPY --chown=root:root ./000-default.conf /etc/apache2/sites-available/
COPY --chown=root:root ./crontab /var/spool/cron/crontabs/www-data
COPY --chown=root:root ./cron.sh /cron.sh
RUN wget https://download.nextcloud.com/.customers/server/21.0.6-677dff24/nextcloud-21.0.6-enterprise.zip -O /tmp/nextcloud.zip \
	&& cd /tmp && unzip /tmp/nextcloud.zip \
	&& mkdir -p /var/www/html/data && touch /var/www/html/data/.ocdata && mkdir /var/www/html/config \
	&& mkdir /var/www/html/custom_apps && cp -a /tmp/nextcloud/* /var/www/html && cp -a /tmp/nextcloud/.[^.]* /var/www/html \
	&& rm -rf /tmp/nextcloud && rm -rf /var/www/html/apps/globalsiteselector
RUN wget https://github.com/SUNET/globalsiteselector/archive/refs/tags/v2.0.0-sunet1.tar.gz -O /tmp/globalsiteselector.tar.gz \
	&& cd /tmp && tar xfvz /tmp/globalsiteselector.tar.gz \
        && mv /tmp/globalsiteselector-* /var/www/html/apps/globalsiteselector
RUN wget https://github.com/ONLYOFFICE/onlyoffice-nextcloud/releases/download/v7.2.0/onlyoffice.tar.gz -O /tmp/onlyoffice.tar.gz \
	&& cd /tmp && tar xfvz /tmp/onlyoffice.tar.gz && mv /tmp/onlyoffice /var/www/html/custom_apps 
RUN wget https://github.com/nextcloud-releases/richdocuments/releases/download/v4.2.3/richdocuments.tar.gz -O /tmp/richdocuments.tar.gz \
	&& cd /tmp && tar xfvz /tmp/richdocuments.tar.gz && mv /tmp/richdocuments /var/www/html/custom_apps 
RUN wget https://github.com/nextcloud-releases/twofactor_totp/releases/download/v6.1.0/twofactor_totp.tar.gz -O /tmp/twofactor_totp.tar.gz \
	&& cd /tmp && tar xfvz /tmp/twofactor_totp.tar.gz && mv /tmp/twofactor_totp /var/www/html/custom_apps 
RUN wget https://github.com/nextcloud-releases/twofactor_u2f/releases/download/v6.2.0/twofactor_u2f.tar.gz -O /tmp/twofactor_u2f.tar.gz \
	&& cd /tmp && tar xfvz /tmp/twofactor_u2f.tar.gz && mv /tmp/twofactor_u2f /var/www/html/custom_apps 
RUN wget https://github.com/nextcloud/user_saml/releases/download/v4.1.1/user_saml-4.1.1.tar.gz -O /tmp/user_saml.tar.gz \
	&& cd /tmp && tar xfvz /tmp/user_saml.tar.gz && mv /tmp/user_saml /var/www/html/custom_apps 
RUN wget https://github.com/SUNET/drive-email-template/archive/refs/tags/1.0.0.tar.gz -O /tmp/drive-email-template.tar.gz \
	&& cd /tmp && tar xfvz /tmp/drive-email-template.tar.gz && mv /tmp/drive-email-template-* /var/www/html/custom_apps/drive_email_template
RUN wget https://github.com/SUNET/loginpagebutton/archive/refs/tags/v.1.0.0.tar.gz -O /tmp/loginpagebutton.tar.gz \
	&& cd /tmp && tar xfvz /tmp/loginpagebutton.tar.gz && mv /tmp/loginpagebutton-* /var/www/html/custom_apps/loginpagebutton
RUN wget https://github.com/ChristophWurst/twofactor_admin/releases/download/v3.2.0/twofactor_admin.tar.gz -O /tmp/twofactor_admin.tar.gz \
	&& cd /tmp && tar xfvz /tmp/twofactor_admin.tar.gz && mv /tmp/twofactor_admin /var/www/html/custom_apps/
RUN rm -rf /tmp/*.tar.* &&  chown -R www-data:root /var/www/html && chmod +x /var/www/html/occ
RUN usermod -a -G tty www-data

