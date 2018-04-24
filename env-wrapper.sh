#!/bin/bash
envsubst '${APP_HOST} ${CERTS_PATH} ${API_SECRET}' < /etc/bigbluebutton/nginx-site.conf.template > /etc/bigbluebutton/nginx-site.conf
exec "$@"
