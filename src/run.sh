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

# set default search lang
if [ ! -z "${SEARCH_DEFAULT_LANG}" ]; then
    sed -i -e "s+default_lang: \"auto\"+default_lang: \"${SEARCH_DEFAULT_LANG}\"+g" \
    searx/settings.yml;
fi

# set engine suspension timeout if a SearxEngineAccessDenied exception occours
if [ ! -z "${SEARCH_ENGINE_ACCESS_DENIED}" ]; then
    sed -i -e "/    SearxEngineAccessDenied/s/86400/${SEARCH_ENGINE_ACCESS_DENIED}/g" \
    searx/settings.yml;
fi

# set instance as public instance to enable some features that are only needed for public instances
if [ ! -z "${PUBLIC_INSTANCE}" ]; then
    sed -i -e "/public_instance:/s/false/true/g" \
    searx/settings.yml;
fi

# enable /metrics if METRICS_PASSWORD is set
if [ ! -z "${METRICS_PASSWORD}" ]; then
    sed -i -e "s|open_metrics: ''|open_metrics: '${METRICS_PASSWORD}'|g" \
    searx/settings.yml;
fi

# auto gen random key for every unique container
sed -i -e "s/ultrasecretkey/$(openssl rand -hex 16)/g" \
searx/settings.yml

# start uwsgi with SearXNG workload
exec uwsgi --master --uid searxng --gid searxng --http-socket "0.0.0.0:8080" "/etc/uwsgi/uwsgi.ini"
