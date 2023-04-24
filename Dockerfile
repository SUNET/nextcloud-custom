FROM debian:bullseye-slim

# Set Nextcloud download url here
ARG nc_download_url=https://download.nextcloud.com/.customers/server/25.0.5-e065c72e/nextcloud-25.0.5-enterprise.zip

# Set app versions here
ARG checksum_version=1.2.0
ARG drive_email_template_version=1.0.0
ARG gss_version=2.1.1
ARG loginpagebutton_version=1.0.0
ARG richdocuments_version=7.1.2
ARG theming_customcss_version=1.13.0
ARG twofactor_admin_version=4.1.9
ARG twofactor_webauthn_version=1.1.2

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
  curl \
  libapache2-mod-php8.0 \
  libmagickcore-6.q16-6-extra \
  make \
  mariadb-client \
  npm \
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
COPY --chown=root:root ./cron.sh /cron.sh

## DONT ADD STUFF BETWEEN HERE
RUN wget ${nc_download_url} -O /tmp/nextcloud.zip && cd /tmp && unzip /tmp/nextcloud.zip && cd /tmp/nextcloud \
  &&  mkdir -p /var/www/html/data && touch /var/www/html/data/.ocdata && mkdir /var/www/html/config \
   && cp -a /tmp/nextcloud/* /var/www/html && cp -a /tmp/nextcloud/.[^.]* /var/www/html \
  &&  chown -R www-data:root /var/www/html && chmod +x /var/www/html/occ &&rm -rf /tmp/nextcloud
RUN php /var/www/html/occ integrity:check-core
## AND HERE, OR CODE INTEGRITY CHECK MIGHT FAIL, AND IMAGE WILL NOT BUILD

## VARIOUS PATCHES COMES HERE IF NEEDED
COPY ./ignore_and_warn_on_non_numeric_version_timestamp.patch /var/www/html/
RUN cd /var/www/html/ && patch -p1 < ignore_and_warn_on_non_numeric_version_timestamp.patch

## INSTALL APPS
RUN mkdir /var/www/html/custom_apps
RUN rm -rf /var/www/html/apps/globalsiteselector
RUN wget https://github.com/nextcloud/globalsiteselector/archive/refs/tags/v${gss_version}.tar.gz -O /tmp/globalsiteselector.tar.gz \
   && cd /tmp && tar xfvz /tmp/globalsiteselector.tar.gz \
  && mv /tmp/globalsiteselector-* /var/www/html/apps/globalsiteselector
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
