#!/bin/bash


if [[ -v SSH_KEY ]]; then
    echo "SSH_KEY found, adding keys."
    mkdir -p /root/.ssh/
    echo "${SSH_KEY}" > /root/.ssh/authorized_keys
    chmod 700 /root/.ssh/
    chmod 600 /root/.ssh/authorized_keys
    echo "Starting sshd for management."
    /usr/sbin/sshd
else
    echo "SSH_KEY not found, will not ssh server."
fi

echo "Starting salt-api, if there are no configurations, salt-api will exit."
salt-api -d
echo "Starting salt-master."
salt-master --log-level=info