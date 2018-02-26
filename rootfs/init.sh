#!/bin/bash

echo "Starting salt-api, if there are no configurations, salt-api will exit."
salt-api -d
echo "Starting salt-master."
salt-master --log-level=info