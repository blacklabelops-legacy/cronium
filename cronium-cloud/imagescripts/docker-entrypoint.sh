#!/bin/bash

set -o errexit

source /opt/cloud/environment-gcloud.sh
source /opt/cloud/environment-tutum.sh
source /opt/cloud/environment-docker.sh

if [ -n "${CLOUD_DELAYED_START}" ]; then
  sleep ${CLOUD_DELAYED_START}
fi

$CROW_HOME/docker-entrypoint.sh "$@"
