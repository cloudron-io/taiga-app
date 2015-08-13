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

read