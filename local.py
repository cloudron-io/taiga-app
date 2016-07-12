

from .common import *

MEDIA_URL = "https://##APP_DOMAIN##/media/"
STATIC_URL = "https://##APP_DOMAIN##/static/"
ADMIN_MEDIA_PREFIX = "https://##APP_DOMAIN##/static/admin/"
SITES["front"]["scheme"] = "https"
SITES["front"]["domain"] = "##APP_DOMAIN##"

SECRET_KEY = "theveryultratopsecretkey"

DEBUG = False
TEMPLATE_DEBUG = False
PUBLIC_REGISTER_ENABLED = True

DEFAULT_FROM_EMAIL = "##MAIL_FROM##"
SERVER_EMAIL = DEFAULT_FROM_EMAIL

# Uncomment and populate with proper connection parameters
# for enable email sending. EMAIL_HOST_USER should end by @domain.tld
EMAIL_BACKEND = "django.core.mail.backends.smtp.EmailBackend"
EMAIL_USE_TLS = False
EMAIL_HOST = "##MAIL_SMTP_SERVER##"
EMAIL_PORT = ##MAIL_SMTP_PORT##
EMAIL_HOST_USER = "##MAIL_SMTP_USERNAME##"
EMAIL_HOST_PASSWORD = "##MAIL_SMTP_PASSWORD##"

# Database config
DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": "##POSTGRESQL_DATABASE##",
        "USER": "##POSTGRESQL_USERNAME##",
        "PASSWORD": "##POSTGRESQL_PASSWORD##",
        "HOST": "##POSTGRESQL_HOST##",
        "PORT": "##POSTGRESQL_PORT##",
    }
}

INSTALLED_APPS += ["taiga_contrib_ldap_auth"]

LDAP_SERVER = "ldap://##LDAP_SERVER##"
LDAP_PORT = ##LDAP_PORT##

# Full DN of the service account use to connect to LDAP server and search for login user's account entry
# If LDAP_BIND_DN is not specified, or is blank, then an anonymous bind is attempated
LDAP_BIND_DN = ""
LDAP_BIND_PASSWORD = ""
# Starting point within LDAP structure to search for login user
LDAP_SEARCH_BASE = "##LDAP_USERS_BASE_DN##"
# LDAP property used for searching, ie. login username needs to match value in sAMAccountName property in LDAP
LDAP_SEARCH_PROPERTY = "sAMAccountName"
LDAP_SEARCH_SUFFIX = None # '@example.com'

# Names of LDAP properties on user account to get email and full name
LDAP_EMAIL_PROPERTY = "mail"
LDAP_FULL_NAME_PROPERTY = "displayname"
