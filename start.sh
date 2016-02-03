#!/bin/bash

# set -eu -o pipefail

echo "========= Start ========="

echo "--> local.py"
# toplevel variables
sed -e "s/MEDIA_URL = \".*\"/MEDIA_URL = \"https:\/\/${HOSTNAME}\/media\/\"/" \
    -e "s/STATIC_URL = \".*\"/STATIC_URL = \"https:\/\/${HOSTNAME}\/static\/\"/" \
    -e "s/ADMIN_MEDIA_PREFIX = \".*\"/ADMIN_MEDIA_PREFIX = \"https:\/\/${HOSTNAME}\/static\/admin\/\"/" \
    -e "s/SITES\[\"front\"\]\[\"scheme\"\] = \".*\"/SITES\[\"front\"\]\[\"scheme\"\] = \"https\"/" \
    -e "s/SITES\[\"front\"\]\[\"domain\"\] = \".*\"/SITES\[\"front\"\]\[\"domain\"\] = \"${HOSTNAME}\"/" \
    -e "s/EMAIL_HOST = \".*\"/EMAIL_HOST = \"${MAIL_SMTP_SERVER}\"/" \
    -e "s/EMAIL_PORT = \".*\"/EMAIL_PORT = \"${MAIL_SMTP_PORT}\"/" \
    -e "s/EMAIL_HOST_USER = \".*\"/EMAIL_HOST_USER = \"${MAIL_SMTP_USERNAME}\"/" \
    -e "s/LDAP_SERVER = \".*\"/LDAP_SERVER = \"ldap:\/\/${LDAP_SERVER}\"/" \
    -e "s/LDAP_PORT = .*/LDAP_PORT = ${LDAP_PORT}/" \
    -e "s/LDAP_SEARCH_BASE = \".*\"/LDAP_SEARCH_BASE = \"${LDAP_USERS_BASE_DN}\"/" \
    -e "s/\"NAME\": \".*\",/\"NAME\": \"${POSTGRESQL_DATABASE}\",/" \
    -e "s/\"USER\": \".*\",/\"USER\": \"${POSTGRESQL_USERNAME}\",/" \
    -e "s/\"PASSWORD\": \".*\",/\"PASSWORD\": \"${POSTGRESQL_PASSWORD}\",/" \
    -e "s/\"HOST\": \".*\",/\"HOST\": \"${POSTGRESQL_HOST}\",/" \
    -e "s/\"PORT\": \".*\",/\"PORT\": \"${POSTGRESQL_PORT}\",/" \
    /app/code/local.py  > /run/local.py

echo "--> Update conf.json"
sed -e "s/\"api\": \".*\",/\"api\": \"https:\/\/${APP_DOMAIN}\/api\/v1\/\",/" \
    -e "s/\"eventsUrl\": \".*\",/\"eventsUrl\": \"wss:\/\/${APP_DOMAIN}\/events\",/" \
    /app/code/conf.json > /run/conf.json

echo "--> Update nginx.conf"
sed -e "s,##HOSTNAME##,${APP_DOMAIN}," \
    /app/code/nginx.conf  > /run/nginx.conf

echo "--> Setup taiga virtual env"
cd /app/code
source /app/code/taiga/bin/activate

echo "--> Run migration scripts"
cd /app/code/taiga-back
python manage.py migrate --noinput
# python manage.py loaddata initial_user
python manage.py loaddata initial_project_templates
# python manage.py loaddata initial_role

cd /app/code

echo "--> Make cloudron own /run"
chown -R cloudron:cloudron /run

echo "--> Start nginx"
nginx -c /run/nginx.conf &

echo "--> Start taiga-back"
PATH=/app/code/taiga/bin:$PATH
TERM=rxvt-256color

SHELL=/bin/bash
USER=root
LANG=en_US.UTF-8
HOME=/app/code
PYTHONPATH=/app/code/taiga/lib/python3.4/site-packages

cd /app/code/taiga-back

exec /usr/local/bin/gosu cloudron:cloudron gunicorn -w 1 -t 60 --pythonpath=. -b 127.0.0.1:8001 taiga.wsgi
# taiga/bin/circusd /app/code/circus.ini
