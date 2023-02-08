FROM debian:bullseye-slim

# Set Nextcloud download url here
ARG nc_download_url=https://download.nextcloud.com/.customers/server/24.0.9-2fa814e5/nextcloud-24.0.9-enterprise.zip

# Set app versions here
ARG drive_email_template_version=1.0.0
ARG gss_version=2.1.1
ARG loginpagebutton_version=1.0.0
ARG richdocuments_version=6.3.3
ARG theming_customcss_version=1.12.0
ARG twofactor_admin_version=4.1.9
ARG twofactor_totp_version=6.4.1
ARG twofactor_webauthn_version=0.3.3
ARG user_saml_version=5.1.2

# Should be no need to modify beyond this point, unless you need to patch something or add more apps
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
RUN apt-get update && apt-get upgrade -y && apt-get install -y wget gnupg2
RUN bash -c 'echo "deb https://packages.sury.org/php/ bullseye main" > /etc/apt/sources.list.d/sury-php.list'
RUN bash -c 'wget -qO - https://packages.sury.org/php/apt.gpg | apt-key add -'
RUN apt-get update && apt-get install -y  \
	apache2 \
	busybox \
	bzip2 \
  cron \
	libapache2-mod-php8.0 \
	libmagickcore-6.q16-6-extra \
	mariadb-client \
  patch \
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
RUN wget https://downloads.rclone.org/rclone-current-linux-amd64.deb \
	&& dpkg -i ./rclone-current-linux-amd64.deb \
	&& rm ./rclone-current-linux-amd64.deb && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /etc/apache2/mods-enabled/ \
	&& ln -s /etc/apache2/mods-available/rewrite.load  /etc/apache2/mods-enabled/ \
	&& ln -s /etc/apache2/mods-available/socache_shmcb.load /etc/apache2/mods-enabled/ \
	&& ln -s /etc/apache2/mods-available/ssl.conf /etc/apache2/mods-enabled/ \
	&& ln -s /etc/apache2/mods-available/ssl.load /etc/apache2/mods-enabled/
COPY --chown=root:root ./000-default.conf /etc/apache2/sites-available/
COPY --chown=root:root ./crontab /var/spool/cron/crontabs/www-data
COPY --chown=root:root ./cron.sh /cron.sh
RUN wget ${nc_download_url} -O /tmp/nextcloud.zip \
	&& cd /tmp && unzip /tmp/nextcloud.zip \
	&& mkdir -p /var/www/html/data && touch /var/www/html/data/.ocdata && mkdir /var/www/html/config \
	&& mkdir /var/www/html/custom_apps && cp -a /tmp/nextcloud/* /var/www/html && cp -a /tmp/nextcloud/.[^.]* /var/www/html \
	&& rm -rf /tmp/nextcloud && rm -rf /var/www/html/apps/globalsiteselector
RUN wget https://github.com/nextcloud/globalsiteselector/archive/refs/tags/v${gss_version}.tar.gz -O /tmp/globalsiteselector.tar.gz \
	&& cd /tmp && tar xfvz /tmp/globalsiteselector.tar.gz \
        && mv /tmp/globalsiteselector-* /var/www/html/apps/globalsiteselector
RUN wget https://github.com/nextcloud-releases/richdocuments/releases/download/v${richdocuments_version}/richdocuments-v${richdocuments_version}.tar.gz -O /tmp/richdocuments.tar.gz \
	&& cd /tmp && tar xfvz /tmp/richdocuments.tar.gz && mv /tmp/richdocuments /var/www/html/custom_apps 
RUN wget https://github.com/nextcloud-releases/twofactor_totp/releases/download/v${twofactor_totp_version}/twofactor_totp-v${twofactor_totp_version}.tar.gz -O /tmp/twofactor_totp.tar.gz \
	&& cd /tmp && tar xfvz /tmp/twofactor_totp.tar.gz && mv /tmp/twofactor_totp /var/www/html/custom_apps
# https://github.com/nextcloud/twofactor_webauthn#migration-from-two-factor-u2f
RUN wget https://github.com/nextcloud-releases/twofactor_webauthn/releases/download/v${twofactor_webauthn_version}/twofactor_webauthn-v${twofactor_webauthn_version}.tar.gz \
        -O /tmp/twofactor_webauthn.tar.gz \
	&& cd /tmp && tar xfvz /tmp/twofactor_webauthn.tar.gz && mv /tmp/twofactor_webauthn /var/www/html/custom_apps
RUN wget https://github.com/nextcloud-releases/user_saml/releases/download/v${user_saml_version}/user_saml-v${user_saml_version}.tar.gz -O /tmp/user_saml.tar.gz \
	&& cd /tmp && tar xfvz /tmp/user_saml.tar.gz && mv /tmp/user_saml /var/www/html/custom_apps 
RUN wget https://github.com/SUNET/drive-email-template/archive/refs/tags/${drive_email_template_version}.tar.gz -O /tmp/drive-email-template.tar.gz \
	&& cd /tmp && tar xfvz /tmp/drive-email-template.tar.gz && mv /tmp/drive-email-template-* /var/www/html/custom_apps/drive_email_template
RUN wget https://github.com/SUNET/loginpagebutton/archive/refs/tags/v.${loginpagebutton_version}.tar.gz -O /tmp/loginpagebutton.tar.gz \
	&& cd /tmp && tar xfvz /tmp/loginpagebutton.tar.gz && mv /tmp/loginpagebutton-* /var/www/html/custom_apps/loginpagebutton
RUN wget https://github.com/nextcloud-releases/twofactor_admin/releases/download/v${twofactor_admin_version}/twofactor_admin.tar.gz -O /tmp/twofactor_admin.tar.gz \
	&& cd /tmp && tar xfvz /tmp/twofactor_admin.tar.gz && mv /tmp/twofactor_admin /var/www/html/custom_apps/
RUN wget  https://github.com/juliushaertl/theming_customcss/releases/download/v${theming_customcss_version}/theming_customcss.tar.gz  -O /tmp/theming_customcss.tar.gz \
	&& cd /tmp && tar xfvz /tmp/theming_customcss.tar.gz && mv /tmp/theming_customcss /var/www/html/custom_apps/theming_customcss
RUN wget  https://github.com/pondersource/nc-sciencemesh/raw/main/release/sciencemesh.tar.gz -O /tmp/nc-sciencemesh.tar.gz \
	&& cd /tmp && tar xfvz /tmp/nc-sciencemesh.tar.gz && mv /tmp/sciencemesh /var/www/html/custom_apps/
COPY --chown=root:root ./nextcloud-rds.tar.gz /tmp
COPY ./31571.diff /var/www/html
RUN cd /tmp && tar xfv nextcloud-rds.tar.gz && mv rds/ /var/www/html/custom_apps
RUN cd /var/www/html && patch -p1 ./31571.diff
RUN rm -rf /tmp/*.tar.* &&  chown -R www-data:root /var/www/html && chmod +x /var/www/html/occ
RUN usermod -a -G tty www-data

