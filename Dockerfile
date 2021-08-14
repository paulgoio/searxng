# minify css files
FROM tdewolff/minify:latest as builder
COPY src/css /css
RUN cd /css && minify searx.css -o searx.min.css && minify searx-rtl.css -o searx-rtl.min.css


# use alpine as base for searx and set workdir as well as env vars
FROM alpine:3.14
ENV GID=991 UID=991 MORTY_KEY= DOMAIN= CONTACT= ISSUE_URL=
WORKDIR /usr/local/searx

# install build deps and git clone searx
RUN addgroup -g ${GID} searx \
&& adduser -u ${UID} -D -h /usr/local/searx -s /bin/sh -G searx searx; \
apk -U upgrade \
&& apk add --no-cache -t build-dependencies build-base py3-setuptools python3-dev libffi-dev libxslt-dev libxml2-dev openssl-dev git tar \
&& apk add --no-cache ca-certificates su-exec python3 py3-pip libxml2 libxslt openssl tini uwsgi uwsgi-python3 brotli \
&& git clone https://github.com/searxng/searxng.git . \
&& chown -R searx:searx . \
pip install --upgrade pip \
&& pip install --no-cache -r requirements.txt \
&& su searx -c "/usr/bin/python3 -m searx.version freeze" \
&& sed -i -e "/VERSION_STRING/s/-.*\"/\"/g" \
-e "/GIT_URL/s/searxng\/searxng/paulgoio\/searx/g" \
-e "/GIT_BRANCH/s/master/main/g" \
searx/version_frozen.py; \
&& apk del build-dependencies \
&& rm -rf /var/cache/apk/* /root/.cache

# copy custom simple themes and run.sh
COPY --from=builder /css/* searx/static/themes/simple/css/
COPY ./src/run.sh /usr/local/bin/run.sh

# make run.sh executable, remove css maps (since the builder does not support css maps for now), copy uwsgi server ini, set default settings, precompile static theme files
RUN cp -r -v dockerfiles/uwsgi.ini /etc/uwsgi/; \
rm -rf searx/static/themes/simple/css/searx.min.css.map; \
rm -rf searx/static/themes/simple/css/searx-rtl.min.css.map; \
chmod +x /usr/local/bin/run.sh; \
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
-e "/name: gentoo/s/$/\n    disabled: true/g" \
-e "/shortcut: fd/{n;s/.*/    disabled: false/}" \
-e "/shortcut: apkm/{n;s/.*/    disabled: false/}" \
-e "/shortcut: ddg/{n;s/.*/    disabled: false/}" \
searx/settings.yml; \
su searx -c "/usr/bin/python3 -m compileall -q searx"; \
find /usr/local/searx/searx/static -a \( -name '*.html' -o -name '*.css' -o -name '*.js' \
-o -name '*.svg' -o -name '*.ttf' -o -name '*.eot' \) \
-type f -exec gzip -9 -k {} \+ -exec brotli --best {} \+

# expose port and set tini as CMD
EXPOSE 8080
CMD ["/sbin/tini","--","run.sh"]
