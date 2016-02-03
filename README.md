# Taiga

This repository contains the Cloudron app package source for [Taiga](http://taigaio.github.io/).

## Installation

This app uses the ldap community plugin https://github.com/ensky/taiga-contrib-ldap-auth

The main installation guide is at http://taigaio.github.io/taiga-doc/dist/setup-production.html

[![Install](https://cloudron.io/img/button32.png)](https://cloudron.io/button.html?app=io.taiga.cloudronapp)

or using the [Cloudron command line tooling](https://cloudron.io/references/cli.html)

```
cloudron install --appstore-id io.taiga.cloudronapp
```

## Building

The app package can be built using the [Cloudron command line tooling](https://cloudron.io/references/cli.html).

```
cd taiga-app

cloudron build
cloudron install
```

## Testing

No tests yet.
