ARG NEXTCLOUD_BASE_IMAGE_TAG=32.0.5.1-1

FROM docker.sunet.se/drive/nextcloud-base:${NEXTCLOUD_BASE_IMAGE_TAG} AS build

# Apps from appstore
ARG announcementcenter_version=7.3.0
ARG assistant_version=2.12.0
ARG auto_groups_version=1.6.2
ARG calendar_version=6.1.6
ARG checksum_version=2.0.3
ARG collectives_version=3.5.0
ARG contacts_version=8.3.1
ARG edusign_version=0.0.9
ARG deck_version=1.16.3
ARG dicomviewer_version=2.3.1
ARG files_accesscontrol_version=3.0.2
ARG files_automatedtagging_version=3.0.3
ARG files_retention_version=3.0.0
ARG forms_version=5.2.4
ARG groupfolders_version=20.1.9
ARG integration_jupyterhub_version=0.1.4
ARG integration_oidc_version=0.1.6
ARG integration_openai_version=3.10.0
ARG login_notes_version=1.7.0
ARG mfazones_version=0.2.4
ARG polls_version=8.6.3
ARG richdocuments_version=9.0.2
ARG sharelisting_version=1.3.0
ARG stepupauth_version=0.2.3
ARG tasks_version=0.17.1
ARG terms_of_service_version=4.6.1
ARG theming_customcss_version=1.19.0
ARG twofactor_admin_version=4.9.0
ARG twofactor_webauthn_version=2.4.1

# Not published
ARG drive_email_template_version=1.0.0
ARG rds_ng_version=1.3.0
ARG imap_manager_version=0.0.4
ARG xmlconvert_version=0.1.3
ARG prismaapprove_version=0.4.0

## INSTALL APPS
RUN apt update && apt install -y patch wget tar
RUN mkdir -p /var/www/html/custom_apps
RUN wget -q https://github.com/nextcloud-releases/assistant/releases/download/v${assistant_version}/assistant-v${assistant_version}.tar.gz -O /tmp/assistant.tar.gz \
  && cd /tmp && tar xf /tmp/assistant.tar.gz && mv /tmp/assistant /var/www/html/custom_apps/
RUN wget -q https://github.com/nextcloud-releases/announcementcenter/releases/download/v${announcementcenter_version}/announcementcenter-v${announcementcenter_version}.tar.gz  -O /tmp/announcementcenter.tar.gz \
  && cd /tmp && tar xf /tmp/announcementcenter.tar.gz && mv /tmp/announcementcenter /var/www/html/custom_apps/
RUN wget -q https://github.com/stjosh/auto_groups/releases/download/v${auto_groups_version}/auto_groups-v${auto_groups_version}.tar.gz -O /tmp/auto_groups.tar.gz \
  && cd /tmp && tar xf /tmp/auto_groups.tar.gz && mv /tmp/auto_groups /var/www/html/custom_apps/
RUN wget -q https://github.com/nextcloud-releases/calendar/releases/download/v${calendar_version}/calendar-v${calendar_version}.tar.gz -O /tmp/calendar.tar.gz \
  && cd /tmp && tar xf /tmp/calendar.tar.gz && mv /tmp/calendar /var/www/html/custom_apps/
RUN wget -q https://github.com/westberliner/checksum/releases/download/v${checksum_version}/checksum.tar.gz -O /tmp/checksum.tar.gz \
  && cd /tmp && tar xf /tmp/checksum.tar.gz && mv /tmp/checksum /var/www/html/custom_apps/
RUN wget -q https://github.com/nextcloud/collectives/releases/download/v${collectives_version}/collectives-${collectives_version}.tar.gz -O /tmp/collectives.tar.gz \
  && cd /tmp && tar xf /tmp/collectives.tar.gz && mv /tmp/collectives /var/www/html/custom_apps/
RUN wget -q https://github.com/nextcloud-releases/contacts/releases/download/v${contacts_version}/contacts-v${contacts_version}.tar.gz -O /tmp/contacts.tar.gz \
  && cd /tmp && tar xf /tmp/contacts.tar.gz && mv /tmp/contacts /var/www/html/custom_apps/
RUN wget -q https://github.com/nextcloud-releases/deck/releases/download/v${deck_version}/deck-v${deck_version}.tar.gz -O /tmp/deck.tar.gz \
  && cd /tmp && tar xf /tmp/deck.tar.gz && mv /tmp/deck /var/www/html/custom_apps/
RUN wget -q https://github.com/ayselafsar/dicomviewer/releases/download/v${dicomviewer_version}/dicomviewer-${dicomviewer_version}.tar.gz -O /tmp/dicomviewer.tar.gz \
  && cd /tmp && tar xf /tmp/dicomviewer.tar.gz && mv /tmp/dicomviewer /var/www/html/custom_apps/
