FROM nginx:alpine

ENV URL_CONF https://raw.githubusercontent.com/CM44/cdn/master/wget/nginx.conf

RUN apk add openssl \
    && printf "wget $URL_CONF -O /etc/nginx/nginx.conf\n\
nginx">/run.sh
chmod +x /run.sh

CMD ["sh", "/run.sh"]
