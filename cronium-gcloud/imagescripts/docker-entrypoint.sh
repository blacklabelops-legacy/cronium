#!/bin/bash

set -o errexit

source /opt/cloud/environment-gcloud.sh

if [ -n "${CLOUD_DELAYED_START}" ]; then
  sleep ${CLOUD_DELAYED_START}
fi

$CROW_HOME/docker-entrypoint.sh "$@"
