FROM nginx:1.13.6

ARG SSL_PASSWORD
ARG COUNTRY
ARG STATE
ARG CITY
ARG ORG
ARG SUB_ORG
ARG DOMAIN

RUN apt-get update -y && apt-get install openssl \
    && mkdir -p /etc/nginx/ssl \
    && openssl genrsa -des3 -passout pass:${SSL_PASSWORD} -out /etc/nginx/ssl/server.pass.key 4096 \
    && openssl rsa -passin pass:${SSL_PASSWORD} -in /etc/nginx/ssl/server.pass.key -out /etc/nginx/ssl/server.key \
    && rm /etc/nginx/ssl/server.pass.key \
    && openssl req -new -key /etc/nginx/ssl/server.key -out /etc/nginx/ssl/server.csr -subj "/C=${COUNTRY}/ST=${STATE}/L=${CITY}/O=${ORG}/OU=${SUB_ORG}/CN=*.${DOMAIN}" \
    && openssl x509 -req -days 3650 -in /etc/nginx/ssl/server.csr -signkey /etc/nginx/ssl/server.key -out /etc/nginx/ssl/server.crt

COPY jenkins.conf /etc/nginx/conf.d/jenkins.conf

RUN export DOMAIN=${DOMAIN} \
    && envsubst '${DOMAIN}' < /etc/nginx/conf.d/jenkins.conf > /etc/nginx/conf.d/default.conf \
    && rm /etc/nginx/conf.d/jenkins.conf
