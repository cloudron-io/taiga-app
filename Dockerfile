FROM cloudron/base:0.8.0
MAINTAINER Johannes Zellner <support@cloudron.io>

EXPOSE 8000

RUN mkdir -p /app/code /app/data
WORKDIR /app/code

RUN apt-get update && apt-get install -y \
    build-essential binutils-doc autoconf flex bison libjpeg-dev libfreetype6-dev \
    zlib1g-dev libzmq3-dev libgdbm-dev libncurses5-dev automake libtool libffi-dev curl git tmux \
    gettext python3 python3-pip python-dev python3-dev virtualenvwrapper libxml2-dev libxslt-dev \
    postgresql-9.4 postgresql-contrib-9.4 postgresql-server-dev-9.4 nginx

## backend
RUN mkdir /app/code/taiga-back
RUN curl -L https://github.com/taigaio/taiga-back/archive/1.10.0.tar.gz | tar -xz -C /app/code/taiga-back --strip-components 1 -f -

## frontend
RUN mkdir /app/code/taiga-front-dist
RUN curl -L https://github.com/taigaio/taiga-front-dist/archive/1.10.0-stable.tar.gz | tar -xz -C /app/code/taiga-front-dist --strip-components 1 -f -

RUN rm -rf /app/code/taiga-back/media && \
    ln -s /app/data/media /app/code/taiga-back/media

## install all deps in a python virtual env
ADD build.sh /app/code/build.sh
RUN /app/code/build.sh

RUN rm -rf /var/log/nginx && mkdir /run/nginx && ln -s /run/nginx /var/log/nginx
RUN rm -f /app/code/taiga-back/settings/local.py && ln -s /run/local.py /app/code/taiga-back/settings/local.py
RUN rm -f /app/code/taiga-front-dist/dist/conf.json && ln -s /run/conf.json /app/code/taiga-front-dist/dist/conf.json

ADD nginx.conf conf.json local.py start.sh /app/code/

CMD [ "/app/code/start.sh" ]
