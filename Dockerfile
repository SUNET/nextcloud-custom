ARG NGINX_BASE_IMAGE_TAG=1.28.0-alpine

FROM nginx:${NGINX_BASE_IMAGE_TAG}

RUN rm /usr/share/nginx/html/50x.html

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80
