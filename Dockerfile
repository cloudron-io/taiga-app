FROM cloudron/base:0.3.1
MAINTAINER Taiga Authors <support@cloudron.io>

EXPOSE 8000

RUN apt-get update
RUN apt-get install -y build-essential binutils-doc autoconf flex bison libjpeg-dev
RUN apt-get install -y libfreetype6-dev zlib1g-dev libzmq3-dev libgdbm-dev libncurses5-dev
RUN apt-get install -y automake libtool libffi-dev curl git tmux gettext

RUN apt-get install -y python3 python3-pip python-dev python3-dev python-pip virtualenvwrapper
RUN apt-get install -y libxml2-dev libxslt-dev

RUN apt-get install -y nginx

## backend
WORKDIR /app/code
RUN git clone https://github.com/taigaio/taiga-back.git taiga-back
WORKDIR /app/code/taiga-back
RUN git checkout stable
RUN mkvirtualenv -p /usr/bin/python3.4 taiga
RUN pip install -r requirements.txt

## frontend
WORKDIR /app/code
RUN git clone https://github.com/taigaio/taiga-front-dist.git taiga-front-dist
WORKDIR /app/code/taiga-front-dist
RUN git checkout stable

## circus process manager
RUN pip2 install circus

ADD circus.ini /app/code/circus.ini
ADD circus.conf /etc/init/circus.conf
RUN rm /etc/nginx/sites-enabled/default
ADD taiga.nginx.conf /etc/nginx/sites-enabled/taiga
ADD start.sh /app/code/start.sh

CMD [ "/app/code/start.sh" ]
