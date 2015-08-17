#!/bin/bash

# set -eu -o pipefail

echo "========= Start ========="

echo "local.py"
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
    -i /app/code/taiga-back/settings/local.py

# object properties
sed -e "s/\"NAME\": \".*\",/\"NAME\": \"${POSTGRESQL_DATABASE}\",/" \
    -e "s/\"USER\": \".*\",/\"USER\": \"${POSTGRESQL_USERNAME}\",/" \
    -e "s/\"PASSWORD\": \".*\",/\"PASSWORD\": \"${POSTGRESQL_PASSWORD}\",/" \
    -e "s/\"HOST\": \".*\",/\"HOST\": \"${POSTGRESQL_HOST}\",/" \
    -e "s/\"PORT\": \".*\",/\"PORT\": \"${POSTGRESQL_PORT}\",/" \
    -i /app/code/taiga-back/settings/local.py

echo "update conf.json"
sed -e "s/\"api\": \".*\",/\"api\": \"https:\/\/${HOSTNAME}\/api\/v1\/\",/" \
    -e "s/\"eventsUrl\": \".*\",/\"eventsUrl\": \"wss:\/\/${HOSTNAME}\/events\",/" \
    -i /app/code/taiga-front-dist/dist/js/conf.json

echo "update nginx"
service nginx restart

echo "setup taiga virtual env"
cd /app/code
source /app/code/taiga/bin/activate

echo "run migration scripts"
cd /app/code/taiga-back
python manage.py migrate --noinput
# python manage.py loaddata initial_user
python manage.py loaddata initial_project_templates
# python manage.py loaddata initial_role

cd /app/code

taiga/bin/circusd /app/code/circus.ini

read