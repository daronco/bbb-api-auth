FROM openresty/openresty:xenial

EXPOSE 80 443

ENV APP_HOST     change-me.bigbluebutton.org
ENV CERTS_PATH   /usr/local/openresty/nginx/ssl
ENV API_SECRET   change-me-im-a-secret

# openssl and dhparam
RUN apt-get update && apt-get install -y openssl \
  && openssl dhparam -out /usr/local/openresty/nginx/dhp-2048.pem 2048 \
  && mkdir -p ${CERTS_PATH}

# nginx configuration
RUN mkdir -p /etc/bigbluebutton/nginx-files/ \
  && mkdir -p /var/bigbluebutton/ \
  && mv /usr/local/openresty/nginx/conf/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf.bk \
  && rm /usr/local/openresty/nginx/html/index.html
COPY nginx-files/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY nginx-files/nginx-site.conf.template /etc/bigbluebutton/nginx-site.conf.template
# COPY nginx-files/api.json /var/bigbluebutton/api.json
COPY nginx-files/api.json /usr/local/openresty/nginx/html/api.json

# if dev create a self-signed certificate
# RUN if [ ${APP_ENV} != production ]; \
#   then \
RUN openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
    -subj "/C=CA/ST=BigBlueButton/L=Test/O=BigBlueButton" \
    -keyout ${CERTS_PATH}/privkey.pem -out ${CERTS_PATH}/fullchain.pem;
	# fi

# wrapper that changes nginx's config based on the env variables
COPY env-wrapper.sh /etc/bigbluebutton/env-wrapper.sh
RUN /etc/bigbluebutton/env-wrapper.sh

# # dumb-init
# ADD dumb-init_1.2.0 /usr/bin/dumb-init
# RUN chmod +x /usr/bin/dumb-init

# ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD [ \
  "/etc/bigbluebutton/env-wrapper.sh", \
  "/usr/local/openresty/bin/openresty", \
  "-c", "/usr/local/openresty/nginx/conf/nginx.conf", \
  "-g", "daemon off;" \
]
