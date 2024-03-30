FROM ubuntu:jammy AS s6-overlay

ARG S6_OVERLAY_VERSION=3.1.6.2

RUN set -ex \
    && apt-get update \
    && apt-get install -y xz-utils curl \
    && curl -fsSL https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz -o /tmp/s6-overlay-noarch.tar.xz \
    && curl -fsSL https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz -o /tmp/s6-overlay-x86_64.tar.xz \
    && tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz \
    && tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz \
    && apt-get purge --autoremove -y xz-utils curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/init"]

FROM s6-overlay AS salt

RUN set -ex \
    && apt-get update \
    && apt-get install -y \
    curl \
    gnupg \
    bash \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN set -ex \
    && adduser --uid 450 --group --shell /bin/sh --system --disabled-password salt

ARG SALT_VERSION=3006
RUN set -xe \
    && curl -fsSL -o /etc/apt/keyrings/salt-archive-keyring.gpg https://repo.saltproject.io/salt/py3/ubuntu/22.04/amd64/${SALT_VERSION}/SALT-PROJECT-GPG-PUBKEY-2023.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/salt-archive-keyring.gpg arch=amd64] https://repo.saltproject.io/salt/py3/ubuntu/22.04/amd64/${SALT_VERSION} jammy main" | tee /etc/apt/sources.list.d/salt.list \
    && apt-get update \
    && apt-get install -y \
    salt-master \
    salt-api \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

FROM salt AS build

RUN set -ex \
    && apt-get update \
    && apt-get install -y \
    libpq-dev \
    libgit2-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN set -xe \
    # For postgres support.
    && salt-pip install psycopg2-binary \
    # For gitfs support. Version 1.7.0 doesn't require a home directory - Salt 3006 now runs with a user without a home directory.
    && salt-pip install pygit2==1.7.0 --no-deps \
    # Default location for self-generated certs, set via the master's ca.cert_base_path.
    && mkdir /etc/pki \
    && chown 450:450 /etc/pki

ADD rootfs/ /

FROM build

LABEL maintainer "Mark Lopez <m@silvenga.com>"
LABEL org.opencontainers.image.source https://github.com/silvenga-docker/salt-master

EXPOSE 4505 \
    4506 \
    8000

# VOLUME [ "/etc/salt", "/var/cache/salt", "/var/log/salt", "/var/run/salt" ]

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2

CMD ["salt-master", "-linfo"]
