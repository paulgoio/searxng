FROM alpine:latest

ARG UID=991 GID=991
RUN addgroup -g ${GID} searx && adduser -u ${UID} -D -h /usr/local/searx -s /bin/sh -G searx searx

ENV MORTY_KEY=""

WORKDIR /usr/local/searx

RUN apk -U upgrade \
 && apk add --no-cache -t build-dependencies build-base py3-setuptools python3-dev libffi-dev libxslt-dev libxml2-dev openssl-dev tar git \
 && apk add --no-cache ca-certificates su-exec python3 py3-pip libxml2 libxslt openssl tini uwsgi uwsgi-python3 brotli \
 && git clone https://github.com/searx/searx.git . \
 && chown -R searx:searx ../searx \
 && pip install --upgrade pip \
 && pip install --no-cache -r requirements.txt \
 && apk del build-dependencies \
 && rm -rf /var/cache/apk/* /root/.cache

RUN rm -rf searx/static/themes/simple/css/* && rm -rf searx/static/themes/simple/img/* && rm -rf searx/settings.yml && rm -rf /etc/uwsgi/uwsgi.ini && cp -v dockerfiles/uwsgi.ini /etc/uwsgi/
COPY ./src/css searx/static/themes/simple/css
COPY ./src/img searx/static/themes/simple/img
COPY ./src/settings.yml searx/settings.yml
COPY ./src/run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

RUN su searx -c "/usr/bin/python3 -m compileall -q searx"; \
find /usr/local/searx/searx/static -a \( -name '*.html' -o -name '*.css' -o -name '*.js' \
-o -name '*.svg' -o -name '*.ttf' -o -name '*.eot' \) \
-type f -exec gzip -9 -k {} \+ -exec brotli --best {} \+

EXPOSE 8080
CMD ["/sbin/tini","--","run.sh"]
