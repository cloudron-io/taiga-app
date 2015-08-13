#!/bin/bash

# set -eu -o pipefail

echo "==============="

echo "local.py"
sed -e "s/MEDIA_URL = \".*\"/MEDIA_URL = \"https:\/\/${HOSTNAME}\/media\/\"/" \
    -e "s/STATIC_URL = \".*\"/STATIC_URL = \"https:\/\/${HOSTNAME}\/static\/\"/" \
    -e "s/ADMIN_MEDIA_PREFIX = \".*\"/ADMIN_MEDIA_PREFIX = \"https:\/\/${HOSTNAME}\/static\/admin\/\"/" \
    -e "s/SITES\[\"front\"\]\[\"scheme\"\] = \".*\"/SITES\[\"front\"\]\[\"scheme\"\] = \"https\"/" \
    -e "s/SITES\[\"front\"\]\[\"domain\"\] = \".*\"/SITES\[\"front\"\]\[\"domain\"\] = \"${HOSTNAME}\"/" \
    -e "s/\"NAME\": \".*\",/\"NAME\": \"${POSTGRESQL_DATABASE}\",/" \
    -e "s/\"USER\": \".*\",/\"USER\": \"${POSTGRESQL_USERNAME}\",/" \
    -e "s/\"PASSWORD\": \".*\",/\"PASSWORD\": \"${POSTGRESQL_PASSWORD}\",/" \
    -e "s/\"HOST\": \".*\",/\"HOST\": \"${POSTGRESQL_HOST}\",/" \
    -e "s/\"PORT\": \".*\",/\"PORT\": \"${POSTGRESQL_PORT}\",/" \
    -e "s/\"EMAIL_HOST\": \".*\",/\"EMAIL_HOST\": \"${MAIL_SMTP_SERVER}\",/" \
    -e "s/\"EMAIL_PORT\": \".*\",/\"EMAIL_PORT\": \"${MAIL_SMTP_PORT}\",/" \
    -e "s/\"EMAIL_HOST_USER\": \".*\",/\"EMAIL_HOST_USER\": \"${MAIL_SMTP_USERNAME}\",/" \
    -i /app/code/taiga-back/settings/local.py

echo "update conf.json"
sed -e "s/\"api\": \".*\",/\"api\": \"https:\/\/${HOSTNAME}\/api\/v1\/\",/" \
    -e "s/\"eventsUrl\": \".*\",/\"eventsUrl\": \"ws:\/\/${HOSTNAME}\/events\",/" \
    -i /app/code/taiga-front-dist/dist/js/conf.json

# cd /app/code/taiga-back/
# python manage.py migrate --noinput
# python manage.py loaddata initial_user
# python manage.py loaddata initial_project_templates
# python manage.py loaddata initial_role
# python manage.py compilemessages
# python manage.py collectstatic --noinput

echo "update nginx"
service nginx restart

echo "setup taiga"
cd /app/code
virtualenv -p /usr/bin/python3.4 taiga
source /app/code/taiga/bin/activate

python --version

echo "install pip"
easy_install pip

echo "install circus"
pip install circus

echo "install taiga deps"
cd /app/code/taiga-back
pip install -r requirements.txt

cd /app/code

# /usr/local/bin/circusd /app/code/circus.ini

read