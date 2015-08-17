

from .common import *

MEDIA_URL = "http://example.com/media/"
STATIC_URL = "http://example.com/static/"
ADMIN_MEDIA_PREFIX = "http://example.com/static/admin/"
SITES["front"]["scheme"] = "http"
SITES["front"]["domain"] = "example.com"

SECRET_KEY = "theveryultratopsecretkey"

DEBUG = False
TEMPLATE_DEBUG = False
PUBLIC_REGISTER_ENABLED = True

DEFAULT_FROM_EMAIL = "no-reply@example.com"
SERVER_EMAIL = DEFAULT_FROM_EMAIL

# Uncomment and populate with proper connection parameters
# for enable email sending. EMAIL_HOST_USER should end by @domain.tld
EMAIL_BACKEND = "django.core.mail.backends.smtp.EmailBackend"
EMAIL_USE_TLS = False
EMAIL_HOST = "localhost"
EMAIL_PORT = 25
EMAIL_HOST_USER = ""
# EMAIL_HOST_PASSWORD = ""

# Database config
DATABASES = {
    "default": {
        "ENGINE": "transaction_hooks.backends.postgresql_psycopg2",
        "NAME": "taiga",
        "USER": "taiga",
        "PASSWORD": "changeme",
        "HOST": "",
        "PORT": "",
    }
}

INSTALLED_APPS += ["taiga_contrib_ldap_auth"]

LDAP_SERVER = "ldap://ldap.example.com"
LDAP_PORT = 389

# Full DN of the service account use to connect to LDAP server and search for login user's account entry
# If LDAP_BIND_DN is not specified, or is blank, then an anonymous bind is attempated
LDAP_BIND_DN = ""
LDAP_BIND_PASSWORD = ""
# Starting point within LDAP structure to search for login user
LDAP_SEARCH_BASE = "OU=DevTeam,DC=example,DC=net"
# LDAP property used for searching, ie. login username needs to match value in sAMAccountName property in LDAP
LDAP_SEARCH_PROPERTY = "sAMAccountName"
LDAP_SEARCH_SUFFIX = None # '@example.com'

# Names of LDAP properties on user account to get email and full name
LDAP_EMAIL_PROPERTY = "mail"
LDAP_FULL_NAME_PROPERTY = "displayname"