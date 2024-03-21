FROM docker.sunet.se/drive/nextcloud-base:27.1.6.3-7 as nextcloud
# Set app versions here
ARG announcementcenter_version=6.7.0
ARG assistant_version=1.0.2
ARG calendar_version=4.6.4
ARG checksum_version=1.2.3
ARG collectives_version=2.9.2
ARG contacts_version=5.5.1
ARG drive_email_template_version=1.0.0
ARG files_accesscontrol_version=1.17.1
ARG files_automatedtagging_version=1.17.0
ARG forms_version=3.4.4
ARG integration_excalidraw_version=2.0.4
ARG integration_openai_version=1.1.5
ARG integration_jupyterhub_version=0.1.0
ARG login_notes_version=1.3.1
ARG loginpagebutton_version=1.0.0
ARG maps_version=1.2.0
ARG mfazones_version=0.0.4
ARG polls_version=5.4.2
ARG rds_version=0.0.2
ARG richdocuments_version=8.2.4
ARG sciencemesh_version=0.5.0
ARG stepupauth_version=0.2.0
ARG tasks_version=0.15.0
ARG theming_customcss_version=1.15.0
ARG twofactor_admin_version=4.4.0
ARG twofactor_webauthn_version=1.3.2

## Install app that needs to go in the regular apps folder
# RUN wget -q https://github.com/nextcloud-releases/mail/releases/download/v${mail_version}/mail-v${mail_version}.tar.gz -O /tmp/mail.tar.gz \
#   && cd /tmp && tar xf /tmp/mail.tar.gz && mv /tmp/mail /var/www/html/apps/


## INSTALL APPS
RUN mkdir /var/www/html/custom_apps
RUN wget -q https://github.com/nextcloud-releases/assistant/releases/download/v${assistant_version}/assistant-v${assistant_version}.tar.gz -O /tmp/assistant.tar.gz \
  && cd /tmp && tar xf /tmp/assistant.tar.gz && mv /tmp/assistant /var/www/html/custom_apps/
RUN wget -q https://github.com/nextcloud-releases/announcementcenter/releases/download/v${announcementcenter_version}/announcementcenter-v${announcementcenter_version}.tar.gz  -O /tmp/announcementcenter.tar.gz \
  && cd /tmp && tar xf /tmp/announcementcenter.tar.gz && mv /tmp/announcementcenter /var/www/html/custom_apps/
RUN wget -q https://github.com/nextcloud-releases/calendar/releases/download/v${calendar_version}/calendar-v${calendar_version}.tar.gz -O /tmp/calendar.tar.gz \
  && cd /tmp && tar xf /tmp/calendar.tar.gz && mv /tmp/calendar /var/www/html/custom_apps/
RUN wget -q https://github.com/westberliner/checksum/releases/download/v${checksum_version}/checksum.tar.gz -O /tmp/checksum.tar.gz \
  && cd /tmp && tar xf /tmp/checksum.tar.gz && mv /tmp/checksum /var/www/html/custom_apps/
RUN wget -q https://github.com/nextcloud/collectives/releases/download/v${collectives_version}/collectives-${collectives_version}.tar.gz -O /tmp/collectives.tar.gz \
  && cd /tmp && tar xf /tmp/collectives.tar.gz && mv /tmp/collectives /var/www/html/custom_apps/
RUN wget -q https://github.com/nextcloud-releases/contacts/releases/download/v${contacts_version}/contacts-v${contacts_version}.tar.gz -O /tmp/contacts.tar.gz \
  && cd /tmp && tar xf /tmp/contacts.tar.gz && mv /tmp/contacts /var/www/html/custom_apps/
RUN wget -q https://github.com/nextcloud-releases/files_accesscontrol/releases/download/v${files_accesscontrol_version}/files_accesscontrol-v${files_accesscontrol_version}.tar.gz -O /tmp/files_accesscontrol.tar.gz \
  && cd /tmp && tar xf /tmp/files_accesscontrol.tar.gz && mv /tmp/files_accesscontrol /var/www/html/custom_apps/
RUN wget -q https://github.com/nextcloud-releases/files_automatedtagging/releases/download/v${files_automatedtagging_version}/files_automatedtagging-v${files_automatedtagging_version}.tar.gz -O /tmp/files_automatedtagging.tar.gz \
  && cd /tmp && tar xf /tmp/files_automatedtagging.tar.gz && mv /tmp/files_automatedtagging /var/www/html/custom_apps/
RUN wget -q https://github.com/nextcloud-releases/forms/releases/download/v${forms_version}/forms-v${forms_version}.tar.gz -O /tmp/forms.tar.gz \
  && cd /tmp && tar xf /tmp/forms.tar.gz && mv /tmp/forms /var/www/html/custom_apps/
RUN wget -q https://github.com/nextcloud-releases/integration_excalidraw/releases/download/v${integration_excalidraw_version}/integration_excalidraw-v${integration_excalidraw_version}.tar.gz -O /tmp/integration_excalidraw.tar.gz \
  && cd /tmp && tar xf /tmp/integration_excalidraw.tar.gz && mv /tmp/integration_excalidraw /var/www/html/custom_apps/
RUN wget -q https://github.com/nextcloud-releases/integration_openai/releases/download/v${integration_openai_version}/integration_openai-v${integration_openai_version}.tar.gz -O /tmp/integration_openai.tar.gz \
  && cd /tmp && tar xf /tmp/integration_openai.tar.gz && mv /tmp/integration_openai /var/www/html/custom_apps/
