FROM ubuntu:16.04
MAINTAINER InAcademia Team, tech@inacademia.org

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    python3-dev \
    build-essential \
    python3-pip \
    libffi-dev \
    libssl-dev \
    xmlsec1 \
    libyaml-dev \
    rsyslog \
    ssh-client \
    virtualenv
RUN apt clean

RUN pip3 install --upgrade pip setuptools
RUN mkdir /root/.ssh

COPY config/id_rsa_inacademia /tmp/inacademia/id_rsa_inacademia

COPY config/root_ssh_config /root/.ssh/config
COPY config/root_ssh_known_hosts /root/.ssh/known_hosts
COPY config/rsyslog/rsyslog.conf /etc/rsyslog.conf
COPY config/rsyslog/inacademia.conf /etc/rsyslog.d/inacademia.conf
COPY config/production/attributemaps /tmp/inacademia/attributemaps
COPY config/cdb/cdb.json.example /etc/cdb/cdb.json
COPY config/start.sh /tmp/inacademia/start.sh
COPY config/install.sh /tmp/inacademia/install.sh

#ENTRYPOINT ["/tmp/inacademia/start.sh"]
ENTRYPOINT /bin/bash
