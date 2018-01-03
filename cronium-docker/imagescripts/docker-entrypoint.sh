#!/bin/bash

set -o errexit

source /opt/cloud/environment-docker.sh

if [ -n "${CLOUD_DELAYED_START}" ]; then
  sleep ${CLOUD_DELAYED_START}
fi

/opt/crow/docker-entrypoint.sh "$@"
