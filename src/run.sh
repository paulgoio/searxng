#!/bin/sh

# morty config based on morty_key and domain
if [ ! -z "${MORTY_KEY}" ]; then
    sed -i -e "/image_proxy :/s/False/True/g" \
    -e "s/#result_proxy:/result_proxy:/g" \
    -e "s+#    url : http://127.0.0.1:3000/+    url : https://${DOMAIN}/morty/+g" \
    -e "s/#    key : !!binary \"your_morty_proxy_key\"/    key : !!binary \"${MORTY_KEY}\"/g" \
    searx/settings.yml;
fi

# set base_url and instance_name if DOMAIN is not empty
if [ ! -z "${DOMAIN}" ]; then
    sed -i -e "s+base_url : False+base_url : \"https://${DOMAIN}/\"+g" \
    -e "/instance_name :/s/searx/${DOMAIN}/g" \
    searx/settings.yml;
fi

# set contact url
if [ ! -z "${CONTACT}" ]; then
    sed -i -e "/contact_url:/s/False/${CONTACT}/g" \
    searx/settings.yml;
fi

# set git and git issue url
if [ ! -z "${GIT_URL}" ]; then
    sed -i -e "s+git_url: https://github.com/searx/searx+git_url: ${GIT_URL}+g" \
    -e "s+issue_url: https://github.com/searx/searx/issues+issue_url: ${GIT_URL}/issues+g" \
    searx/settings.yml;
fi

# set twitter url
if [ ! -z "${TWITTER}" ]; then
    sed -i -e "s+twitter_url: https://twitter.com/Searx_engine+twitter_url: https://twitter.com/${TWITTER}+g" \
    searx/settings.yml;
fi

# auto gen random key for every unique container
sed -i -e "s/ultrasecretkey/$(openssl rand -hex 16)/g" \
searx/settings.yml

# touch and chown log dir on runtime
touch /var/run/uwsgi-logrotate
chown -R searx:searx /var/log/uwsgi /var/run/uwsgi-logrotate

# unset variables in running container
unset MORTY_KEY

# exec uwsgi prod server with tini
exec su-exec searx:searx uwsgi --master --http-socket "0.0.0.0:8080" "/etc/uwsgi/uwsgi.ini"
