# use prebuild filtron image from filtron branch
FROM registry.paulgo.dev/paulgoio/searxng:filtron as builder



# use prebuild alpine image with needed python packages from base branch
FROM registry.paulgo.dev/paulgoio/searxng:base
ENV GID=991 UID=991 IMAGE_PROXY= MORTY_KEY= MORTY_URL= REDIS_URL= LIMITER= LIMITER2= BASE_URL= NAME= CONTACT= ISSUE_URL= GIT_URL= GIT_BRANCH= FILTRON= \
UPSTREAM_COMMIT=a4942213a1dc6404616e239e0d2fb55a6e19a499
WORKDIR /usr/local/searxng

# install build deps and git clone searxng as well as setting the version
RUN addgroup -g ${GID} searxng \
&& adduser -u ${UID} -D -h /usr/local/searxng -s /bin/sh -G searxng searxng \
&& git clone https://github.com/searxng/searxng.git . \
&& git reset --hard ${UPSTREAM_COMMIT} \
&& chown -R searxng:searxng . \
&& su searxng -c "/usr/bin/python3 -m searx.version freeze" \
&& sed -i -e "/VERSION_STRING/s/-.*\"/\"/g" searx/version_frozen.py

# copy custom simple themes, run.sh, limiter2 and filtron
COPY ./src/css/* searx/static/themes/simple/css/
COPY ./src/run.sh /usr/local/bin/run.sh
COPY ./src/limiter2.py /usr/local/searxng/searx/extra/limiter2.py
COPY --from=builder /go/src/github.com/searxng/filtron/filtron /usr/local/bin/filtron
COPY ./src/rules.json /etc/filtron/rules.json

# make run.sh executable, remove css maps (since the builder does not support css maps for now), copy uwsgi server ini, set default settings, precompile static theme files
RUN cp -r -v dockerfiles/uwsgi.ini /etc/uwsgi/; \
rm -rf searx/static/themes/simple/css/searxng.min.css.map; \
rm -rf searx/static/themes/simple/css/searxng-rtl.min.css.map; \
chmod +x /usr/local/bin/run.sh; \
sed -i -e "/safe_search:/s/0/1/g" \
-e "/autocomplete:/s/\"\"/\"google\"/g" \
-e "/port:/s/8888/8080/g" \
-e "/bind_address:/s/127.0.0.1/0.0.0.0/g" \
-e "/http_protocol_version:/s/1.0/1.1/g" \
-e "/X-Content-Type-Options: nosniff/d" \
-e "/X-XSS-Protection: 1; mode=block/d" \
-e "/X-Robots-Tag: noindex, nofollow/d" \
-e "/Referrer-Policy: no-referrer/d" \
-e "/default_theme:/s/oscar/simple/g" \
-e "s/    use_mobile_ui: false/    use_mobile_ui: true/g" \
-e "/name: btdigg/s/$/\n    disabled: true/g" \
-e "/name: deviantart/s/$/\n    disabled: true/g" \
-e "/name: vimeo/s/$/\n    disabled: true/g" \
-e "/name: openairepublications/s/$/\n    disabled: true/g" \
-e "/name: wikidata/s/$/\n    disabled: true/g" \
-e "/name: library of congress/s/$/\n    disabled: true/g" \
-e "/name: dictzone/s/$/\n    disabled: true/g" \
-e "/name: brave/s/$/\n    disabled: true/g" \
-e "/name: genius/s/$/\n    disabled: true/g" \
-e "/name: artic/s/$/\n    disabled: true/g" \
-e "/name: flickr/s/$/\n    disabled: true/g" \
-e "/name: unsplash/s/$/\n    disabled: true/g" \
-e "/name: gentoo/s/$/\n    disabled: true/g" \
-e "/name: openverse/s/$/\n    disabled: true/g" \
-e "/name: google videos/s/$/\n    disabled: true/g" \
-e "/name: yahoo news/s/$/\n    disabled: true/g" \
-e "/name: bing news/s/$/\n    disabled: true/g" \
-e "/name: tineye/s/$/\n    disabled: true/g" \
-e "/shortcut: fd/{n;s/.*/    disabled: false/}" \
searx/settings.yml; \
touch /var/run/uwsgi-logrotate; \
chown -R searxng:searxng /var/log/uwsgi /var/run/uwsgi-logrotate; \
su searxng -c "/usr/bin/python3 -m compileall -q searx"; \
find /usr/local/searxng/searx/static -a \( -name '*.html' -o -name '*.css' -o -name '*.js' -o -name '*.svg' -o -name '*.ttf' -o -name '*.eot' \) \
-type f -exec gzip -9 -k {} \+ -exec brotli --best {} \+

# expose port and set tini as CMD; default user is searxng
USER searxng
EXPOSE 8080
CMD ["/sbin/tini","--","run.sh"]
