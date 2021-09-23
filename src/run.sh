#!/bin/sh

# enable built in image proxy
if [ ! -z "${IMAGE_PROXY}" ]; then
    sed -i -e "/image_proxy:/s/false/true/g" \
    searx/settings.yml;
fi

# morty config based on morty_key and and morty_url
if [ ! -z "${MORTY_KEY}" ] && [ ! -z "${MORTY_URL}" ]; then
    sed -i -e "s/# result_proxy:/result_proxy:/g" \
    -e "s+#   url: http://127.0.0.1:3000/+  url : ${MORTY_URL}+g" \
    -e "s/#   key: !!binary \"your_morty_proxy_key\"/  key : !!binary \"${MORTY_KEY}\"/g" \
    -e "s/#   proxify_results: true/  proxify_results: false/g" \
    searx/settings.yml;
fi

# set base_url and instance_name if DOMAIN is not empty
if [ ! -z "${DOMAIN}" ]; then
    sed -i -e "s+base_url: false+base_url: \"https://${DOMAIN}/\"+g" \
    -e "/instance_name:/s/SearXNG/${DOMAIN}/g" \
    searx/settings.yml;
fi

# set contact url
if [ ! -z "${CONTACT}" ]; then
    sed -i -e "/contact_url:/s/false/${CONTACT}/g" \
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

# unset variables in running container
unset MORTY_KEY

# start filtron in front of searx or just searx
if [ ! -z "${FILTRON}" ]; then
    exec uwsgi --master --http-socket "127.0.0.1:3000" "/etc/uwsgi/uwsgi.ini" &
    exec filtron --rules /etc/filtron/rules.json -listen 0.0.0.0:8080 -api 0.0.0.0:4041 -target 127.0.0.1:3000
else
    exec uwsgi --master --http-socket "0.0.0.0:8080" "/etc/uwsgi/uwsgi.ini"
fi
