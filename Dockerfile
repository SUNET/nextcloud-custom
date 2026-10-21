ARG NGINX_BASE_IMAGE_TAG=1.28.0-alpine

FROM nginx:${NGINX_BASE_IMAGE_TAG} AS certificate

RUN apk add --no-cache openssl \
    && mkdir /tls \
    && openssl req -x509 -nodes -newkey rsa:2048 -days 30 \
        -subj "/CN=sunet-drive-maintenance" \
        -keyout /tls/ssl-cert-snakeoil.key \
        -out /tls/ssl-cert-snakeoil.pem

FROM nginx:${NGINX_BASE_IMAGE_TAG}

RUN rm /usr/share/nginx/html/50x.html

COPY --from=certificate /tls /etc/nginx/tls
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY index.html /usr/share/nginx/html/index.html
COPY status.php /usr/share/nginx/html/status.php

EXPOSE 80 443
