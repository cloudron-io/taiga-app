FROM cloudron/base:0.3.1
MAINTAINER Taiga Authors <support@cloudron.io>

EXPOSE 8000

RUN apt-get update
RUN apt-get install -y build-essential binutils-doc autoconf flex bison libjpeg-dev
RUN apt-get install -y libfreetype6-dev zlib1g-dev libzmq3-dev libgdbm-dev libncurses5-dev
RUN apt-get install -y automake libtool libffi-dev curl git tmux gettext

RUN apt-get install -y python3 python3-pip python-dev python3-dev virtualenvwrapper
RUN apt-get install -y libxml2-dev libxslt-dev

RUN apt-get install -y postgresql-9.4 postgresql-contrib-9.4 postgresql-server-dev-9.4

RUN apt-get install -y nginx

WORKDIR /app/code

## backend
RUN git clone https://github.com/taigaio/taiga-back.git taiga-back
WORKDIR /app/code/taiga-back
RUN git checkout stable

## frontend
WORKDIR /app/code
RUN git clone https://github.com/taigaio/taiga-front-dist.git taiga-front-dist
WORKDIR /app/code/taiga-front-dist
RUN git checkout stable

WORKDIR /app/code

ADD circus.ini /app/code/circus.ini
RUN rm /etc/nginx/sites-enabled/default
ADD taiga.nginx.conf /etc/nginx/sites-enabled/taiga
ADD conf.json /app/code/taiga-front-dist/dist/js/conf.json
ADD local.py /app/code/taiga-back/settings/local.py
ADD start.sh /app/code/start.sh

CMD [ "/app/code/start.sh" ]