RUN wget -q https://github.com/nextcloud-releases/files_accesscontrol/releases/download/v${files_accesscontrol_version}/files_accesscontrol-v${files_accesscontrol_version}.tar.gz -O /tmp/files_accesscontrol.tar.gz \
  && cd /tmp && tar xf /tmp/files_accesscontrol.tar.gz && mv /tmp/files_accesscontrol /var/www/html/custom_apps/
RUN wget -q https://github.com/SUNET/nextcloud-edusign/releases/download/v${edusign_version}/edusign-${edusign_version}.tar.gz -O /tmp/edusign.tar.gz \
  && cd /tmp && tar xf /tmp/edusign.tar.gz && mv /tmp/edusign /var/www/html/custom_apps/
RUN wget -q https://github.com/nextcloud-releases/files_automatedtagging/releases/download/v${files_automatedtagging_version}/files_automatedtagging-v${files_automatedtagging_version}.tar.gz -O /tmp/files_automatedtagging.tar.gz \
  && cd /tmp && tar xf /tmp/files_automatedtagging.tar.gz && mv /tmp/files_automatedtagging /var/www/html/custom_apps/
RUN wget -q https://github.com/nextcloud-releases/files_retention/releases/download/v${files_retention_version}/files_retention-v${files_retention_version}.tar.gz -O /tmp/files_retention.tar.gz \
  && cd /tmp && tar xf /tmp/files_retention.tar.gz && mv /tmp/files_retention /var/www/html/custom_apps/
RUN wget -q https://github.com/nextcloud-releases/forms/releases/download/v${forms_version}/forms-v${forms_version}.tar.gz -O /tmp/forms.tar.gz \
  && cd /tmp && tar xf /tmp/forms.tar.gz && mv /tmp/forms /var/www/html/custom_apps/
RUN wget -q https://github.com/nextcloud-releases/groupfolders/releases/download/v${groupfolders_version}/groupfolders-v${groupfolders_version}.tar.gz -O /tmp/groupfolders.tar.gz \
  && cd /tmp && tar xf /tmp/groupfolders.tar.gz && mv /tmp/groupfolders /var/www/html/custom_apps/
RUN wget -q https://github.com/SUNET/nextcloud-imap_manager/releases/download/v${imap_manager_version}/imap_manager-${imap_manager_version}.tar.gz -O /tmp/imap_manager.tar.gz \
  && cd /tmp && tar xf /tmp/imap_manager.tar.gz && mv /tmp/imap_manager /var/www/html/custom_apps/ 
RUN wget -q https://github.com/nextcloud-releases/integration_openai/releases/download/v${integration_openai_version}/integration_openai-v${integration_openai_version}.tar.gz -O /tmp/integration_openai.tar.gz \
  && cd /tmp && tar xf /tmp/integration_openai.tar.gz && mv /tmp/integration_openai /var/www/html/custom_apps/
RUN wget -q https://github.com/SUNET/nextcloud-integration_oidc/releases/download/v${integration_oidc_version}/integration_oidc-${integration_oidc_version}.tar.gz -O /tmp/integration_oidc.tar.gz \
  && cd /tmp && tar xf /tmp/integration_oidc.tar.gz && mv /tmp/integration_oidc /var/www/html/custom_apps/
RUN wget -q https://packages.framasoft.org/projects/nextcloud-apps/login-notes/login_notes-${login_notes_version}.tar.gz -O /tmp/login_notes.tar.gz \
  && cd /tmp && tar xf /tmp/login_notes.tar.gz && mv /tmp/login_notes /var/www/html/custom_apps/
RUN wget -q https://github.com/nextcloud-releases/polls/releases/download/v${polls_version}/polls-v${polls_version}.tar.gz -O /tmp/polls.tar.gz \
  && cd /tmp && tar xf /tmp/polls.tar.gz && mv /tmp/polls /var/www/html/custom_apps/
RUN wget -q https://github.com/nextcloud-releases/richdocuments/releases/download/v${richdocuments_version}/richdocuments-v${richdocuments_version}.tar.gz -O /tmp/richdocuments.tar.gz \
  && cd /tmp && tar xf /tmp/richdocuments.tar.gz && mv /tmp/richdocuments /var/www/html/custom_apps
RUN wget -q https://github.com/nextcloud-releases/sharelisting/releases/download/v${sharelisting_version}/sharelisting-v${sharelisting_version}.tar.gz -O /tmp/sharelisting.tar.gz \
  && cd /tmp && tar xf /tmp/sharelisting.tar.gz && mv /tmp/sharelisting /var/www/html/custom_apps
