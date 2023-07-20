FROM php:8.1-rc-apache-bullseye

# Set environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_DOCUMENT_ROOT /var/www/html
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_PID_FILE /var/run/apache2/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2

# Set Nextcloud download url here
ARG nc_download_url=https://download.nextcloud.com/.customers/server/26.0.3-336cf930/nextcloud-26.0.3-enterprise.zip

# Set app versions here
ARG announcementcenter_version=6.6.1
ARG checksum_version=1.2.2
ARG drive_email_template_version=1.0.0
ARG files_accesscontrol_version=1.16.0
ARG files_automatedtagging_version=1.16.1
ARG globalsiteselector_version=2.4.3
ARG login_notes_version=1.2.0
ARG loginpagebutton_version=1.0.0
ARG richdocuments_version=8.0.2
ARG theming_customcss_version=1.14.0
ARG twofactor_admin_version=4.2.0
ARG twofactor_webauthn_version=1.2.0

# Pre-requisites for the extensions
RUN set -ex; \
  apt-get -q update > /dev/null && apt-get -q install -y \
  freetype* \
  libgmp* \
  libicu* \
  libldap* \
  libmagickwand* \
  libmemcached* \
  libpng* \
  libpq* \
  libweb* \
  libzip* \
  zlib* \
  curl \
  gnupg2 \
  make \
  mariadb-client \
  npm \
  patch \
  redis-tools \
  ssl-cert \
  unzip \
  vim \
  wget > /dev/null

# PECL Modules
RUN pecl -q install apcu \
  imagick \
  memcached \
  redis > /dev/null

# Adjusting freetype message error
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp

# PHP Extensions needed
RUN docker-php-ext-install -j "$(nproc)" \
  pdo_mysql \
  bcmath \
  exif \
  gd \
  gmp \
  intl \
  ldap \
  opcache \
  pcntl \
  pdo_pgsql \
  sysvsem \
  zip

# More extensions
RUN docker-php-ext-enable \
  imagick \
  apcu \
  memcached \
  redis

# Enabling Modules
RUN a2enmod dir env headers mime rewrite setenvif deflate ssl

# Adjusting PHP settings
RUN { \
  echo 'opcache.interned_strings_buffer=32'; \
  echo 'opcache.save_comments=1'; \
  echo 'opcache.revalidate_freq=60'; \
  } > /usr/local/etc/php/conf.d/opcache-recommended.ini;

RUN { \
  echo 'extension=apcu.so'; \
  echo 'apc.enable_cli=1'; \
  } > /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini;

RUN { \
  echo 'memory_limit = 2G'; \
  } > /usr/local/etc/php/conf.d/memory_limit.ini;

# Update apache configuration for ServerName
RUN echo "ServerName localhost" | tee /etc/apache2/conf-available/servername.conf \
  && a2enconf servername

RUN sed 's/^ServerTokens OS/ServerTokens Prod/' /etc/apache2/conf-available/security.conf
RUN sed 's/^ServerSignature On/ServerSignature Off/' /etc/apache2/conf-available/security.conf

# Set permissions to allow non-root user to access necessary folders
RUN chmod -R 777 ${APACHE_RUN_DIR} ${APACHE_LOCK_DIR} ${APACHE_LOG_DIR} ${APACHE_DOCUMENT_ROOT}

