# built filtron from upstream dalf/filtron
FROM golang:1.14-alpine as builder
WORKDIR $GOPATH/src/github.com/asciimoo/filtron

# add gcc musl-dev for "go test"; get source and build filtron
RUN apk add --no-cache git
RUN git clone https://github.com/dalf/filtron.git .
RUN go get -d -v
RUN gofmt -l ./
# RUN go vet -v ./...
# RUN go test -v ./...
RUN go build .



# use alpine as base for searx and set workdir as well as env vars
FROM alpine:3.14
ENV GID=991 UID=991 IMAGE_PROXY= MORTY_KEY= MORTY_URL= DOMAIN= CONTACT= ISSUE_URL= GIT_URL= GIT_BRANCH= FILTRON=
WORKDIR /usr/local/searx

# install build deps and git clone searxng as well as setting the version
RUN addgroup -g ${GID} searx \
&& adduser -u ${UID} -D -h /usr/local/searx -s /bin/sh -G searx searx; \
apk -U upgrade \
&& apk add --no-cache -t build-dependencies build-base py3-setuptools python3-dev libffi-dev libxslt-dev libxml2-dev openssl-dev git tar \
&& apk add --no-cache ca-certificates su-exec python3 py3-pip libxml2 libxslt openssl tini uwsgi uwsgi-python3 brotli \
&& git clone https://github.com/searxng/searxng.git . \
&& chown -R searx:searx . \
&& pip install --upgrade pip \
&& pip install --no-cache -r requirements.txt \
&& su searx -c "/usr/bin/python3 -m searx.version freeze" \
&& sed -i -e "/VERSION_STRING/s/-.*\"/\"/g" searx/version_frozen.py; \
apk del build-dependencies \
&& rm -rf /var/cache/apk/* /root/.cache

# copy custom simple themes, run.sh and filtron
COPY ./src/css/* searx/static/themes/simple/css/
COPY ./src/run.sh /usr/local/bin/run.sh
COPY --from=builder /go/src/github.com/asciimoo/filtron/filtron /usr/local/bin/filtron
COPY ./src/rules.json /etc/filtron/rules.json

# make run.sh executable, remove css maps (since the builder does not support css maps for now), copy uwsgi server ini, set default settings, precompile static theme files
RUN cp -r -v dockerfiles/uwsgi.ini /etc/uwsgi/; \
rm -rf searx/static/themes/simple/css/searxng.min.css.map; \
rm -rf searx/static/themes/simple/css/searxng-rtl.min.css.map; \
chmod +x /usr/local/bin/run.sh; \
sed -i -e "/autocomplete:/s/\"\"/\"google\"/g" \
-e "/port:/s/8888/8080/g" \
-e "/bind_address:/s/127.0.0.1/0.0.0.0/g" \
-e "/http_protocol_version:/s/1.0/1.1/g" \
-e "/X-Content-Type-Options: nosniff/d" \
-e "/X-XSS-Protection: 1; mode=block/d" \
-e "/X-Robots-Tag: noindex, nofollow/d" \
-e "/Referrer-Policy: no-referrer/d" \
-e "/default_theme:/s/oscar/simple/g" \
-e "/name: btdigg/s/$/\n    disabled: true/g" \
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
sed -i -e "/workers = 4/s/$/\n# Enable 4 threads per core\nthreads = 4\n\nauto-procname = true/g" /etc/uwsgi/uwsgi.ini; \
touch /var/run/uwsgi-logrotate; \
chown -R searx:searx /var/log/uwsgi /var/run/uwsgi-logrotate; \
su searx -c "/usr/bin/python3 -m compileall -q searx"; \
find /usr/local/searx/searx/static -a \( -name '*.html' -o -name '*.css' -o -name '*.js' -o -name '*.svg' -o -name '*.ttf' -o -name '*.eot' \) \
-type f -exec gzip -9 -k {} \+ -exec brotli --best {} \+

# expose port and set tini as CMD; default user is searx
USER searx
EXPOSE 8080
CMD ["/sbin/tini","--","run.sh"]
