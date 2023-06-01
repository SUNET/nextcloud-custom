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
ARG nc_download_url=https://download.nextcloud.com/.customers/server/26.0.2-8dbf9b02/nextcloud-26.0.2-enterprise.zip

# Set app versions here
ARG checksum_version=1.2.1
ARG drive_email_template_version=1.0.0
ARG local_user_saml_version=5.1.3-beta2
ARG local_gss_version=2.1.1
ARG loginpagebutton_version=1.0.0
ARG richdocuments_version=8.0.1
ARG theming_customcss_version=1.13.0
ARG twofactor_admin_version=4.1.9
ARG twofactor_webauthn_version=1.1.2

# Pre-requisites for the extensions
RUN set -ex; \
  apt-get update && apt-get install -y \
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
  wget

# PECL Modules
RUN pecl install apcu \
  pecl install imagick \
  pecl install memcached \
  pecl install redis \
  pecl install sysvsem

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
  } > /usr/local/etc/php/conf.d/opcache-recommended.ini; \
  \
  echo 'extension=apcu.so'; \
  echo 'apc.enable_cli=1' >> /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini;

# Update apache configuration for ServerName
RUN echo "ServerName localhost" | tee /etc/apache2/conf-available/servername.conf \
  && a2enconf servername

# Set permissions to allow non-root user to access necessary folders
RUN chmod -R 777 ${APACHE_RUN_DIR} ${APACHE_LOCK_DIR} ${APACHE_LOG_DIR} ${APACHE_DOCUMENT_ROOT}

# Should be no need to modify beyond this point, unless you need to patch something or add more apps
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
RUN wget https://downloads.rclone.org/rclone-current-linux-amd64.deb \
  && dpkg -i ./rclone-current-linux-amd64.deb \
  && rm ./rclone-current-linux-amd64.deb && rm -rf /var/lib/apt/lists/*
COPY --chown=root:root ./000-default.conf /etc/apache2/sites-available/
COPY --chown=root:root ./cron.sh /cron.sh

## DONT ADD STUFF BETWEEN HERE
RUN wget ${nc_download_url} -O /tmp/nextcloud.zip && cd /tmp && unzip /tmp/nextcloud.zip && cd /tmp/nextcloud \
  && mkdir -p /var/www/html/data && touch /var/www/html/data/.ocdata && mkdir /var/www/html/config \
  && cp -a /tmp/nextcloud/* /var/www/html && cp -a /tmp/nextcloud/.[^.]* /var/www/html \
  && chown -R www-data:root /var/www/html && chmod +x /var/www/html/occ &&rm -rf /tmp/nextcloud
RUN php /var/www/html/occ integrity:check-core
## AND HERE, OR CODE INTEGRITY CHECK MIGHT FAIL, AND IMAGE WILL NOT BUILD

## VARIOUS PATCHES COMES HERE IF NEEDED
COPY ./ignore_and_warn_on_non_numeric_version_timestamp.patch /var/www/html/
COPY ./redis-atomic-stable26.patch /var/www/html/
RUN cd /var/www/html/ \
  && patch -p1 < ignore_and_warn_on_non_numeric_version_timestamp.patch \
  && patch -p1 < redis-atomic-stable26.patch 

## Install apps from local sources inplace of bundled apps
# usersaml
# RUN rm -rf /var/www/html/apps/user_saml
# COPY ./user_saml-${local_user_saml_version}.tar.gz /tmp/user_saml.tar.gz
# RUN cd /tmp && tar xfvz user_saml.tar.gz && mv user_saml /var/www/html/apps/user_saml
#gss
RUN rm -rf /var/www/html/apps/globalsiteselector
COPY ./globalsiteselector-${local_gss_version}.tar.gz /tmp/globalsiteselector.tar.gz
RUN cd /tmp && tar xfvz globalsiteselector.tar.gz && mv globalsiteselector-${local_gss_version} /var/www/html/apps/globalsiteselector

## INSTALL APPS
RUN mkdir /var/www/html/custom_apps
RUN wget https://github.com/nextcloud-releases/richdocuments/releases/download/v${richdocuments_version}/richdocuments-v${richdocuments_version}.tar.gz -O /tmp/richdocuments.tar.gz \
  && cd /tmp && tar xfvz /tmp/richdocuments.tar.gz && mv /tmp/richdocuments /var/www/html/custom_apps 
RUN wget https://github.com/nextcloud-releases/twofactor_webauthn/releases/download/v${twofactor_webauthn_version}/twofactor_webauthn-v${twofactor_webauthn_version}.tar.gz \
  -O /tmp/twofactor_webauthn.tar.gz \
  && cd /tmp && tar xfvz /tmp/twofactor_webauthn.tar.gz && mv /tmp/twofactor_webauthn /var/www/html/custom_apps
RUN wget https://github.com/SUNET/drive-email-template/archive/refs/tags/${drive_email_template_version}.tar.gz -O /tmp/drive-email-template.tar.gz \
  && cd /tmp && tar xfvz /tmp/drive-email-template.tar.gz && mv /tmp/drive-email-template-* /var/www/html/custom_apps/drive_email_template
RUN wget https://github.com/SUNET/loginpagebutton/archive/refs/tags/v.${loginpagebutton_version}.tar.gz -O /tmp/loginpagebutton.tar.gz \
  && cd /tmp && tar xfvz /tmp/loginpagebutton.tar.gz && mv /tmp/loginpagebutton-* /var/www/html/custom_apps/loginpagebutton
RUN wget https://github.com/nextcloud-releases/twofactor_admin/releases/download/v${twofactor_admin_version}/twofactor_admin.tar.gz -O /tmp/twofactor_admin.tar.gz \
  && cd /tmp && tar xfvz /tmp/twofactor_admin.tar.gz && mv /tmp/twofactor_admin /var/www/html/custom_apps/
RUN wget  https://github.com/juliushaertl/theming_customcss/releases/download/v${theming_customcss_version}/theming_customcss.tar.gz  -O /tmp/theming_customcss.tar.gz \
  && cd /tmp && tar xfvz /tmp/theming_customcss.tar.gz && mv /tmp/theming_customcss /var/www/html/custom_apps/theming_customcss
RUN wget https://github.com/westberliner/checksum/releases/download/v${checksum_version}/checksum.tar.gz -O /tmp/checksum.tar.gz \
  && cd /tmp && tar xfvz /tmp/checksum.tar.gz && mv /tmp/checksum /var/www/html/custom_apps/
RUN wget  https://github.com/pondersource/nc-sciencemesh/archive/refs/heads/main.zip -O /tmp/nc-sciencemesh.zip \
  && cd /tmp && unzip /tmp/nc-sciencemesh.zip
RUN cd /tmp/nc-sciencemesh-main/ && make  && mv /tmp/nc-sciencemesh-main/ /var/www/html/custom_apps/sciencemesh
COPY --chown=root:root ./nextcloud-rds.tar.gz /tmp
RUN cd /tmp && tar xfv nextcloud-rds.tar.gz && mv rds/ /var/www/html/custom_apps
RUN rm -rf /tmp/*.tar.* && chown -R www-data:root /var/www/html
RUN usermod -a -G tty www-data
RUN apt remove -y wget curl make npm patch && apt autoremove -y
