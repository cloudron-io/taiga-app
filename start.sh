#!/bin/bash

set -eu -o pipefail

echo "==============="

# RUN python manage.py migrate --noinput
# RUN python manage.py loaddata initial_user
# RUN python manage.py loaddata initial_project_templates
# RUN python manage.py loaddata initial_role
# RUN python manage.py compilemessages
# RUN python manage.py collectstatic --noinput

#service circus start
#service nginx restart

echo "local.py"
sed -e "s/MEDIA_URL = \".*\"/MEDIA_URL = \"https:\/\/${HOSTNAME}\/media\/\"/" \
    -e "s/STATIC_URL = \".*\"/STATIC_URL = \"https:\/\/${HOSTNAME}\/static\/\"/" \
    -e "s/ADMIN_MEDIA_PREFIX = \".*\"/ADMIN_MEDIA_PREFIX = \"https:\/\/${HOSTNAME}\/static\/admin\/\"/" \
    -e "s/SITES\[\"front\"\]\[\"scheme\"\] = \".*\"/SITES\[\"front\"\]\[\"scheme\"\] = \"https\"/" \
    -e "s/SITES\[\"front\"\]\[\"domain\"\] = \".*\"/SITES\[\"front\"\]\[\"domain\"\] = \"${HOSTNAME}\"/" \
    -i /app/code/taiga-back/settings/local.py

echo "update conf.json"
sed -e "s/\"api\": \".*\",/\"api\": \"https:\/\/${HOSTNAME}\/api\/v1\/\",/" \
    -e "s/\"eventsUrl\": \".*\",/\"eventsUrl\": \"ws:\/\/${HOSTNAME}\/events\",/" \
    -i /app/code/taiga-front-dist/dist/js/conf.json

echo "update nginx"

read