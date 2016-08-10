FROM alpine

ENV LANG C.UTF-8
RUN apk add -U ca-certificates \
  && echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
  && apk add -U openssl python py-pip py-openssl py-lxml py-requests py-scrapy@testing py-gunicorn py-flask py-pillow py-numpy@testing py-crypto \
  && pip install wheel sh logbook pytesseract \
  && rm -rf /var/cache/apk/*

