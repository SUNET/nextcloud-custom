FROM debian:bullseye-slim

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
RUN apt-get update && apt-get upgrade -y && apt-get install -y wget gnupg2 
RUN bash -c 'echo "deb https://packages.sury.org/php/ bullseye main" > /etc/apt/sources.list.d/sury-php.list'
RUN bash -c 'wget -qO - https://packages.sury.org/php/apt.gpg | apt-key add -'
RUN apt-get update && apt-get install -y  \
	apache2 \
	build-essential \
	busybox \
	bzip2 \
        cron \
	libapache2-mod-php8.0 \
	libmagickcore-6.q16-6-extra \
	mariadb-client \
	php8.0-apcu \
	php8.0-imagick \
	php8.0-redis \
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
	vim 
RUN wget https://downloads.rclone.org/v1.59.1/rclone-v1.59.1-linux-amd64.deb \
	&& dpkg -i ./rclone-v1.59.1-linux-amd64.deb \
	&& rm ./rclone-v1.59.1-linux-amd64.deb && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /etc/apache2/mods-enabled/ \
	&& ln -s /etc/apache2/mods-available/rewrite.load  /etc/apache2/mods-enabled/ \
	&& ln -s /etc/apache2/mods-available/socache_shmcb.load /etc/apache2/mods-enabled/ \
	&& ln -s /etc/apache2/mods-available/ssl.conf /etc/apache2/mods-enabled/ \
	&& ln -s /etc/apache2/mods-available/ssl.load /etc/apache2/mods-enabled/
COPY --chown=root:root ./000-default.conf /etc/apache2/sites-available/
COPY --chown=root:root ./crontab /var/spool/cron/crontabs/www-data
COPY --chown=root:root ./cron.sh /cron.sh
RUN wget https://download.nextcloud.com/.customers/server/23.0.8-a3c33df1/nextcloud-23.0.8-enterprise.zip -O /tmp/nextcloud.zip \
	&& cd /tmp && unzip /tmp/nextcloud.zip \
	&& mkdir -p /var/www/html/data && touch /var/www/html/data/.ocdata && mkdir /var/www/html/config \
	&& mkdir /var/www/html/custom_apps && cp -a /tmp/nextcloud/* /var/www/html && cp -a /tmp/nextcloud/.[^.]* /var/www/html \
	&& rm -rf /tmp/nextcloud && rm -rf /var/www/html/apps/globalsiteselector
RUN wget https://github.com/SUNET/globalsiteselector/archive/refs/tags/v2.0.0-sunet1.tar.gz -O /tmp/globalsiteselector.tar.gz \
	&& cd /tmp && tar xfvz /tmp/globalsiteselector.tar.gz \
        && mv /tmp/globalsiteselector-* /var/www/html/apps/globalsiteselector
RUN wget https://github.com/nextcloud-releases/richdocuments/releases/download/v5.0.7/richdocuments-v5.0.7.tar.gz -O /tmp/richdocuments.tar.gz \
	&& cd /tmp && tar xfvz /tmp/richdocuments.tar.gz && mv /tmp/richdocuments /var/www/html/custom_apps 
RUN wget https://github.com/nextcloud-releases/twofactor_totp/releases/download/v6.4.0/twofactor_totp-v6.4.0.tar.gz -O /tmp/twofactor_totp.tar.gz \
	&& cd /tmp && tar xfvz /tmp/twofactor_totp.tar.gz && mv /tmp/twofactor_totp /var/www/html/custom_apps
# https://github.com/nextcloud/twofactor_webauthn#migration-from-two-factor-u2f
RUN wget https://github.com/nextcloud-releases/twofactor_webauthn/releases/download/v0.3.1/twofactor_webauthn-v0.3.1.tar.gz \
        -O /tmp/twofactor_webauthn.tar.gz \
	&& cd /tmp && tar xfvz /tmp/twofactor_webauthn.tar.gz && mv /tmp/twofactor_webauthn /var/www/html/custom_apps
RUN wget https://github.com/nextcloud-releases/user_saml/releases/download/v5.0.2/user_saml-v5.0.2.tar.gz -O /tmp/user_saml.tar.gz \
	&& cd /tmp && tar xfvz /tmp/user_saml.tar.gz && mv /tmp/user_saml /var/www/html/custom_apps 
RUN wget https://github.com/SUNET/drive-email-template/archive/refs/tags/1.0.0.tar.gz -O /tmp/drive-email-template.tar.gz \
	&& cd /tmp && tar xfvz /tmp/drive-email-template.tar.gz && mv /tmp/drive-email-template-* /var/www/html/custom_apps/drive_email_template
RUN wget https://github.com/SUNET/loginpagebutton/archive/refs/tags/v.1.0.0.tar.gz -O /tmp/loginpagebutton.tar.gz \
	&& cd /tmp && tar xfvz /tmp/loginpagebutton.tar.gz && mv /tmp/loginpagebutton-* /var/www/html/custom_apps/loginpagebutton
RUN wget https://github.com/ChristophWurst/twofactor_admin/releases/download/v3.2.0/twofactor_admin.tar.gz -O /tmp/twofactor_admin.tar.gz \
	&& cd /tmp && tar xfvz /tmp/twofactor_admin.tar.gz && mv /tmp/twofactor_admin /var/www/html/custom_apps/
RUN wget https://github.com/pondersource/nextcloud-mfa-awareness/archive/ecde2da7ab9f8ada5ca7e5976d99080e5e2b33ec.tar.gz -O /tmp/nextcloud-mfa-awareness.tar.gz \
	&& cd /tmp && tar xfvz /tmp/nextcloud-mfa-awareness.tar.gz && mv /tmp/nextcloud-mfa-awareness-ecde2da7ab9f8ada5ca7e5976d99080e5e2b33ec/mfachecker  /var/www/html/custom_apps/ && cd /var/www/html/custom_apps/mfachecker && make build && apt remove build-essential
RUN rm -rf /tmp/*.tar.* &&  chown -R www-data:root /var/www/html && chmod +x /var/www/html/occ
RUN usermod -a -G tty www-data

