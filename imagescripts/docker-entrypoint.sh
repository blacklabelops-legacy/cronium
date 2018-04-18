#!/bin/bash

set -o errexit

[[ ${DEBUG} == true ]] && set -x && LOG4J_LOG_LEVEL=debug

source ${CROW_HOME}/create-config.sh

source ${CROW_HOME}/jobber-migration.sh

source $CROW_HOME/import-gpg.sh

source $CROW_HOME/create-log-config.sh

if [ ! -e "application.properties" ]; then
  createPropertyFile
  createConfig
fi

if [ ! -e "log4j.xml" ]; then
  createLogConfig
fi

if [ -n "${CRONIUM_UID}" ]; then
  createCustomUser $CRONIUM_UID $CRONIUM_GID
fi

if [ "${DEBUG}" = 'true' ]; then
  cat application.yml
  cat log4j.xml
fi

if [ -n "${CRONIUM_BASE_URL}" ]; then
  export CROW_BASE_URL=${CRONIUM_BASE_URL}
fi

importKeys

if [ "$1" = 'cronium-server' ] || [ "${1:0:1}" = '-' ]; then
  migrateJobberEnvs
  pipeEnvironmentVariables
  if [ -n "${CROW_UID}" ]; then
      printUserInfo
      exec su-exec cronium java ${JAVA_OPTS} -Dlogging.config=log4j.xml -jar ${CROW_HOME}/crow-application.jar "$@"
  else
    exec java ${JAVA_OPTS} -Dlogging.config=log4j.xml -jar ${CROW_HOME}/crow-application.jar "$@"
  fi
else
  if [ -n "${CROW_UID}" ]; then
    printUserInfo
    exec su-exec cronium "$@"
  else
    exec "$@"
  fi
fi