# Should be no need to modify beyond this point, unless you need to patch something or add more apps
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
RUN wget -q https://downloads.rclone.org/rclone-current-linux-amd64.deb \
  && dpkg -i ./rclone-current-linux-amd64.deb \
  && rm ./rclone-current-linux-amd64.deb && rm -rf /var/lib/apt/lists/*
COPY --chown=root:root ./000-default.conf /etc/apache2/sites-available/
COPY --chown=root:root ./cron.sh /cron.sh

## DONT ADD STUFF BETWEEN HERE
RUN wget -q ${nc_download_url} -O /tmp/nextcloud.zip && cd /tmp && unzip -qq /tmp/nextcloud.zip && cd /tmp/nextcloud \
  && mkdir -p /var/www/html/data && touch /var/www/html/data/.ocdata && mkdir /var/www/html/config \
  && cp -a /tmp/nextcloud/* /var/www/html && cp -a /tmp/nextcloud/.[^.]* /var/www/html \
  && chown -R www-data:root /var/www/html && chmod +x /var/www/html/occ && rm -rf /tmp/nextcloud
RUN php /var/www/html/occ integrity:check-core
## AND HERE, OR CODE INTEGRITY CHECK MIGHT FAIL, AND IMAGE WILL NOT BUILD

## VARIOUS PATCHES COMES HERE IF NEEDED
COPY ./security-July-2023-26.patch /var/www/html/
COPY ./ignore_and_warn_on_non_numeric_version_timestamp.patch /var/www/html/
RUN cd /var/www/html/ \
  && patch -p1 < security-July-2023-26.patch \
  && patch -p1 < ignore_and_warn_on_non_numeric_version_timestamp.patch

## USE LOCAL GSS FOR NOW
RUN rm -rf /var/www/html/apps/globalsiteselector
COPY ./globalsiteselector-${globalsiteselector_version}.tar.gz /tmp/globalsiteselector.tar.gz
RUN cd /tmp && tar xf globalsiteselector.tar.gz && mv globalsiteselector /var/www/html/apps

## INSTALL APPS
RUN mkdir /var/www/html/custom_apps
RUN wget -q https://github.com/nextcloud-releases/announcementcenter/releases/download/v${announcementcenter_version}/announcementcenter-v${announcementcenter_version}.tar.gz  -O /tmp/announcementcenter.tar.gz \
  && cd /tmp && tar xf /tmp/announcementcenter.tar.gz && mv /tmp/announcementcenter /var/www/html/custom_apps/
RUN wget -q https://github.com/westberliner/checksum/releases/download/v${checksum_version}/checksum.tar.gz -O /tmp/checksum.tar.gz \
  && cd /tmp && tar xf /tmp/checksum.tar.gz && mv /tmp/checksum /var/www/html/custom_apps/
RUN wget -q https://github.com/SUNET/drive-email-template/archive/refs/tags/${drive_email_template_version}.tar.gz -O /tmp/drive-email-template.tar.gz \
  && cd /tmp && tar xf /tmp/drive-email-template.tar.gz && mv /tmp/drive-email-template-* /var/www/html/custom_apps/drive_email_template
RUN wget -q https://github.com/nextcloud-releases/files_accesscontrol/releases/download/v${files_accesscontrol_version}/files_accesscontrol-v${files_accesscontrol_version}.tar.gz -O /tmp/files_accesscontrol.tar.gz \
  && cd /tmp && tar xf /tmp/files_accesscontrol.tar.gz && mv /tmp/files_accesscontrol /var/www/html/custom_apps/
RUN wget -q https://github.com/nextcloud-releases/files_automatedtagging/releases/download/v${files_automatedtagging_version}/files_automatedtagging-v${files_automatedtagging_version}.tar.gz -O /tmp/files_automatedtagging.tar.gz \
  && cd /tmp && tar xf /tmp/files_automatedtagging.tar.gz && mv /tmp/files_automatedtagging /var/www/html/custom_apps/
RUN wget -q https://packages.framasoft.org/projects/nextcloud-apps/login-notes/login_notes-${login_notes_version}.tar.gz -O /tmp/login_notes.tar.gz \
  && cd /tmp && tar xf /tmp/login_notes.tar.gz && mv /tmp/login_notes /var/www/html/custom_apps/
RUN wget -q https://github.com/SUNET/loginpagebutton/archive/refs/tags/v.${loginpagebutton_version}.tar.gz -O /tmp/loginpagebutton.tar.gz \
  && cd /tmp && tar xf /tmp/loginpagebutton.tar.gz && mv /tmp/loginpagebutton-* /var/www/html/custom_apps/loginpagebutton
RUN wget -q https://github.com/nextcloud-releases/richdocuments/releases/download/v${richdocuments_version}/richdocuments-v${richdocuments_version}.tar.gz -O /tmp/richdocuments.tar.gz \
  && cd /tmp && tar xf /tmp/richdocuments.tar.gz && mv /tmp/richdocuments /var/www/html/custom_apps
RUN wget -q https://github.com/juliushaertl/theming_customcss/releases/download/v${theming_customcss_version}/theming_customcss.tar.gz  -O /tmp/theming_customcss.tar.gz \
  && cd /tmp && tar xf /tmp/theming_customcss.tar.gz && mv /tmp/theming_customcss /var/www/html/custom_apps/theming_customcss
RUN wget -q https://github.com/nextcloud-releases/twofactor_webauthn/releases/download/v${twofactor_webauthn_version}/twofactor_webauthn-v${twofactor_webauthn_version}.tar.gz \
  -O /tmp/twofactor_webauthn.tar.gz \
  && cd /tmp && tar xf /tmp/twofactor_webauthn.tar.gz && mv /tmp/twofactor_webauthn /var/www/html/custom_apps
RUN wget -q https://github.com/nextcloud-releases/twofactor_admin/releases/download/v${twofactor_admin_version}/twofactor_admin.tar.gz -O /tmp/twofactor_admin.tar.gz \
  && cd /tmp && tar xf /tmp/twofactor_admin.tar.gz && mv /tmp/twofactor_admin /var/www/html/custom_apps/

## INSTALL OUR APPS
RUN wget -q https://github.com/pondersource/nc-sciencemesh/archive/refs/heads/main.zip -O /tmp/nc-sciencemesh.zip \
  && cd /tmp && unzip /tmp/nc-sciencemesh.zip
RUN cd /tmp/nc-sciencemesh-main/ && make  && mv /tmp/nc-sciencemesh-main/ /var/www/html/custom_apps/sciencemesh
COPY --chown=root:root ./nextcloud-rds.tar.gz /tmp
RUN cd /tmp && tar xf nextcloud-rds.tar.gz && mv rds/ /var/www/html/custom_apps

## ADD www-data to tty group
RUN usermod -a -G tty www-data

# CLEAN UP
RUN apt remove -y wget curl make npm patch && apt autoremove -y
RUN rm -rf /tmp/*.tar.* && chown -R www-data:root /var/www/html
