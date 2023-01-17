#!/bin/bash

# enable built in image proxy
if [ ! -z "${IMAGE_PROXY}" ]; then
    sed -i -e "/image_proxy:/s/false/true/g" \
    searx/settings.yml;
fi

# proxy config based on PROXY env var
if [ ! -z "${PROXY}" ]; then
    sed -i -e "s/  #  proxies:/  proxies:/g" \
    -e "s+  #    all://:+    all://:+g" \
    searx/settings.yml;
    proxies=($(echo ${PROXY} | tr ',' ' '))
    for i in "${proxies[@]}"
    do
        sed -i -e "s+    all://:+    all://:\n      - ${i}+g" \
        searx/settings.yml;
    done
fi

# set UWSGI_WORKERS from env
if [ ! -z "${UWSGI_WORKERS}" ]; then
sed -i -e "s|workers = .*|workers = ${UWSGI_WORKERS}|g" \
/etc/uwsgi/uwsgi.ini
fi

# set UWSGI_THREADS from env
if [ ! -z "${UWSGI_THREADS}" ]; then
sed -i -e "s|threads = .*|threads = ${UWSGI_THREADS}|g" \
/etc/uwsgi/uwsgi.ini
fi

# set redis if REDIS_URL contains URL
if [ ! -z "${REDIS_URL}" ]; then
    sed -i -e "s+  url: false+  url: ${REDIS_URL}+g" \
    searx/settings.yml;
fi

# enable limiter if LIMITER exists
if [ ! -z "${LIMITER}" ]; then
    sed -i -e "s+limiter: false+limiter: true+g" \
    searx/settings.yml;
fi

# set base_url and instance_name if BASE_URL is not empty
if [ ! -z "${BASE_URL}" ]; then
    sed -i -e "s+base_url: false+base_url: \"${BASE_URL}\"+g" \
    searx/settings.yml;
fi

# set instance name
if [ ! -z "${NAME}" ]; then
    sed -i -e "/instance_name:/s/SearXNG/${NAME}/g" \
    searx/settings.yml;
fi

# set privacy policy url
if [ ! -z "${PRIVACYPOLICY}" ]; then
    sed -i -e "s+privacypolicy_url: false+privacypolicy_url: ${PRIVACYPOLICY}+g" \
    searx/settings.yml;
fi

# set contact url
if [ ! -z "${CONTACT}" ]; then
    sed -i -e "s+contact_url: false+contact_url: ${CONTACT}+g" \
    searx/settings.yml;
fi

# set issue url
if [ ! -z "${ISSUE_URL}" ]; then
    sed -i -e "s+issue_url: https://github.com/searxng/searxng/issues+issue_url: ${ISSUE_URL}+g" \
    -e "s+new_issue_url: https://github.com/searxng/searxng/issues/new+new_issue_url: ${ISSUE_URL}/new+g" \
    searx/settings.yml;
fi

# set git url
if [ ! -z "${GIT_URL}" ]; then
    sed -i -e "s+GIT_URL = \"https://github.com/searxng/searxng\"+GIT_URL = \"${GIT_URL}\"+g" \
    searx/version_frozen.py; \
fi

# set git branch
if [ ! -z "${GIT_BRANCH}" ]; then
    sed -i -e "/GIT_BRANCH/s/\".*\"/\"${GIT_BRANCH}\"/g" \
    searx/version_frozen.py; \
fi

# auto gen random key for every unique container
sed -i -e "s/ultrasecretkey/$(openssl rand -hex 16)/g" \
searx/settings.yml

# start uwsgi with SearXNG workload
exec uwsgi --master --http-socket "0.0.0.0:8080" "/etc/uwsgi/uwsgi.ini"
