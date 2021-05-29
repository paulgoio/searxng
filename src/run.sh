#!/bin/sh

#change settings based on env
sed -i -e "s/ultrasecretkey/$(openssl rand -hex 16)/g" \
-e "s/{MORTY_KEY}/${MORTY_KEY}/g" \
searx/settings.yml

# chown log dir on runtime
chown -R searx:searx /var/log/uwsgi /var/run/uwsgi-logrotate

# exec uwsgi prod server with tini
exec su-exec searx:searx uwsgi --master --http-socket "0.0.0.0:8080" "/etc/uwsgi/uwsgi.ini"