RUN wget -q https://github.com/nextcloud/tasks/releases/download/v${tasks_version}/tasks.tar.gz -O /tmp/tasks.tar.gz \
  && cd /tmp && tar xf /tmp/tasks.tar.gz && mv /tmp/tasks /var/www/html/custom_apps
RUN wget -q https://github.com/nextcloud-releases/terms_of_service/releases/download/v${terms_of_service_version}/terms_of_service-v${terms_of_service_version}.tar.gz -O /tmp/terms_of_service.tar.gz \
  && cd /tmp && tar xf /tmp/terms_of_service.tar.gz && mv /tmp/terms_of_service /var/www/html/custom_apps
RUN wget -q https://github.com/juliushaertl/theming_customcss/releases/download/v${theming_customcss_version}/theming_customcss.tar.gz  -O /tmp/theming_customcss.tar.gz \
  && cd /tmp && tar xf /tmp/theming_customcss.tar.gz && mv /tmp/theming_customcss /var/www/html/custom_apps/theming_customcss
RUN wget -q https://github.com/nextcloud-releases/twofactor_webauthn/releases/download/v${twofactor_webauthn_version}/twofactor_webauthn-v${twofactor_webauthn_version}.tar.gz \
  -O /tmp/twofactor_webauthn.tar.gz \
  && cd /tmp && tar xf /tmp/twofactor_webauthn.tar.gz && mv /tmp/twofactor_webauthn /var/www/html/custom_apps
RUN wget -q https://github.com/nextcloud-releases/twofactor_admin/releases/download/v${twofactor_admin_version}/twofactor_admin.tar.gz -O /tmp/twofactor_admin.tar.gz \
  && cd /tmp && tar xf /tmp/twofactor_admin.tar.gz && mv /tmp/twofactor_admin /var/www/html/custom_apps/
RUN wget -q https://github.com/SUNET/drive-email-template/archive/refs/tags/${drive_email_template_version}.tar.gz -O /tmp/drive-email-template.tar.gz \
  && cd /tmp && tar xf /tmp/drive-email-template.tar.gz && mv /tmp/drive-email-template-* /var/www/html/custom_apps/drive_email_template
RUN wget -q https://github.com/SUNET/nextcloud-stepupauth/releases/download/v${stepupauth_version}/stepupauth-${stepupauth_version}.tar.gz -O /tmp/stepupauth.tar.gz \
  && cd /tmp && tar xf /tmp/stepupauth.tar.gz && mv /tmp/stepupauth /var/www/html/custom_apps/
RUN wget -q https://github.com/SUNET/nextcloud-jupyter/releases/download/v${integration_jupyterhub_version}/integration_jupyterhub-${integration_jupyterhub_version}.tar.gz -O /tmp/integration_jupyterhub.tar.gz \
  && cd /tmp && tar xf /tmp/integration_jupyterhub.tar.gz && mv /tmp/integration_jupyterhub /var/www/html/custom_apps/
RUN wget -q https://github.com/SUNET/nextcloud-mfazones/releases/download/v${mfazones_version}/mfazones-${mfazones_version}.tar.gz -O /tmp/mfazones.tar.gz \
  && cd /tmp && tar xf /tmp/mfazones.tar.gz && mv /tmp/mfazones /var/www/html/custom_apps/
RUN wget -q https://sunet.drive.sunet.se/s/KKxj6ReMf4RKZqi/download/rdsng-${rds_ng_version}.tar.gz -O /tmp/rdsng.tar.gz \
  && cd /tmp && tar xf /tmp/rdsng.tar.gz && mv /tmp/rdsng /var/www/html/custom_apps
RUN wget -q https://platform.sunet.se/SUNET/nextcloud-xmlconvert/releases/download/v${xmlconvert_version}/xmlconvert-${xmlconvert_version}.tar.gz -O /tmp/xmlconvert.tar.gz \
  && cd /tmp && tar xf /tmp/xmlconvert.tar.gz && mv /tmp/xmlconvert /var/www/html/custom_apps
RUN wget -q https://platform.sunet.se/SUNET/nextcloud-prisma-approve/releases/download/v${prismaapprove_version}/prismaapprove-${prismaapprove_version}.tar.gz -O /tmp/prismaapprove.tar.gz \
  && cd /tmp && tar xf /tmp/prismaapprove.tar.gz && mv /tmp/prismaapprove /var/www/html/custom_apps

FROM docker.sunet.se/drive/nextcloud-base:${NEXTCLOUD_BASE_IMAGE_TAG}
COPY --from=build --chown=www-data:root /var/www/html/custom_apps /var/www/html/custom_apps
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