RUN wget -q https://packages.framasoft.org/projects/nextcloud-apps/login-notes/login_notes-${login_notes_version}.tar.gz -O /tmp/login_notes.tar.gz \
  && cd /tmp && tar xf /tmp/login_notes.tar.gz && mv /tmp/login_notes /var/www/html/custom_apps/
RUN wget -q https://github.com/SUNET/loginpagebutton/archive/refs/tags/v.${loginpagebutton_version}.tar.gz -O /tmp/loginpagebutton.tar.gz \
  && cd /tmp && tar xf /tmp/loginpagebutton.tar.gz && mv /tmp/loginpagebutton-* /var/www/html/custom_apps/loginpagebutton
RUN wget -q https://github.com/nextcloud/maps/releases/download/v${maps_version}/maps-${maps_version}.tar.gz -O /tmp/maps.tar.gz \
  && cd /tmp && tar xf /tmp/maps.tar.gz && mv /tmp/maps /var/www/html/custom_apps/
RUN wget -q https://github.com/nextcloud/polls/releases/download/v${polls_version}/polls.tar.gz -O /tmp/polls.tar.gz \
  && cd /tmp && tar xf /tmp/polls.tar.gz && mv /tmp/polls /var/www/html/custom_apps/
RUN wget -q https://github.com/nextcloud-releases/richdocuments/releases/download/v${richdocuments_version}/richdocuments-v${richdocuments_version}.tar.gz -O /tmp/richdocuments.tar.gz \
  && cd /tmp && tar xf /tmp/richdocuments.tar.gz && mv /tmp/richdocuments /var/www/html/custom_apps
RUN wget -q https://github.com/nextcloud/tasks/releases/download/v${tasks_version}/tasks.tar.gz -O /tmp/tasks.tar.gz \
  && cd /tmp && tar xf /tmp/tasks.tar.gz && mv /tmp/tasks /var/www/html/custom_apps
RUN wget -q https://github.com/juliushaertl/theming_customcss/releases/download/v${theming_customcss_version}/theming_customcss.tar.gz  -O /tmp/theming_customcss.tar.gz \
  && cd /tmp && tar xf /tmp/theming_customcss.tar.gz && mv /tmp/theming_customcss /var/www/html/custom_apps/theming_customcss
RUN wget -q https://github.com/nextcloud-releases/twofactor_webauthn/releases/download/v${twofactor_webauthn_version}/twofactor_webauthn-v${twofactor_webauthn_version}.tar.gz \
  -O /tmp/twofactor_webauthn.tar.gz \
  && cd /tmp && tar xf /tmp/twofactor_webauthn.tar.gz && mv /tmp/twofactor_webauthn /var/www/html/custom_apps
RUN wget -q https://github.com/nextcloud-releases/twofactor_admin/releases/download/v${twofactor_admin_version}/twofactor_admin.tar.gz -O /tmp/twofactor_admin.tar.gz \
  && cd /tmp && tar xf /tmp/twofactor_admin.tar.gz && mv /tmp/twofactor_admin /var/www/html/custom_apps/
RUN wget -q https://github.com/SUNET/drive-email-template/archive/refs/tags/${drive_email_template_version}.tar.gz -O /tmp/drive-email-template.tar.gz \
  && cd /tmp && tar xf /tmp/drive-email-template.tar.gz && mv /tmp/drive-email-template-* /var/www/html/custom_apps/drive_email_template
RUN wget -q https://github.com/sciencemesh/nc-sciencemesh/releases/download/v${sciencemesh_version}-nc/sciencemesh.tar.gz -O /tmp/sciencemesh.tar.gz \
  && cd /tmp && tar xf /tmp/sciencemesh.tar.gz && mv /tmp/sciencemesh /var/www/html/custom_apps/
RUN wget -q https://github.com/SUNET/nextcloud-stepupauth/releases/download/v${stepupauth_version}/stepupauth-${stepupauth_version}.tar.gz -O /tmp/stepupauth.tar.gz \
  && cd /tmp && tar xf /tmp/stepupauth.tar.gz && mv /tmp/stepupauth /var/www/html/custom_apps/
RUN wget -q https://github.com/SUNET/nextcloud-jupyter/releases/download/v${integration_jupyterhub_version}/integration_jupyterhub-${integration_jupyterhub_version}.tar.gz -O /tmp/integration_jupyterhub.tar.gz \
  && cd /tmp && tar xf /tmp/integration_jupyterhub.tar.gz && mv /tmp/integration_jupyterhub /var/www/html/custom_apps/
RUN wget -q https://github.com/SUNET/nextcloud-mfazones/releases/download/v${mfazones_version}/mfazones-${mfazones_version}.tar.gz -O /tmp/mfazones.tar.gz \
  && cd /tmp && tar xf /tmp/mfazones.tar.gz && mv /tmp/mfazones /var/www/html/custom_apps/
RUN wget -q https://github.com/Sciebo-RDS/nextcloud-rds/releases/download/v${rds_version}/rds-${rds_version}.tar.gz -O /tmp/rds.tar.gz \
  && cd /tmp && tar xf /tmp/rds.tar.gz && mv /tmp/rds /var/www/html/custom_apps

# CLEAN UP
RUN apt remove -y wget curl make npm patch && apt autoremove -y
RUN rm -rf /tmp/*.tar.* && chown -R www-data:root /var/www/html && rm -rf /var/lib/apt/lists/*
