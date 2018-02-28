FROM ubuntu:17.10

LABEL maintainer="Mark Lopez <m@silvenga.com>"

ENV NOTVISIBLE "in users profile"

RUN set -xe \
    && DEBIAN_FRONTEND=noninteractive apt-get update -q \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y wget \
    && wget -O - https://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest/SALTSTACK-GPG-KEY.pub | apt-key add - \
    && echo "deb http://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest xenial main" > /etc/apt/sources.list.d/saltstack.list \
    && DEBIAN_FRONTEND=noninteractive apt-get update -q \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    salt-master=2017.7.4+ds-1 \
    salt-api=2017.7.4+ds-1 \
    python-pygit2 \
    virt-what \
    openssh-server \
    htop \
    && rm -r /var/lib/apt/lists/* \
    && mkdir /var/run/sshd \
    && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
    && echo "export VISIBLE=now" >> /etc/profile

COPY rootfs/ /

EXPOSE 4505
EXPOSE 4506

VOLUME [ "/etc/salt/pki", "/var/cache/salt", "/var/log/salt", "/var/run/salt" ]

CMD [ "/bin/bash", "/init.sh" ]