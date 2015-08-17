#!/bin/bash

# set -eu -o pipefail

echo "========= Build ========="

echo "setup taiga virtualenv"
cd /app/code
virtualenv -p /usr/bin/python3.4 taiga
source /app/code/taiga/bin/activate

echo "install circus"
pip install circus

echo "install pip"
easy_install pip

echo "install taiga deps"
cd /app/code/taiga-back
pip install -r requirements.txt

echo "install taiga-contrib-ldap-auth"
pip install taiga-contrib-ldap-auth

echo "run migration scripts"
cd /app/code/taiga-back
python manage.py collectstatic --noinput
python manage.py compilemessages