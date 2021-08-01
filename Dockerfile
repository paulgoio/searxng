FROM alpine:3.14

# GIUD and UID for searx user and optional settings
ENV GID=991 UID=991 MORTY_KEY= DOMAIN= CONTACT= ISSUE_URL= TWITTER=

# setup searx user and workdir
RUN addgroup -g ${GID} searx && adduser -u ${UID} -D -h /usr/local/searx -s /bin/sh -G searx searx
WORKDIR /usr/local/searx
COPY --chown=searx:searx src/searxng .

# install build deps and git clone searx
RUN apk -U upgrade \
 && apk add --no-cache -t build-dependencies build-base py3-setuptools python3-dev libffi-dev libxslt-dev libxml2-dev openssl-dev tar git \
 && apk add --no-cache ca-certificates su-exec python3 py3-pip libxml2 libxslt openssl tini uwsgi uwsgi-python3 brotli \
 && pip install --upgrade pip \
 && pip install --no-cache -r requirements.txt \
 && apk del build-dependencies \
 && rm -rf /var/cache/apk/* /root/.cache

# copy custom simple themes and run.sh
RUN rm -rf searx/static/themes/simple/css/* && rm -rf searx/static/themes/simple/img/* && cp -r -v dockerfiles/uwsgi.ini /etc/uwsgi/
COPY ./src/css searx/static/themes/simple/css
COPY ./src/img searx/static/themes/simple/img
COPY ./src/run.sh /usr/local/bin/run.sh

#make run.sh executable, set default settings, precompile searx files
RUN chmod +x /usr/local/bin/run.sh; \
sed -i -e "/safe_search:/s/0/1/g" \
-e "/port:/s/8888/8080/g" \
-e "/bind_address:/s/127.0.0.1/0.0.0.0/g" \
-e "/http_protocol_version:/s/1.0/1.1/g" \
-e "/X-Content-Type-Options: nosniff/d" \
-e "/X-XSS-Protection: 1; mode=block/d" \
-e "/X-Robots-Tag: noindex, nofollow/d" \
-e "/Referrer-Policy: no-referrer/d" \
-e "/default_theme:/s/oscar/simple/g" \
-e "/name: btdigg/s/$/\n    disabled: true/g" \
-e "/name: stackoverflow/s/$/\n    disabled: true/g" \
-e "/name: digg/s/$/\n    disabled: true/g" \
-e "/name: piratebay/s/$/\n    disabled: true/g" \
-e "/name: bandcamp/s/$/\n    disabled: true/g" \
-e "/name: deviantart/s/$/\n    disabled: true/g" \
-e "/name: vimeo/s/$/\n    disabled: true/g" \
-e "/name: openairepublications/s/$/\n    disabled: true/g" \
-e "/name: wikidata/s/$/\n    disabled: true/g" \
-e "/name: library of congress/s/$/\n    disabled: true/g" \
-e "/name: currency/s/$/\n    disabled: true/g" \
-e "/name: dictzone/s/$/\n    disabled: true/g" \
-e "/name: brave/s/$/\n    disabled: true/g" \
-e "/name: genius/s/$/\n    disabled: true/g" \
-e "/name: artic/s/$/\n    disabled: true/g" \
-e "/name: flickr/s/$/\n    disabled: true/g" \
-e "/name: unsplash/s/$/\n    disabled: true/g" \
-e "/name: deezer/s/$/\n    disabled: true/g" \
-e "/name: gentoo/s/$/\n    disabled: true/g" \
-e "/shortcut: fd/{n;s/.*/    disabled: false/}" \
-e "/shortcut: apkm/{n;s/.*/    disabled: false/}" \
searx/settings.yml; \
su searx -c "/usr/bin/python3 -m compileall -q searx"; \
find /usr/local/searx/searx/static -a \( -name '*.html' -o -name '*.css' -o -name '*.js' \
-o -name '*.svg' -o -name '*.ttf' -o -name '*.eot' \) \
-type f -exec gzip -9 -k {} \+ -exec brotli --best {} \+

#expose port and set tini as CMD
EXPOSE 8080
CMD ["/sbin/tini","--","run.sh"]
