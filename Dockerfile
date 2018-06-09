FROM ubuntu:18.04

LABEL maintainer="Mark Lopez <m@silvenga.com>"

ENV NOTVISIBLE "in users profile"

RUN set -xe \
    && DEBIAN_FRONTEND=noninteractive apt-get update -q \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y wget gnupg \
    && wget -O - https://repo.saltstack.com/py3/ubuntu/16.04/amd64/2018.3/SALTSTACK-GPG-KEY.pub | apt-key add - \
    && echo "deb http://repo.saltstack.com/py3/ubuntu/16.04/amd64/2018.3 xenial main" > /etc/apt/sources.list.d/saltstack.list \
    && DEBIAN_FRONTEND=noninteractive apt-get update -q \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    salt-master=2018.3.0+ds-1 \
    salt-api=2018.3.0+ds-1 \
    python3-pygit2 \
    virt-what \
    openssh-server \
    htop \
    && rm -r /var/lib/apt/lists/* \
    && mkdir /var/run/sshd \
    && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
    && echo "export VISIBLE=now" >> /etc/profile

COPY rootfs/ /

EXPOSE 4505 4506

VOLUME [ "/etc/salt/pki", "/var/cache/salt", "/var/log/salt", "/var/run/salt" ]

CMD [ "/bin/bash", "/init.sh" ]