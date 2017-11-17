FROM ubuntu:16.04

LABEL maintainer="Mark Lopez <m@silvenga.com>"

RUN set -xe \
    && DEBIAN_FRONTEND=noninteractive apt-get update -q \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y wget \
    && wget -O - https://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest/SALTSTACK-GPG-KEY.pub | apt-key add - \
    && echo "deb http://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest xenial main" > /etc/apt/sources.list.d/saltstack.list \
    && DEBIAN_FRONTEND=noninteractive apt-get update -q \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    salt-master \
    salt-api \
    python-pygit2 \
    virt-what \
    && rm -r /var/lib/apt/lists/*

COPY rootfs/ /

VOLUME [ "/etc/salt/pki", "/var/cache/salt", "/var/log/salt", "/var/run/salt" ]

CMD [ "/bin/bash", "/init.sh" ]