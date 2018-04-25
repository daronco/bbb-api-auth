FROM openresty/openresty:xenial

EXPOSE 80 443

ENV APP_HOST     change-me.bigbluebutton.org
ENV CERTS_PATH   /usr/local/openresty/nginx/ssl
ENV API_PATH     /bigbluebutton/api/v2/
ENV API_SECRET   change-me-im-a-secret

ENV RESTY_NGINX_PATH /usr/local/openresty/nginx/

# openssl and dhparam
RUN apt-get update && apt-get install -y openssl \
  && openssl dhparam -out /usr/local/openresty/nginx/dhp-2048.pem 2048 \
  && mkdir -p ${CERTS_PATH}

# nginx configuration
RUN mkdir -p ${RESTY_NGINX_PATH}/conf/lua/ \
  && mv ${RESTY_NGINX_PATH}/conf/nginx.conf ${RESTY_NGINX_PATH}/conf/nginx.conf.bk \
  && rm ${RESTY_NGINX_PATH}/html/index.html
COPY nginx-files/nginx.conf ${RESTY_NGINX_PATH}/conf/nginx.conf
COPY nginx-files/site.conf.template ${RESTY_NGINX_PATH}/conf/site.conf.template
COPY nginx-files/auth.lua ${RESTY_NGINX_PATH}/conf/lua/auth.lua
COPY nginx-files/html/ ${RESTY_NGINX_PATH}/html

# if dev create a self-signed certificate
# RUN if [ ${APP_ENV} != production ]; \
#   then \
RUN openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
    -subj "/C=CA/ST=BigBlueButton/L=Test/O=BigBlueButton" \
    -keyout ${CERTS_PATH}/privkey.pem -out ${CERTS_PATH}/fullchain.pem;
	# fi

# wrapper that changes nginx's config based on the env variables
COPY env-wrapper.sh ${RESTY_NGINX_PATH}/env-wrapper.sh
RUN ${RESTY_NGINX_PATH}/env-wrapper.sh

# # dumb-init
# ADD dumb-init_1.2.0 /usr/bin/dumb-init
# RUN chmod +x /usr/bin/dumb-init

# ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD [ \
  "/usr/local/openresty/nginx/env-wrapper.sh", \
  "/usr/local/openresty/bin/openresty", \
  "-c", "/usr/local/openresty/nginx/conf/nginx.conf", \
  "-g", "daemon off;" \
]
