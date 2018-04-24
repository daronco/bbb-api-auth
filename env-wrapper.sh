#!/bin/bash
envsubst '${APP_HOST} ${CERTS_PATH} ${API_SECRET}' < /usr/local/openresty/nginx/conf/site.conf.template > /usr/local/openresty/nginx/conf/site.conf
exec "$@"
