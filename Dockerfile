FROM docker.sunet.se/drive/nextcloud-base:29.0.8.2-5 as build

ARG announcementcenter_version=7.0.0
ARG assistant_version=1.1.0
ARG calendar_version=4.7.16
ARG checksum_version=1.2.4
ARG collectives_version=2.14.4
ARG contacts_version=6.0.0
ARG dicomviewer_version=2.1.2
ARG drive_email_template_version=1.0.0
ARG edusign_version=0.0.3
ARG files_accesscontrol_version=1.19.1
ARG files_automatedtagging_version=1.19.0
ARG forms_version=4.2.4
ARG integration_openai_version=2.0.3
ARG integration_jupyterhub_version=0.1.2
ARG login_notes_version=1.6.0
ARG mail_version=3.7.8
ARG mfazones_version=0.2.1
ARG polls_version=7.2.4
ARG rds_version=0.0.3
ARG richdocuments_version=8.4.6
ARG sciencemesh_version=0.5.0
ARG stepupauth_version=0.2.0
ARG stt_helper_version=1.1.1
ARG tasks_version=0.16.1
ARG text2image_helper_version=1.0.2
ARG theming_customcss_version=1.17.0
ARG twofactor_admin_version=4.5.0
ARG twofactor_webauthn_version=1.4.0

## INSTALL APPS
RUN apt update && apt install -y patch wget tar
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
RUN wget -q https://github.com/ayselafsar/dicomviewer/releases/download/v${dicomviewer_version}/dicomviewer-${dicomviewer_version}.tar.gz -O /tmp/dicomviewer.tar.gz \
  && cd /tmp && tar xf /tmp/dicomviewer.tar.gz && mv /tmp/dicomviewer /var/www/html/custom_apps/
RUN wget -q https://github.com/nextcloud-releases/files_accesscontrol/releases/download/v${files_accesscontrol_version}/files_accesscontrol-v${files_accesscontrol_version}.tar.gz -O /tmp/files_accesscontrol.tar.gz \
  && cd /tmp && tar xf /tmp/files_accesscontrol.tar.gz && mv /tmp/files_accesscontrol /var/www/html/custom_apps/
RUN wget -q https://github.com/SUNET/nextcloud-edusign/releases/download/v${edusign_version}/edusign-${edusign_version}.tar.gz -O /tmp/edusign.tar.gz \
  && cd /tmp && tar xf /tmp/edusign.tar.gz && mv /tmp/edusign /var/www/html/custom_apps/
RUN wget -q https://github.com/nextcloud-releases/files_automatedtagging/releases/download/v${files_automatedtagging_version}/files_automatedtagging-v${files_automatedtagging_version}.tar.gz -O /tmp/files_automatedtagging.tar.gz \
  && cd /tmp && tar xf /tmp/files_automatedtagging.tar.gz && mv /tmp/files_automatedtagging /var/www/html/custom_apps/
RUN wget -q https://github.com/nextcloud-releases/forms/releases/download/v${forms_version}/forms-v${forms_version}.tar.gz -O /tmp/forms.tar.gz \
  && cd /tmp && tar xf /tmp/forms.tar.gz && mv /tmp/forms /var/www/html/custom_apps/
RUN wget -q https://github.com/nextcloud-releases/integration_openai/releases/download/v${integration_openai_version}/integration_openai-v${integration_openai_version}.tar.gz -O /tmp/integration_openai.tar.gz \
  && cd /tmp && tar xf /tmp/integration_openai.tar.gz && mv /tmp/integration_openai /var/www/html/custom_apps/
RUN wget -q https://packages.framasoft.org/projects/nextcloud-apps/login-notes/login_notes-${login_notes_version}.tar.gz -O /tmp/login_notes.tar.gz \
  && cd /tmp && tar xf /tmp/login_notes.tar.gz && mv /tmp/login_notes /var/www/html/custom_apps/
RUN wget -q https://github.com/nextcloud-releases/mail/releases/download/v${mail_version}/mail-v${mail_version}.tar.gz -O /tmp/mail.tar.gz \
  && cd /tmp && tar xf /tmp/mail.tar.gz && mv /tmp/mail /var/www/html/custom_apps/
RUN wget -q https://github.com/nextcloud-releases/polls/releases/download/v${polls_version}/polls-v${polls_version}.tar.gz -O /tmp/polls.tar.gz \
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
RUN wget -q https://github.com/nextcloud-releases/stt_helper/releases/download/v${stt_helper_version}/stt_helper-v${stt_helper_version}.tar.gz -O /tmp/stt_helper.tar.gz \
  && cd /tmp && tar xf /tmp/stt_helper.tar.gz && mv /tmp/stt_helper /var/www/html/custom_apps/
RUN wget -q https://github.com/nextcloud-releases/text2image_helper/releases/download/v${text2image_helper_version}/text2image_helper-v${text2image_helper_version}.tar.gz -O /tmp/text2image_helper.tar.gz \
  && cd /tmp && tar xf /tmp/text2image_helper.tar.gz && mv /tmp/text2image_helper /var/www/html/custom_apps/
# Patch mail app
COPY ./masterpassword.patch /var/www/html/custom_apps/mail/
RUN cd /var/www/html/custom_apps/mail && \
  apt-get update && apt-get install -y patch && \
  patch -p1 < ./masterpassword.patch && \
  rm masterpassword.patch

FROM docker.sunet.se/drive/nextcloud-base:29.0.8.2-5
COPY --from=build /var/www/html/custom_apps /var/www/html/custom_apps

