#!/bin/bash

# set -eu -o pipefail

echo "========= Start ========="

echo "--> local.py"
sed -e "s/##APP_DOMAIN##/${APP_DOMAIN}/" \
    -e "s/##MAIL_DOMAIN##/${MAIL_DOMAIN}/" \
    -e "s/##MAIL_SMTP_SERVER##/${MAIL_SMTP_SERVER}/" \
    -e "s/##MAIL_SMTP_PORT##/${MAIL_SMTP_PORT}/" \
    -e "s/##MAIL_SMTP_USERNAME##/${MAIL_SMTP_USERNAME}/" \
    -e "s/##LDAP_SERVER##/${LDAP_SERVER}/" \
    -e "s/##LDAP_PORT##/${LDAP_PORT}/" \
    -e "s/##LDAP_USERS_BASE_DN##/${LDAP_USERS_BASE_DN}/" \
    -e "s/##POSTGRESQL_DATABASE##/${POSTGRESQL_DATABASE}/" \
    -e "s/##POSTGRESQL_USERNAME##/${POSTGRESQL_USERNAME}/" \
    -e "s/##POSTGRESQL_PASSWORD##/${POSTGRESQL_PASSWORD}/" \
    -e "s/##POSTGRESQL_HOST##/${POSTGRESQL_HOST}/" \
    -e "s/##POSTGRESQL_PORT##/${POSTGRESQL_PORT}/" \
    /app/code/local.py  > /run/local.py

echo "--> Update conf.json"
sed -e "s/##APP_DOMAIN##/${APP_DOMAIN}/" /app/code/conf.json > /run/conf.json

echo "--> Update nginx.conf"
sed -e "s,##APP_DOMAIN##,${APP_DOMAIN}," /app/code/nginx.conf  > /run/nginx.conf

echo "--> Setup taiga virtual env"
source /app/code/taiga/bin/activate

echo "--> Run migration scripts"
if [[ ! -d /app/data/media/user ]]; then
    echo "--> New installation create inital project templates"

    mkdir -p /app/data/media/user
    cd /app/code/taiga-back

    python manage.py migrate --noinput
    python manage.py loaddata initial_project_templates
fi

echo "--> Make cloudron own /run"
chown -R cloudron:cloudron /run
chown -R cloudron:cloudron /app/data

echo "--> Start nginx"
nginx -c /run/nginx.conf &

echo "--> Start taiga-back"
PATH=/app/code/taiga/bin:$PATH
HOME=/app/code
PYTHONPATH=/app/code/taiga/lib/python3.4/site-packages

cd /app/code/taiga-back

exec /usr/local/bin/gosu cloudron:cloudron gunicorn -w 1 -t 60 --pythonpath=. -b 127.0.0.1:8001 taiga.wsgi
